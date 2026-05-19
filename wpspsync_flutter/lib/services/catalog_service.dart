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
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/models.dart';

class CatalogService {
  // Loads the game catalog from the user directory or fallback to bundled asset
  Future<GameCatalog> loadCatalog() async {
    final userFile = await _userCatalogFile();
    
    if (await userFile.exists()) {
      try {
        return await _decodeCatalogFromFile(userFile);
      } catch (_) {
        // Fallback if user file is corrupted
      }
    }

    try {
      // Fallback to bundled sample catalog
      final jsonString = await rootBundle.loadString('assets/psp-games.sample.json');
      return _decodeCatalogFromString(jsonString);
    } catch (_) {
      return GameCatalog.empty;
    }
  }

  // Imports a catalog from an external file and saves it to the user directory
  Future<GameCatalog> importCatalog(File file) async {
    final catalog = await _decodeCatalogFromFile(file);
    final destination = await _userCatalogFile();
    
    if (!await destination.parent.exists()) {
      await destination.parent.create(recursive: true);
    }

    final List<Map<String, dynamic>> jsonList = catalog.games.values.map((m) => m.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await destination.writeAsString(jsonString);
    
    return catalog;
  }

  // Helper to decode catalog from a File
  Future<GameCatalog> _decodeCatalogFromFile(File file) async {
    final jsonString = await file.readAsString();
    return _decodeCatalogFromString(jsonString);
  }

  // Helper to decode catalog from a JSON string
  GameCatalog _decodeCatalogFromString(String jsonString) {
    final List<dynamic> entries = jsonDecode(jsonString);
    final Map<String, GameMetadata> games = {};
    
    for (var entry in entries) {
      final metadata = GameMetadata.fromJson(entry);
      games[metadata.id.toUpperCase()] = metadata;
    }
    
    return GameCatalog(games: games);
  }

  // Gets the path to the user's persisted catalog file
  Future<File> _userCatalogFile() async {
    final appSupport = await getApplicationSupportDirectory();
    return File(p.join(appSupport.path, 'psp-games.json'));
  }
}