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

final class SaveScannerTests: XCTestCase {
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

    func testResolvesPSPStorageRootFromRootPSPAndSaveDataFolders() throws {
        let scanner = SaveScanner()
        let root = temporaryRoot.appendingPathComponent("memory-stick", isDirectory: true)
        let psp = root.appendingPathComponent("PSP", isDirectory: true)
        let savedata = psp.appendingPathComponent("SAVEDATA", isDirectory: true)
        try fileManager.createDirectory(at: savedata, withIntermediateDirectories: true)

        XCTAssertEqual(scanner.resolvePSPStorageRoot(from: root), root.standardizedFileURL)
        XCTAssertEqual(scanner.resolvePSPStorageRoot(from: psp), root.standardizedFileURL)
        XCTAssertEqual(scanner.resolvePSPStorageRoot(from: savedata), root.standardizedFileURL)
    }

    func testScanPSPSavesAcceptsNormalizedStorageRoot() throws {
        let scanner = SaveScanner()
        let root = temporaryRoot.appendingPathComponent("memory-stick", isDirectory: true)
        let saveRoot = root.appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
        let save = saveRoot.appendingPathComponent("ULUS10000DATA00", isDirectory: true)
        try fileManager.createDirectory(at: save, withIntermediateDirectories: true)
        try "data".write(to: save.appendingPathComponent("DATA.BIN"), atomically: true, encoding: .utf8)

        let saves = try scanner.scanPSPSaves(storageRoot: root.appendingPathComponent("PSP", isDirectory: true), catalog: .empty)

        XCTAssertEqual(saves.map(\.folderName), ["ULUS10000DATA00"])
    }

    func testScanSyncSavesNormalizesPSPAndSaveDataFolders() throws {
        let scanner = SaveScanner()
        let root = temporaryRoot.appendingPathComponent("sync", isDirectory: true)
        let saveRoot = root.appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
        let save = saveRoot.appendingPathComponent("ULUS10000DATA00", isDirectory: true)
        try fileManager.createDirectory(at: save, withIntermediateDirectories: true)
        try "data".write(to: save.appendingPathComponent("DATA.BIN"), atomically: true, encoding: .utf8)

        let pspSaves = try scanner.scanSyncSaves(syncRoot: root.appendingPathComponent("PSP", isDirectory: true), catalog: .empty)
        let saveDataSaves = try scanner.scanSyncSaves(syncRoot: saveRoot, catalog: .empty)

        XCTAssertEqual(pspSaves.map(\.folderName), ["ULUS10000DATA00"])
        XCTAssertEqual(saveDataSaves.map(\.folderName), ["ULUS10000DATA00"])
        XCTAssertEqual(scanner.resolveSyncRoot(from: saveRoot), root.standardizedFileURL)
    }

    func testScanUsesFileModificationDateInsteadOfSaveFolderModificationDate() throws {
        let scanner = SaveScanner()
        let pspRoot = temporaryRoot.appendingPathComponent("psp", isDirectory: true)
        let syncRoot = temporaryRoot.appendingPathComponent("sync", isDirectory: true)
        let pspSave = pspRoot.appendingPathComponent("PSP/SAVEDATA/ULUS10000DATA00", isDirectory: true)
        let syncSave = syncRoot.appendingPathComponent("PSP/SAVEDATA/ULUS10000DATA00", isDirectory: true)
        try fileManager.createDirectory(at: pspSave, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: syncSave, withIntermediateDirectories: true)
        let fileDate = Date(timeIntervalSince1970: 1_700_000_000)
        try writeSaveFile(in: pspSave, contents: "same", modifiedAt: fileDate)
        try writeSaveFile(in: syncSave, contents: "same", modifiedAt: fileDate)
        try fileManager.setAttributes([.modificationDate: Date(timeIntervalSince1970: 1_700_000_500)], ofItemAtPath: syncSave.path)

        let pspSaves = try scanner.scanPSPSaves(storageRoot: pspRoot, catalog: .empty)
        let syncSaves = try scanner.scanSyncSaves(syncRoot: syncRoot, catalog: .empty)
        let row = SaveComparison(folderName: "ULUS10000DATA00", psp: pspSaves.first, sync: syncSaves.first)

        XCTAssertEqual(row.state, .same)
    }

    private func writeSaveFile(in folderURL: URL, contents: String, modifiedAt: Date) throws {
        let fileURL = folderURL.appendingPathComponent("DATA.BIN")
        try contents.write(to: fileURL, atomically: true, encoding: .utf8)
        try fileManager.setAttributes([.modificationDate: modifiedAt], ofItemAtPath: fileURL.path)
    }
}
