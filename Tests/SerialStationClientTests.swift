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

final class SerialStationClientTests: XCTestCase {
    func testDecodesTitleIDResponse() throws {
        let data = Data("""
        {
          "title_id": "ULUS10512",
          "title_id_type": "ULUS",
          "title_id_number": "10512",
          "name": "Shin Megami Tensei: Persona 3 Portable",
          "content_type": "Game",
          "systems": ["PSP"],
          "games": [
            {
              "id": "7d980ec4-f5ed-41b2-bc39-f60adcdac9ce",
              "name": "Shin Megami Tensei: Persona 3 Portable"
            }
          ]
        }
        """.utf8)

        let decoded = try JSONDecoder().decode(SerialStationTitleID.self, from: data)

        XCTAssertEqual(decoded.titleID, "ULUS10512")
        XCTAssertEqual(decoded.bestName, "Shin Megami Tensei: Persona 3 Portable")
    }

    func testDecodesTMDBIconResponse() throws {
        let data = Data("""
        {
          "names": [
            {
              "language": "en-US",
              "name": "Shin Megami Tensei: Persona 3 Portable"
            }
          ],
          "s_names": [],
          "icons": [
            {
              "type": "icon",
              "language": "en-US",
              "url": "https://serialstation.com/media/icon.png"
            }
          ],
          "parental_levels": [],
          "revision": 1,
          "title_id": "ULUS10512",
          "console": ["PSP"],
          "parental_level": 5,
          "name": "P3P"
        }
        """.utf8)

        let decoded = try JSONDecoder().decode(SerialStationTMDBItem.self, from: data)

        XCTAssertEqual(decoded.titleID, "ULUS10512")
        XCTAssertEqual(decoded.bestName, "Shin Megami Tensei: Persona 3 Portable")
        XCTAssertEqual(decoded.bestIconURL?.absoluteString, "https://serialstation.com/media/icon.png")
    }
}
