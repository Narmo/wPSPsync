//
// Copyright (c) 2026 Nikita Denin <nik@brite-apps.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import AppKit
import Foundation
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published private(set) var externalCandidates: [VolumeCandidate] = []
    @Published var selectedExternalRoot: URL? {
        didSet {
            persistSelectedRoot(selectedExternalRoot, key: .externalRoot)
        }
    }
    @Published var selectedSyncRoot: URL? {
        didSet {
            persistSelectedRoot(selectedSyncRoot, key: .syncRoot)
        }
    }
    @Published private(set) var rows: [SaveComparison] = []
    @Published private(set) var catalog: GameCatalog = .empty
    @Published var selectedRowIDs = Set<SaveComparison.ID>()
    @Published var useSerialStationAPI = false
    @Published var backupsEnabled: Bool {
        didSet {
            UserDefaults.standard.set(backupsEnabled, forKey: Self.backupsEnabledKey)
        }
    }
    @Published var statusMessage = String(localized: "Choose a PSP storage root and a sync root.")
    @Published var isWorking = false
    @Published var alert: AppAlert?
    @Published private(set) var backups: [BackupArchive] = []
    @Published var selectedBackupID: BackupArchive.ID?

    private let scanner = SaveScanner()
    private let syncEngine = SyncEngine()
    private let backupStore = BackupStore()
    private let directoryBookmarkStore = DirectoryBookmarkStore()
    private let catalogStore = CatalogStore()
    private let serialStationClient = SerialStationClient()
    private let serialStationCacheStore = SerialStationCacheStore()
    private var serialStationCache: [String: GameMetadata] = [:]
    private var accessedDirectoryPaths = Set<String>()
    private var promptedExternalRootAccessPaths = Set<String>()
    private static let backupsEnabledKey = "backupsEnabled"

    init() {
        backupsEnabled = UserDefaults.standard.object(forKey: Self.backupsEnabledKey) as? Bool ?? true
        loadSerialStationCache()
        restoreSelectedRoots()
        refreshBackups()
        Task {
            await loadCatalog()
            await refreshVolumes()
        }
    }

    deinit {
        for path in accessedDirectoryPaths {
            URL(fileURLWithPath: path).stopAccessingSecurityScopedResource()
        }
    }

    func refreshVolumes() async {
        externalCandidates = scanner.discoverVolumeCandidates()
        if selectedExternalRoot == nil, let candidate = externalCandidates.first {
            await requestAccessToDetectedExternalRoot(candidate.rootURL)
        }
        guard selectedExternalRoot != nil else {
            rows = []
            if externalCandidates.isEmpty {
                statusMessage = String(localized: "No PSP storage selected.")
            }
            return
        }
        await scan()
    }

    func loadCatalog() async {
        do {
            catalog = try catalogStore.loadCatalog()
        } catch {
            alert = AppAlert(title: String(localized: "Catalog could not be loaded"), message: error.localizedDescription)
        }
    }

    func importCatalog(from url: URL) async {
        do {
            catalog = try catalogStore.importCatalog(from: url)
            await scan()
            statusMessage = String(localized: "Imported \(catalog.games.count) catalog entries.")
        } catch {
            alert = AppAlert(title: String(localized: "Catalog import failed"), message: error.localizedDescription)
        }
    }

    func selectExternalRoot() {
        if let url = DirectoryPicker.pick(
            title: String(localized: "Select PSP storage root"),
            message: String(localized: "Choose the top-level PSP volume or memory card folder that contains PSP/SAVEDATA."),
            directoryURL: selectedExternalRoot ?? externalCandidates.first?.rootURL
        ) {
            setExternalRoot(url)
            Task {
                await scan()
            }
        }
    }

    func selectSyncRoot() {
        if let url = DirectoryPicker.pick(
            title: String(localized: "Select sync root"),
            message: String(localized: "Choose the top-level folder that contains or will contain PSP/SAVEDATA.")
        ) {
            setSyncRoot(url)
            Task {
                await scan()
            }
        }
    }

    func setExternalRoot(_ url: URL?) {
        selectedExternalRoot = url
    }

    func setSyncRoot(_ url: URL?) {
        selectedSyncRoot = url
    }

    func scan() async {
        guard let externalRoot = selectedExternalRoot else {
            rows = []
            statusMessage = String(localized: "No PSP storage selected.")
            return
        }
        let syncRoot = selectedSyncRoot
        let catalog = catalog

        isWorking = true
        defer {
            isWorking = false
        }

        do {
            var (pspSaves, syncSaves) = try await Task.detached(priority: .userInitiated) {
                let scanner = SaveScanner()
                let pspSaves = try scanner.scanPSPSaves(storageRoot: externalRoot, catalog: catalog)
                let syncSaves = try syncRoot.map { try scanner.scanSyncSaves(syncRoot: $0, catalog: catalog) } ?? []
                return (pspSaves, syncSaves)
            }.value

            var metadata = serialStationCache
            if useSerialStationAPI {
                metadata = await fetchSerialStationMetadata(for: pspSaves + syncSaves)
            }
            if !metadata.isEmpty {
                pspSaves = pspSaves.map { $0.enriched(with: metadata[$0.gameID] ?? $0.game) }
                syncSaves = syncSaves.map { $0.enriched(with: metadata[$0.gameID] ?? $0.game) }
            }

            rows = syncEngine.compare(pspSaves: pspSaves, syncSaves: syncSaves)
            selectedRowIDs = Set(rows.filter { $0.state != .same }.map(\.id))
            statusMessage = String(localized: "\(rows.count) save folders found.")
        } catch {
            rows = []
            statusMessage = String(localized: "Scan failed.")
            alert = AppAlert(title: String(localized: "Scan failed"), message: error.localizedDescription)
        }
    }

    func syncSelected() async {
        guard let syncRoot = selectedSyncRoot else {
            alert = AppAlert(title: String(localized: "Sync root required"), message: String(localized: "Select a sync root before syncing."))
            return
        }

        guard let externalRoot = selectedExternalRoot else {
            alert = AppAlert(title: String(localized: "PSP storage required"), message: String(localized: "Select PSP storage before syncing."))
            return
        }

        let selectedRows = rows.filter { selectedRowIDs.contains($0.id) }
        let willWriteChanges = selectedRows.contains { $0.state != .same }
        let shouldCreateBackup = backupsEnabled && willWriteChanges

        isWorking = true
        defer {
            isWorking = false
        }

        do {
            if shouldCreateBackup {
                let backupURL = try await Task.detached(priority: .userInitiated) {
                    try BackupStore().createBackup(of: syncRoot)
                }.value
                refreshBackups()
                statusMessage = String(localized: "Created backup \(backupURL.lastPathComponent).")
            }
            let syncedCount = try await Task.detached(priority: .userInitiated) {
                try SyncEngine().syncLatest(rows: selectedRows, syncRoot: syncRoot, pspRoot: externalRoot)
            }.value
            await scan()
            statusMessage = syncedCount == 0 ? String(localized: "Everything is already in sync.") : String(localized: "Synced \(syncedCount) save folders.")
        } catch {
            alert = AppAlert(title: String(localized: "Sync failed"), message: error.localizedDescription)
        }
    }

    func deletePSPSave(_ row: SaveComparison) async {
        guard let save = row.psp else {
            return
        }
        await deleteSave(
            at: save.rootURL,
            title: String(localized: "Delete from PSP storage?"),
            message: String(localized: "This will permanently delete \(row.displayTitle) from PSP storage."),
            status: String(localized: "Deleted \(row.displayTitle) from PSP storage.")
        )
    }

    func deleteSyncSave(_ row: SaveComparison) async {
        guard let save = row.sync else {
            return
        }
        await deleteSave(
            at: save.rootURL,
            title: String(localized: "Delete from sync root?"),
            message: String(localized: "This will permanently delete \(row.displayTitle) from the sync root."),
            status: String(localized: "Deleted \(row.displayTitle) from the sync root.")
        )
    }

    func deleteBothSaves(_ row: SaveComparison) async {
        guard let pspSave = row.psp, let syncSave = row.sync else {
            return
        }
        await deleteSaves(
            urls: [pspSave.rootURL, syncSave.rootURL],
            title: String(localized: "Delete both copies?"),
            message: String(localized: "This will permanently delete \(row.displayTitle) from PSP storage and the sync root."),
            status: String(localized: "Deleted \(row.displayTitle) from both sides.")
        )
    }

    func restoreSelectedBackup() async {
        guard let syncRoot = selectedSyncRoot else {
            alert = AppAlert(title: String(localized: "Sync root required"), message: String(localized: "Select a sync root before restoring a backup."))
            return
        }

        guard let backup = backups.first(where: { $0.id == selectedBackupID }) else {
            alert = AppAlert(title: String(localized: "Backup required"), message: String(localized: "Select a backup before restoring."))
            return
        }
        let backupURL = backup.url

        let confirmed = ConfirmationDialog.ask(
            title: String(localized: "Restore backup?"),
            message: String(localized: "This will replace the current sync root contents with \(backupURL.lastPathComponent)."),
            confirmTitle: String(localized: "Restore")
        )
        guard confirmed else {
            return
        }

        isWorking = true
        defer {
            isWorking = false
        }

        do {
            if backupsEnabled {
                let currentBackupURL = try backupStore.createBackup(of: syncRoot, preserving: backupURL)
                refreshBackups()
                statusMessage = String(localized: "Created backup \(currentBackupURL.lastPathComponent).")
            }
            try backupStore.restoreBackup(from: backupURL, to: syncRoot)
            await scan()
            refreshBackups()
            statusMessage = String(localized: "Restored \(backupURL.lastPathComponent).")
        } catch {
            alert = AppAlert(title: String(localized: "Restore failed"), message: error.localizedDescription)
        }
    }

    func refreshBackups() {
        do {
            backups = try backupStore.listBackups()
            if selectedBackupID == nil || !backups.contains(where: { $0.id == selectedBackupID }) {
                selectedBackupID = backups.first?.id
            }
        } catch {
            backups = []
            selectedBackupID = nil
            alert = AppAlert(title: String(localized: "Backups could not be loaded"), message: error.localizedDescription)
        }
    }

    private func fetchSerialStationMetadata(for saves: [SaveGame]) async -> [String: GameMetadata] {
        let ids = Array(Set(saves.map(\.gameID))).filter { GameIDParser.parse(from: $0) != nil }
        var result = serialStationCache
        let missingIDs = ids.filter { result[$0] == nil }

        if missingIDs.isEmpty {
            return result
        }

        statusMessage = String(localized: "Looking up \(missingIDs.count) titles on SerialStation...")

        let client = serialStationClient

        await withTaskGroup(of: (String, GameMetadata?).self) { group in
            for id in missingIDs {
                group.addTask {
                    let metadata = try? await client.metadata(for: id)
                    return (id, metadata)
                }
            }

            for await (id, metadata) in group {
                if let metadata {
                    result[id] = metadata
                }
            }
        }

        serialStationCache = result
        saveSerialStationCache()
        return result
    }

    private func deleteSave(at url: URL, title: String, message: String, status: String) async {
        await deleteSaves(urls: [url], title: title, message: message, status: status)
    }

    private func deleteSaves(urls: [URL], title: String, message: String, status: String) async {
        let confirmed = ConfirmationDialog.ask(
            title: title,
            message: message,
            confirmTitle: String(localized: "Delete")
        )
        guard confirmed else {
            return
        }

        isWorking = true
        defer {
            isWorking = false
        }

        do {
            for url in urls {
                try FileManager.default.removeItem(at: url)
            }
            await scan()
            statusMessage = status
        } catch {
            alert = AppAlert(title: String(localized: "Delete failed"), message: error.localizedDescription)
        }
    }

    private func loadSerialStationCache() {
        serialStationCache = (try? serialStationCacheStore.load()) ?? [:]
    }

    private func saveSerialStationCache() {
        try? serialStationCacheStore.save(serialStationCache)
    }

    private func requestAccessToDetectedExternalRoot(_ url: URL, forcePrompt: Bool = false) async {
        let standardizedURL = url.standardizedFileURL
        let path = standardizedURL.path
        if !forcePrompt, promptedExternalRootAccessPaths.contains(path) {
            statusMessage = String(localized: "PSP storage detected. Choose it to grant access.")
            return
        }

        promptedExternalRootAccessPaths.insert(path)
        guard let selectedURL = DirectoryPicker.pick(
            title: String(localized: "Select PSP storage root"),
            message: String(localized: "Choose the top-level PSP volume or memory card folder that contains PSP/SAVEDATA."),
            directoryURL: standardizedURL
        ) else {
            statusMessage = String(localized: "PSP storage detected. Choose it to grant access.")
            return
        }

        setExternalRoot(selectedURL)
    }

    private func restoreSelectedRoots() {
        do {
            if let externalRoot = try directoryBookmarkStore.loadURL(for: .externalRoot) {
                selectedExternalRoot = externalRoot
            }
            if let syncRoot = try directoryBookmarkStore.loadURL(for: .syncRoot) {
                selectedSyncRoot = syncRoot
            }
        } catch {
            alert = AppAlert(title: String(localized: "Saved folders could not be restored"), message: error.localizedDescription)
        }
    }

    private func persistSelectedRoot(_ url: URL?, key: DirectoryBookmarkStore.Key) {
        guard let url else {
            return
        }

        let standardizedURL = url.standardizedFileURL
        let path = standardizedURL.path
        if !accessedDirectoryPaths.contains(path), standardizedURL.startAccessingSecurityScopedResource() {
            accessedDirectoryPaths.insert(path)
        }

        do {
            try directoryBookmarkStore.save(standardizedURL, for: key)
        } catch {
            alert = AppAlert(title: String(localized: "Folder selection could not be saved"), message: error.localizedDescription)
        }
    }
}

struct AppAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

enum DirectoryPicker {
    static func pick(title: String, message: String, directoryURL: URL? = nil) -> URL? {
        let panel = NSOpenPanel()
        panel.title = title
        panel.message = message
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.canCreateDirectories = true
        panel.directoryURL = directoryURL
        return panel.runModal() == .OK ? panel.url : nil
    }
}

enum ConfirmationDialog {
    static func ask(title: String, message: String, confirmTitle: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: confirmTitle)
        alert.addButton(withTitle: String(localized: "Cancel"))
        return alert.runModal() == .alertFirstButtonReturn
    }
}
