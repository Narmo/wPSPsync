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

import Foundation

struct SaveScanner {
    private let fileManager = FileManager.default

    func discoverVolumeCandidates() -> [VolumeCandidate] {
        guard let volumeURLs = fileManager.mountedVolumeURLs(
            includingResourceValuesForKeys: [.volumeNameKey, .isRegularFileKey, .volumeIsRemovableKey, .volumeIsInternalKey],
            options: [.skipHiddenVolumes]
        ) else {
            return []
        }

        return volumeURLs.compactMap { volumeURL in
            guard let storageRoot = resolvePSPStorageRoot(from: volumeURL) else {
                return nil
            }
            let saveDataURL = storageRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
            let name = (try? storageRoot.resourceValues(forKeys: [.volumeNameKey]).volumeName) ?? storageRoot.lastPathComponent
            return VolumeCandidate(name: name, rootURL: storageRoot, saveDataURL: saveDataURL)
        }
        .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    func scanPSPSaves(storageRoot: URL, catalog: GameCatalog) throws -> [SaveGame] {
        guard let pspRoot = resolvePSPStorageRoot(from: storageRoot) else {
            return []
        }
        let saveDataURL = pspRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
        return try scanSaveFolders(in: saveDataURL, catalog: catalog)
    }

    func resolvePSPStorageRoot(from url: URL) -> URL? {
        let standardizedURL = url.standardizedFileURL
        if directoryExists(standardizedURL.appendingPathComponent("PSP/SAVEDATA", isDirectory: true)) {
            return standardizedURL
        }

        if standardizedURL.lastPathComponent.uppercased() == "PSP",
           directoryExists(standardizedURL.appendingPathComponent("SAVEDATA", isDirectory: true)) {
            return standardizedURL.deletingLastPathComponent()
        }

        if standardizedURL.lastPathComponent.uppercased() == "SAVEDATA",
           standardizedURL.deletingLastPathComponent().lastPathComponent.uppercased() == "PSP",
           directoryExists(standardizedURL) {
            return standardizedURL.deletingLastPathComponent().deletingLastPathComponent()
        }

        return nil
    }

    func scanSyncSaves(syncRoot: URL, catalog: GameCatalog) throws -> [SaveGame] {
        let normalizedSyncRoot = resolveSyncRoot(from: syncRoot)
        let saveDataURL = normalizedSyncRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
        if directoryExists(saveDataURL) {
            return try scanSaveFolders(in: saveDataURL, catalog: catalog)
        }
        return try scanSaveFolders(in: normalizedSyncRoot, catalog: catalog)
    }

    func resolveSyncRoot(from url: URL) -> URL {
        let standardizedURL = url.standardizedFileURL

        if standardizedURL.lastPathComponent.uppercased() == "PSP",
           directoryExists(standardizedURL.appendingPathComponent("SAVEDATA", isDirectory: true)) {
            return standardizedURL.deletingLastPathComponent()
        }

        if standardizedURL.lastPathComponent.uppercased() == "SAVEDATA",
           standardizedURL.deletingLastPathComponent().lastPathComponent.uppercased() == "PSP" {
            return standardizedURL.deletingLastPathComponent().deletingLastPathComponent()
        }

        return standardizedURL
    }

    private func scanSaveFolders(in root: URL, catalog: GameCatalog) throws -> [SaveGame] {
        guard directoryExists(root) else {
            return []
        }

        let urls = try fileManager.contentsOfDirectory(
            at: root,
            includingPropertiesForKeys: [.isDirectoryKey, .contentModificationDateKey, .totalFileAllocatedSizeKey],
            options: [.skipsHiddenFiles]
        )

        return try urls.compactMap { url in
            let values = try url.resourceValues(forKeys: [.isDirectoryKey])
            guard values.isDirectory == true else {
                return nil
            }
            return try makeSaveGame(from: url, catalog: catalog)
        }
        .sorted {
            $0.displayTitle.localizedStandardCompare($1.displayTitle) == .orderedAscending
        }
    }

    private func makeSaveGame(from url: URL, catalog: GameCatalog) throws -> SaveGame {
        let modifiedAt = try recursiveModifiedDate(for: url)
        let size = try recursiveSize(for: url)
        let iconURL = ["ICON0.PNG", "ICON0.png", "PIC1.PNG", "PIC1.png"]
            .map { url.appendingPathComponent($0) }
            .first { fileManager.fileExists(atPath: $0.path) }

        return SaveGame(
            folderName: url.lastPathComponent,
            rootURL: url,
            modifiedAt: modifiedAt,
            size: size,
            game: catalog.metadata(for: url.lastPathComponent),
            iconURL: iconURL
        )
    }

    private func recursiveModifiedDate(for url: URL) throws -> Date {
        var latestFileDate: Date?
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.contentModificationDateKey, .isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return try folderModifiedDate(for: url)
        }

        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: [.contentModificationDateKey, .isRegularFileKey])
            guard values.isRegularFile == true, let date = values.contentModificationDate else {
                continue
            }
            latestFileDate = max(latestFileDate ?? .distantPast, date)
        }

        if let latestFileDate {
            return latestFileDate
        }
        return try folderModifiedDate(for: url)
    }

    private func folderModifiedDate(for url: URL) throws -> Date {
        try url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? .distantPast
    }

    private func recursiveSize(for url: URL) throws -> Int64 {
        var total: Int64 = 0
        guard let enumerator = fileManager.enumerator(
            at: url,
            includingPropertiesForKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return total
        }

        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: [.totalFileAllocatedSizeKey, .fileAllocatedSizeKey])
            total += Int64(values.totalFileAllocatedSize ?? values.fileAllocatedSize ?? 0)
        }
        return total
    }

    private func directoryExists(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }
}
