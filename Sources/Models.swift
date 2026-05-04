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

struct VolumeCandidate: Identifiable, Hashable {
    var id: URL { rootURL }
    let name: String
    let rootURL: URL
    let saveDataURL: URL
}

struct SaveGame: Identifiable, Hashable {
    var id: String { folderName }
    let folderName: String
    let rootURL: URL
    let modifiedAt: Date
    let size: Int64
    let game: GameMetadata?
    let iconURL: URL?

    var gameID: String {
        GameIDParser.parse(from: folderName) ?? folderName
    }

    var displayTitle: String {
        game?.title ?? folderName
    }

    func enriched(with metadata: GameMetadata?) -> SaveGame {
        guard let metadata else {
            return self
        }
        return SaveGame(
            folderName: folderName,
            rootURL: rootURL,
            modifiedAt: modifiedAt,
            size: size,
            game: metadata,
            iconURL: iconURL
        )
    }
}

struct SaveComparison: Identifiable, Hashable {
    var id: String { folderName }
    let folderName: String
    let psp: SaveGame?
    let sync: SaveGame?

    var displayTitle: String {
        psp?.displayTitle ?? sync?.displayTitle ?? folderName
    }

    var gameID: String {
        psp?.gameID ?? sync?.gameID ?? folderName
    }

    var iconURL: URL? {
        psp?.iconURL ?? sync?.iconURL
    }

    var coverURL: URL? {
        psp?.game?.coverURL ?? sync?.game?.coverURL
    }

    var state: SaveState {
        switch (psp, sync) {
        case (.some(let psp), .some(let sync)):
            if abs(psp.modifiedAt.timeIntervalSince(sync.modifiedAt)) < 1 {
                return .same
            }
            return psp.modifiedAt > sync.modifiedAt ? .pspNewer : .syncNewer
        case (.some, .none):
            return .onlyPSP
        case (.none, .some):
            return .onlySync
        case (.none, .none):
            return .same
        }
    }

    var latestModifiedAt: Date? {
        [psp?.modifiedAt, sync?.modifiedAt].compactMap { $0 }.max()
    }

    var size: Int64 {
        max(psp?.size ?? 0, sync?.size ?? 0)
    }

}

enum SaveState: String {
    case same
    case pspNewer
    case syncNewer
    case onlyPSP
    case onlySync

    var title: String {
        switch self {
        case .same:
            return String(localized: "Synced")
        case .pspNewer:
            return String(localized: "PSP newer")
        case .syncNewer:
            return String(localized: "Sync newer")
        case .onlyPSP:
            return String(localized: "Only on PSP")
        case .onlySync:
            return String(localized: "Only in sync")
        }
    }
}

struct GameCatalog: Codable, Equatable {
    let games: [String: GameMetadata]

    static let empty = GameCatalog(games: [:])

    func metadata(for folderName: String) -> GameMetadata? {
        guard let id = GameIDParser.parse(from: folderName) else {
            return games[folderName.uppercased()]
        }
        return games[id]
    }
}

struct GameMetadata: Codable, Equatable, Hashable {
    let id: String
    let title: String
    let region: String?
    let publisher: String?
    let coverURL: URL?
}

enum GameIDParser {
    static func parse(from folderName: String) -> String? {
        let uppercased = folderName.uppercased()
        let pattern = #"U[A-Z]{3}[0-9]{5}"#
        guard let range = uppercased.range(of: pattern, options: .regularExpression) else {
            return nil
        }
        return String(uppercased[range])
    }
}
