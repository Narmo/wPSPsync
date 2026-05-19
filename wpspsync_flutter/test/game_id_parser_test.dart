//
// Copyright (c) 2026 Nikita Denin <nik@brite-apps.com>
// Copyright (c) 2026 OniMock <onimock@gmail.com>
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


import 'package:flutter_test/flutter_test.dart';
import 'package:wpspsync_flutter/models/models.dart';

void main() {
  group('GameIDParser', () {
    test('parses Game ID from save folder', () {
      expect(GameIDParser.parse('ULUS10566DATA00'), equals('ULUS10566'));
      expect(GameIDParser.parse('savedata_ules00151_profile'), equals('ULES00151'));
    });

    test('returns null when no Game ID exists', () {
      expect(GameIDParser.parse('PROFILE_BACKUP'), isNull);
    });
  });
}