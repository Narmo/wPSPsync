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
