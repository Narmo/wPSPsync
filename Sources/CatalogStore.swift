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

struct CatalogStore {
    private let fileManager = FileManager.default
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func loadCatalog() throws -> GameCatalog {
        if let userURL = userCatalogURL(), fileManager.fileExists(atPath: userURL.path) {
            return try decodeCatalog(from: userURL)
        }
        guard let bundledURL = Bundle.appResources.url(forResource: "psp-games.sample", withExtension: "json") else {
            return .empty
        }
        return try decodeCatalog(from: bundledURL)
    }

    func importCatalog(from url: URL) throws -> GameCatalog {
        let catalog = try decodeCatalog(from: url)
        guard let destination = userCatalogURL() else {
            return catalog
        }
        try fileManager.createDirectory(at: destination.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try encoder.encode(catalog)
        try data.write(to: destination, options: [.atomic])
        return catalog
    }

    private func decodeCatalog(from url: URL) throws -> GameCatalog {
        let data = try Data(contentsOf: url)
        let entries = try decoder.decode([GameMetadata].self, from: data)
        return GameCatalog(games: Dictionary(uniqueKeysWithValues: entries.map { ($0.id.uppercased(), $0) }))
    }

    private func userCatalogURL() -> URL? {
        appSupportRoot()?.appendingPathComponent("psp-games.json")
    }

    private func appSupportRoot() -> URL? {
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        return appSupport.appendingPathComponent("wPSPsync", isDirectory: true)
    }
}

extension Bundle {
    static var appResources: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return .main
        #endif
    }
}
