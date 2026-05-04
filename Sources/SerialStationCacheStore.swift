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

struct SerialStationCacheStore {
    private let fileManager: FileManager
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let customCacheURL: URL?

    init(fileManager: FileManager = .default, cacheURL: URL? = nil) {
        self.fileManager = fileManager
        self.customCacheURL = cacheURL
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    func load() throws -> [String: GameMetadata] {
        let url = cacheURL()
        guard fileManager.fileExists(atPath: url.path) else {
            return [:]
        }
        let data = try Data(contentsOf: url)
        let cache = try decoder.decode([String: GameMetadata].self, from: data)
        return cache.reduce(into: [:]) { result, item in
            result[item.key.uppercased()] = item.value
        }
    }

    func save(_ cache: [String: GameMetadata]) throws {
        let url = cacheURL()
        try fileManager.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let normalizedCache = cache.reduce(into: [:]) { result, item in
            result[item.key.uppercased()] = item.value
        }
        let data = try encoder.encode(normalizedCache)
        try data.write(to: url, options: [.atomic])
    }

    private func cacheURL() -> URL {
        if let customCacheURL {
            return customCacheURL
        }
        let caches = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first ?? fileManager.temporaryDirectory
        return caches
            .appendingPathComponent("wPSPsync", isDirectory: true)
            .appendingPathComponent("serialstation-metadata.json")
    }
}
