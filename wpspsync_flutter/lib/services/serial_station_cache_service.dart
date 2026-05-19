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


import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

// Persistent disk cache for SerialStation API responses.
// Mirrors SerialStationCacheStore.swift behavior.
class SerialStationCacheService {
  Future<Map<String, GameMetadata>> load() async {
    final file = await _cacheFile();
    if (!await file.exists()) return {};

    try {
      final contents = await file.readAsString();
      final Map<String, dynamic> raw = jsonDecode(contents);
      return raw.map((key, value) =>
          MapEntry(key.toUpperCase(), GameMetadata.fromJson(value)));
    } catch (_) {
      return {};
    }
  }

  Future<void> save(Map<String, GameMetadata> cache) async {
    final file = await _cacheFile();
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }

    final normalized = {
      for (var entry in cache.entries) entry.key.toUpperCase(): entry.value.toJson()
    };

    final encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(normalized));
  }

  Future<File> _cacheFile() async {
    final caches = await getApplicationCacheDirectory();
    return File(p.join(caches.path, 'serialstation-metadata.json'));
  }
}