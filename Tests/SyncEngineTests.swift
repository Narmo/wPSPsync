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

import XCTest

final class SyncEngineTests: XCTestCase {
    private let fileManager = FileManager.default
    private var temporaryRoot: URL!

    override func setUpWithError() throws {
        let root = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
        try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
        temporaryRoot = root
        addTeardownBlock {
            if self.fileManager.fileExists(atPath: root.path) {
                try self.fileManager.removeItem(at: root)
            }
        }
    }

    override func tearDownWithError() throws {
        temporaryRoot = nil
    }

    func testSyncLatestCopiesNewerAndMissingSavesBothWays() throws {
        let engine = SyncEngine()
        let pspRoot = temporaryRoot.appendingPathComponent("psp", isDirectory: true)
        let syncRoot = temporaryRoot.appendingPathComponent("sync", isDirectory: true)

        let olderDate = Date(timeIntervalSince1970: 1_700_000_000)
        let newerDate = Date(timeIntervalSince1970: 1_700_000_100)
        let pspNewer = try makeSave(root: pspRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true), folderName: "ULUS10000DATA00", fileName: "DATA.BIN", contents: "psp-newer", modifiedAt: newerDate)
        let syncOlder = try makeSave(root: syncRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true), folderName: "ULUS10000DATA00", fileName: "DATA.BIN", contents: "sync-older", modifiedAt: olderDate)
        let pspOlder = try makeSave(root: pspRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true), folderName: "ULUS10001DATA00", fileName: "DATA.BIN", contents: "psp-older", modifiedAt: olderDate)
        let syncNewer = try makeSave(root: syncRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true), folderName: "ULUS10001DATA00", fileName: "DATA.BIN", contents: "sync-newer", modifiedAt: newerDate)
        let onlyPSP = try makeSave(root: pspRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true), folderName: "ULUS10002DATA00", fileName: "DATA.BIN", contents: "only-psp", modifiedAt: newerDate)
        let onlySync = try makeSave(root: syncRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true), folderName: "ULUS10003DATA00", fileName: "DATA.BIN", contents: "only-sync", modifiedAt: newerDate)

        let rows = [
            SaveComparison(folderName: "ULUS10000DATA00", psp: pspNewer, sync: syncOlder),
            SaveComparison(folderName: "ULUS10001DATA00", psp: pspOlder, sync: syncNewer),
            SaveComparison(folderName: "ULUS10002DATA00", psp: onlyPSP, sync: nil),
            SaveComparison(folderName: "ULUS10003DATA00", psp: nil, sync: onlySync)
        ]

        let syncedCount = try engine.syncLatest(rows: rows, syncRoot: syncRoot, pspRoot: pspRoot)

        XCTAssertEqual(syncedCount, 4)
        XCTAssertEqual(try readSave(root: syncRoot, folderName: "ULUS10000DATA00"), "psp-newer")
        XCTAssertEqual(try readSave(root: pspRoot, folderName: "ULUS10001DATA00"), "sync-newer")
        XCTAssertEqual(try readSave(root: syncRoot, folderName: "ULUS10002DATA00"), "only-psp")
        XCTAssertEqual(try readSave(root: pspRoot, folderName: "ULUS10003DATA00"), "only-sync")
    }

    func testSyncLatestDoesNotNestSaveDataWhenSyncRootPointsAtSaveDataFolder() throws {
        let engine = SyncEngine()
        let pspRoot = temporaryRoot.appendingPathComponent("psp", isDirectory: true)
        let syncRoot = temporaryRoot.appendingPathComponent("sync", isDirectory: true)
        let saveDataRoot = syncRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
        let pspSave = try makeSave(
            root: pspRoot.appendingPathComponent("PSP/SAVEDATA", isDirectory: true),
            folderName: "ULUS10000DATA00",
            fileName: "DATA.BIN",
            contents: "psp-newer",
            modifiedAt: Date(timeIntervalSince1970: 1_700_000_100)
        )
        let syncSave = try makeSave(
            root: saveDataRoot,
            folderName: "ULUS10000DATA00",
            fileName: "DATA.BIN",
            contents: "sync-older",
            modifiedAt: Date(timeIntervalSince1970: 1_700_000_000)
        )
        let row = SaveComparison(folderName: "ULUS10000DATA00", psp: pspSave, sync: syncSave)

        _ = try engine.syncLatest(rows: [row], syncRoot: saveDataRoot, pspRoot: pspRoot)

        XCTAssertEqual(try readSave(root: syncRoot, folderName: "ULUS10000DATA00"), "psp-newer")
        XCTAssertFalse(fileManager.fileExists(atPath: saveDataRoot.appendingPathComponent("SAVEDATA").path))
    }

    private func makeSave(root: URL, folderName: String, fileName: String, contents: String, modifiedAt: Date) throws -> SaveGame {
        let folderURL = root.appendingPathComponent(folderName, isDirectory: true)
        try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        try contents.write(to: folderURL.appendingPathComponent(fileName), atomically: true, encoding: .utf8)

        return SaveGame(
            folderName: folderName,
            rootURL: folderURL,
            modifiedAt: modifiedAt,
            size: Int64(contents.utf8.count),
            game: nil,
            iconURL: nil
        )
    }

    private func readSave(root: URL, folderName: String) throws -> String {
        let url = root
            .appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
            .appendingPathComponent(folderName, isDirectory: true)
            .appendingPathComponent("DATA.BIN")
        return try String(contentsOf: url, encoding: .utf8)
    }
}
