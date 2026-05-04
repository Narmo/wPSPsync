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

final class BackupStoreTests: XCTestCase {
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

    func testCreatesZipBackupAndRestoresSyncRootContents() throws {
        let syncRoot = temporaryRoot.appendingPathComponent("sync", isDirectory: true)
        let backupsRoot = temporaryRoot.appendingPathComponent("backups", isDirectory: true)
        let store = BackupStore(backupsDirectory: backupsRoot, dateProvider: {
            Date(timeIntervalSince1970: 1_700_000_000)
        })
        let save = syncRoot
            .appendingPathComponent("PSP/SAVEDATA", isDirectory: true)
            .appendingPathComponent("ULUS10000DATA00", isDirectory: true)
        try fileManager.createDirectory(at: save, withIntermediateDirectories: true)
        try "original".write(to: save.appendingPathComponent("DATA.BIN"), atomically: true, encoding: .utf8)

        let backupURL = try store.createBackup(of: syncRoot)
        try "changed".write(to: save.appendingPathComponent("DATA.BIN"), atomically: true, encoding: .utf8)
        try "extra".write(to: syncRoot.appendingPathComponent("EXTRA.BIN"), atomically: true, encoding: .utf8)

        try store.restoreBackup(from: backupURL, to: syncRoot)

        let restoredURL = save.appendingPathComponent("DATA.BIN")
        XCTAssertEqual(try String(contentsOf: restoredURL, encoding: .utf8), "original")
        XCTAssertFalse(fileManager.fileExists(atPath: syncRoot.appendingPathComponent("EXTRA.BIN").path))
        XCTAssertTrue(fileManager.fileExists(atPath: backupURL.path))
        XCTAssertEqual(backupURL.deletingLastPathComponent(), backupsRoot)
    }

    func testKeepsOnlyFiveNewestBackups() throws {
        let syncRoot = temporaryRoot.appendingPathComponent("sync", isDirectory: true)
        let backupsRoot = temporaryRoot.appendingPathComponent("backups", isDirectory: true)
        try fileManager.createDirectory(at: syncRoot, withIntermediateDirectories: true)
        let dataURL = syncRoot.appendingPathComponent("DATA.BIN")
        var backupIndex = 0
        let store = BackupStore(backupsDirectory: backupsRoot, dateProvider: {
            defer {
                backupIndex += 1
            }
            return Date(timeIntervalSince1970: 1_700_000_000 + Double(backupIndex))
        })

        for index in 0..<6 {
            try "\(index)".write(to: dataURL, atomically: true, encoding: .utf8)
            _ = try store.createBackup(of: syncRoot)
        }

        let backups = try store.listBackups()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"

        XCTAssertEqual(backups.count, 5)
        XCTAssertEqual(backups.first?.url.lastPathComponent, "sync-\(formatter.string(from: Date(timeIntervalSince1970: 1_700_000_005))).zip")
        XCTAssertEqual(backups.last?.url.lastPathComponent, "sync-\(formatter.string(from: Date(timeIntervalSince1970: 1_700_000_001))).zip")
        XCTAssertFalse(fileManager.fileExists(atPath: backupsRoot.appendingPathComponent("sync-\(formatter.string(from: Date(timeIntervalSince1970: 1_700_000_000))).zip").path))
    }
}
