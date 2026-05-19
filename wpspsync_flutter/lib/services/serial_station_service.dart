import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class SerialStationService {
  static const String baseURL = "https://api.serialstation.com";
  final http.Client _client;

  SerialStationService({http.Client? client}) : _client = client ?? http.Client();

  // Fetches metadata for a given PSP title ID
  Future<GameMetadata?> fetchMetadata(String titleId) async {
    final results = await Future.wait([
      _fetchTitleID(titleId).catchError((_) => null),
      _fetchTMDB(titleId).catchError((_) => null),
    ]);

    final titleIDResponse = results[0] as SerialStationTitleID?;
    final tmdbResponse = results[1] as SerialStationTMDBItem?;

    if (titleIDResponse == null && tmdbResponse == null) {
      return null;
    }

    final title = tmdbResponse?.bestName ?? titleIDResponse?.bestName ?? titleId;
    final coverUrl = tmdbResponse?.bestIconUrl;

    return GameMetadata(
      id: titleId.toUpperCase(),
      title: title,
      coverUrl: coverUrl,
    );
  }

  // Fetches basic title ID information
  Future<SerialStationTitleID?> _fetchTitleID(String titleId) async {
    final url = Uri.parse("$baseURL/v1/title-ids/${titleId.toUpperCase()}");
    try {
      final response = await _get(url);
      return SerialStationTitleID.fromJson(jsonDecode(response.body));
    } catch (_) {
      return null;
    }
  }

  // Fetches TMDB enrichment data (icons and translated names)
  Future<SerialStationTMDBItem?> _fetchTMDB(String titleId) async {
    final url = Uri.parse("$baseURL/v1/tmdb/${titleId.toUpperCase()}");
    try {
      final response = await _get(url);
      return SerialStationTMDBItem.fromJson(jsonDecode(response.body));
    } catch (_) {
      return null;
    }
  }

  // Helper to perform GET requests with timeout and common headers
  Future<http.Response> _get(Uri url) async {
    final response = await _client.get(
      url,
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("SerialStation returned HTTP ${response.statusCode}");
    }
    return response;
  }
}

// Internal models for parsing SerialStation responses

class SerialStationTitleID {
  final String titleId;
  final String name;
  final List<String> systems;
  final List<SerialStationTitleIDGame> games;

  SerialStationTitleID({
    required this.titleId,
    required this.name,
    required this.systems,
    required this.games,
  });

  String get bestName => games.isNotEmpty ? games.first.name : name;

  factory SerialStationTitleID.fromJson(Map<String, dynamic> json) {
    return SerialStationTitleID(
      titleId: json['title_id'],
      name: json['name'],
      systems: List<String>.from(json['systems']),
      games: (json['games'] as List)
          .map((i) => SerialStationTitleIDGame.fromJson(i))
          .toList(),
    );
  }
}

class SerialStationTitleIDGame {
  final String id;
  final String name;

  SerialStationTitleIDGame({required this.id, required this.name});

  factory SerialStationTitleIDGame.fromJson(Map<String, dynamic> json) {
    return SerialStationTitleIDGame(id: json['id'], name: json['name']);
  }
}

class SerialStationTMDBItem {
  final String titleId;
  final String name;
  final List<SerialStationTMDBIcon> icons;
  final List<SerialStationTMDBName> names;

  SerialStationTMDBItem({
    required this.titleId,
    required this.name,
    required this.icons,
    required this.names,
  });

  String get bestName {
    try {
      return names.firstWhere((n) => n.language.toLowerCase().startsWith('en')).name;
    } catch (_) {
      return name;
    }
  }

  Uri? get bestIconUrl {
    try {
      final icon = icons.firstWhere((i) => i.type.toLowerCase() == 'icon');
      return Uri.parse(icon.url);
    } catch (_) {
      if (icons.isNotEmpty) {
        return Uri.parse(icons.first.url);
      }
      return null;
    }
  }

  factory SerialStationTMDBItem.fromJson(Map<String, dynamic> json) {
    return SerialStationTMDBItem(
      titleId: json['title_id'],
      name: json['name'],
      icons: (json['icons'] as List)
          .map((i) => SerialStationTMDBIcon.fromJson(i))
          .toList(),
      names: (json['names'] as List)
          .map((i) => SerialStationTMDBName.fromJson(i))
          .toList(),
    );
  }
}

class SerialStationTMDBIcon {
  final String type;
  final String url;

  SerialStationTMDBIcon({required this.type, required this.url});

  factory SerialStationTMDBIcon.fromJson(Map<String, dynamic> json) {
    return SerialStationTMDBIcon(type: json['type'], url: json['url']);
  }
}

class SerialStationTMDBName {
  final String language;
  final String name;

  SerialStationTMDBName({required this.language, required this.name});

  factory SerialStationTMDBName.fromJson(Map<String, dynamic> json) {
    return SerialStationTMDBName(language: json['language'], name: json['name']);
  }
}
