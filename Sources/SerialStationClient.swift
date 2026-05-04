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

struct SerialStationClient {
    private let baseURL = URL(string: "https://api.serialstation.com")!
    private let session: URLSession
    private let decoder = JSONDecoder()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func metadata(for titleID: String) async throws -> GameMetadata? {
        async let titleIDResult = fetchTitleID(titleID)
        async let tmdbResult = fetchTMDB(titleID)

        let titleIDResponse = try? await titleIDResult
        let tmdbResponse = try? await tmdbResult

        guard titleIDResponse != nil || tmdbResponse != nil else {
            return nil
        }

        let title = tmdbResponse?.bestName ?? titleIDResponse?.bestName ?? titleID
        let coverURL = tmdbResponse?.bestIconURL

        return GameMetadata(
            id: titleID.uppercased(),
            title: title,
            region: nil,
            publisher: nil,
            coverURL: coverURL
        )
    }

    func fetchTitleID(_ titleID: String) async throws -> SerialStationTitleID {
        let url = baseURL.appending(path: "v1/title-ids/\(titleID.uppercased())")
        let data = try await fetch(url)
        return try decoder.decode(SerialStationTitleID.self, from: data)
    }

    func fetchTMDB(_ titleID: String) async throws -> SerialStationTMDBItem {
        let url = baseURL.appending(path: "v1/tmdb/\(titleID.uppercased())")
        let data = try await fetch(url)
        return try decoder.decode(SerialStationTMDBItem.self, from: data)
    }

    private func fetch(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.timeoutInterval = 12
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SerialStationError.invalidResponse
        }
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw SerialStationError.httpStatus(httpResponse.statusCode)
        }
        return data
    }
}

enum SerialStationError: LocalizedError {
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return String(localized: "SerialStation returned an invalid response.")
        case .httpStatus(let status):
            return String(localized: "SerialStation returned HTTP \(status).")
        }
    }
}

struct SerialStationTitleID: Decodable {
    let titleID: String
    let name: String
    let systems: [String]
    let games: [SerialStationTitleIDGame]

    var bestName: String {
        games.first?.name ?? name
    }

    enum CodingKeys: String, CodingKey {
        case titleID = "title_id"
        case name
        case systems
        case games
    }
}

struct SerialStationTitleIDGame: Decodable {
    let id: String
    let name: String
}

struct SerialStationTMDBItem: Decodable {
    let titleID: String
    let name: String
    let icons: [SerialStationTMDBIcon]
    let names: [SerialStationTMDBName]

    var bestName: String {
        names.first(where: { $0.language.lowercased().hasPrefix("en") })?.name ?? name
    }

    var bestIconURL: URL? {
        icons.first(where: { $0.type.lowercased() == "icon" }).flatMap { URL(string: $0.url) }
            ?? icons.first.flatMap { URL(string: $0.url) }
    }

    enum CodingKeys: String, CodingKey {
        case titleID = "title_id"
        case name
        case icons
        case names
    }
}

struct SerialStationTMDBIcon: Decodable {
    let type: String
    let url: String
}

struct SerialStationTMDBName: Decodable {
    let language: String
    let name: String
}
