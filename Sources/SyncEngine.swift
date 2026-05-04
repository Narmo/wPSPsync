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

struct SyncEngine {
    private let fileManager = FileManager.default

    func compare(pspSaves: [SaveGame], syncSaves: [SaveGame]) -> [SaveComparison] {
        let pspByFolder = Dictionary(uniqueKeysWithValues: pspSaves.map { ($0.folderName, $0) })
        let syncByFolder = Dictionary(uniqueKeysWithValues: syncSaves.map { ($0.folderName, $0) })
        let folders = Set(pspByFolder.keys).union(syncByFolder.keys)

        return folders.map { folder in
            SaveComparison(folderName: folder, psp: pspByFolder[folder], sync: syncByFolder[folder])
        }
        .sorted {
            $0.displayTitle.localizedStandardCompare($1.displayTitle) == .orderedAscending
        }
    }

    func syncLatest(rows: [SaveComparison], syncRoot: URL, pspRoot: URL) throws -> Int {
        var syncedCount = 0

        for row in rows {
            switch row.state {
            case .pspNewer, .onlyPSP:
                guard let source = row.psp?.rootURL else {
                    continue
                }
                let destination = saveDestination(for: row.folderName, syncRoot: syncRoot)
                try replaceDirectory(source: source, destination: destination)
                syncedCount += 1
            case .syncNewer, .onlySync:
                guard let source = row.sync?.rootURL else {
                    continue
                }
                let destination = pspDestination(for: row.folderName, pspRoot: pspRoot)
                try replaceDirectory(source: source, destination: destination)
                syncedCount += 1
            case .same:
                continue
            }
        }

        return syncedCount
    }

    private func pspDestination(for folderName: String, pspRoot: URL) -> URL {
        storageRoot(from: pspRoot)
            .appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
    }

    private func saveDestination(for folderName: String, syncRoot: URL) -> URL {
        let normalizedSyncRoot = storageRoot(from: syncRoot)
        let pspStyleRoot = normalizedSyncRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
        if directoryExists(pspStyleRoot) || !directoryContainsSaveFolders(normalizedSyncRoot) {
            return pspStyleRoot.appendingPathComponent(folderName, isDirectory: true)
        }
        return normalizedSyncRoot.appendingPathComponent(folderName, isDirectory: true)
    }

    private func storageRoot(from url: URL) -> URL {
        let standardizedURL = url.standardizedFileURL

        if standardizedURL.lastPathComponent.uppercased() == "PSP",
           directoryExists(standardizedURL.appendingPathComponent("SAVEDATA", isDirectory: true)) {
            return standardizedURL.deletingLastPathComponent()
        }

        if standardizedURL.lastPathComponent.uppercased() == "SAVEDATA",
           standardizedURL.deletingLastPathComponent().lastPathComponent.uppercased() == "PSP",
           directoryExists(standardizedURL) {
            return standardizedURL.deletingLastPathComponent().deletingLastPathComponent()
        }

        return standardizedURL
    }

    private func replaceDirectory(source: URL, destination: URL) throws {
        let parent = destination.deletingLastPathComponent()
        try fileManager.createDirectory(at: parent, withIntermediateDirectories: true)
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: source, to: destination)
    }

    private func directoryExists(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = false
        return fileManager.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
    }

    private func directoryContainsSaveFolders(_ url: URL) -> Bool {
        guard let contents = try? fileManager.contentsOfDirectory(atPath: url.path) else {
            return false
        }
        return contents.contains { GameIDParser.parse(from: $0) != nil }
    }
}
