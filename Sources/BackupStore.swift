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

struct BackupStore {
    static let maximumBackupCount = 5

    private let fileManager: FileManager
    private let processRunner: ProcessRunning
    private let dateProvider: () -> Date
    private let customBackupsDirectory: URL?

    init(fileManager: FileManager = .default, processRunner: ProcessRunning = SystemProcessRunner(), backupsDirectory: URL? = nil, dateProvider: @escaping () -> Date = Date.init) {
        self.fileManager = fileManager
        self.processRunner = processRunner
        self.customBackupsDirectory = backupsDirectory
        self.dateProvider = dateProvider
    }

    var backupsDirectory: URL {
        if let customBackupsDirectory {
            return customBackupsDirectory
        }
        return appSupportRoot()
            .appendingPathComponent("Backups", isDirectory: true)
    }

    func createBackup(of syncRoot: URL, preserving preservedBackupURL: URL? = nil) throws -> URL {
        try fileManager.createDirectory(at: syncRoot, withIntermediateDirectories: true)
        try fileManager.createDirectory(at: backupsDirectory, withIntermediateDirectories: true)
        let destination = try nextBackupURL()
        try processRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/ditto"),
            arguments: ["-c", "-k", "--sequesterRsrc", "--rsrc", syncRoot.path, destination.path]
        )
        try pruneBackups(preserving: preservedBackupURL)
        return destination
    }

    func listBackups() throws -> [BackupArchive] {
        guard fileManager.fileExists(atPath: backupsDirectory.path) else {
            return []
        }

        let urls = try fileManager.contentsOfDirectory(
            at: backupsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        )

        return try urls
            .filter { $0.pathExtension.lowercased() == "zip" }
            .map { url in
                let modifiedAt = try url.resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate ?? .distantPast
                return BackupArchive(url: url, modifiedAt: modifiedAt)
            }
            .sorted {
                $0.url.lastPathComponent.localizedStandardCompare($1.url.lastPathComponent) == .orderedDescending
            }
    }

    func restoreBackup(from backupURL: URL, to syncRoot: URL) throws {
        try fileManager.createDirectory(at: syncRoot, withIntermediateDirectories: true)
        try removeContents(of: syncRoot)
        try processRunner.run(
            executableURL: URL(fileURLWithPath: "/usr/bin/ditto"),
            arguments: ["-x", "-k", backupURL.path, syncRoot.path]
        )
    }

    private func nextBackupURL() throws -> URL {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let baseName = "sync-\(formatter.string(from: dateProvider()))"
        var candidate = backupsDirectory.appendingPathComponent("\(baseName).zip")
        var index = 2

        while fileManager.fileExists(atPath: candidate.path) {
            candidate = backupsDirectory.appendingPathComponent("\(baseName)-\(index).zip")
            index += 1
        }

        return candidate
    }

    private func pruneBackups(preserving preservedBackupURL: URL?) throws {
        let preservedPath = preservedBackupURL?.standardizedFileURL.path
        var backups = try listBackups()

        while backups.count > Self.maximumBackupCount {
            guard let backup = backups.last(where: { $0.url.standardizedFileURL.path != preservedPath }) else {
                return
            }
            try fileManager.removeItem(at: backup.url)
            backups.removeAll { $0.url == backup.url }
        }
    }

    private func removeContents(of directory: URL) throws {
        let contents = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        for url in contents {
            try fileManager.removeItem(at: url)
        }
    }

    private func appSupportRoot() -> URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        return appSupport.appendingPathComponent("wPSPsync", isDirectory: true)
    }
}

struct BackupArchive: Identifiable, Hashable {
    var id: URL { url }
    let url: URL
    let modifiedAt: Date

    var title: String {
        url.deletingPathExtension().lastPathComponent
    }
}

protocol ProcessRunning {
    func run(executableURL: URL, arguments: [String]) throws
}

struct SystemProcessRunner: ProcessRunning {
    func run(executableURL: URL, arguments: [String]) throws {
        let process = Process()
        process.executableURL = executableURL
        process.arguments = arguments

        let errorPipe = Pipe()
        process.standardError = errorPipe

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            let data = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let message = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
            throw BackupStoreError.processFailed(message?.isEmpty == false ? message! : String(localized: "Archive command failed."))
        }
    }
}

enum BackupStoreError: LocalizedError {
    case processFailed(String)

    var errorDescription: String? {
        switch self {
        case .processFailed(let message):
            return message
        }
    }
}
