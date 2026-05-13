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
