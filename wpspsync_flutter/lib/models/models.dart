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


class VolumeCandidate {
  final String name;
  final Uri rootUri;
  final Uri saveDataUri;

  VolumeCandidate({
    required this.name,
    required this.rootUri,
    required this.saveDataUri,
  });

  String get id => rootUri.toString();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VolumeCandidate &&
          runtimeType == other.runtimeType &&
          rootUri == other.rootUri;

  @override
  int get hashCode => rootUri.hashCode;
}

class GameMetadata {
  final String id;
  final String title;
  final String? region;
  final String? publisher;
  final Uri? coverUrl;

  GameMetadata({
    required this.id,
    required this.title,
    this.region,
    this.publisher,
    this.coverUrl,
  });

  factory GameMetadata.fromJson(Map<String, dynamic> json) {
    return GameMetadata(
      id: json['id'],
      title: json['title'],
      region: json['region'],
      publisher: json['publisher'],
      coverUrl: json['coverURL'] != null ? Uri.parse(json['coverURL']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'region': region,
    'publisher': publisher,
    'coverURL': coverUrl?.toString(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameMetadata &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SaveGame {
  final String folderName;
  final Uri rootUri;
  final DateTime modifiedAt;
  final int size;
  final GameMetadata? game;
  final Uri? iconUrl;

  SaveGame({
    required this.folderName,
    required this.rootUri,
    required this.modifiedAt,
    required this.size,
    this.game,
    this.iconUrl,
  });

  String get id => folderName;

  String get gameId => GameIDParser.parse(folderName) ?? folderName;

  String get displayTitle => game?.title ?? folderName;

  SaveGame enriched(GameMetadata? metadata) {
    if (metadata == null) return this;
    return SaveGame(
      folderName: folderName,
      rootUri: rootUri,
      modifiedAt: modifiedAt,
      size: size,
      game: metadata,
      iconUrl: iconUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaveGame &&
          runtimeType == other.runtimeType &&
          folderName == other.folderName;

  @override
  int get hashCode => folderName.hashCode;
}

enum SaveState {
  same,
  pspNewer,
  syncNewer,
  onlyPSP,
  onlySync;

  String get title {
    switch (this) {
      case SaveState.same:
        return "Synced";
      case SaveState.pspNewer:
        return "PSP newer";
      case SaveState.syncNewer:
        return "Sync newer";
      case SaveState.onlyPSP:
        return "Only on PSP";
      case SaveState.onlySync:
        return "Only in sync";
    }
  }
}

class SaveComparison {
  final String folderName;
  final SaveGame? psp;
  final SaveGame? sync;

  SaveComparison({
    required this.folderName,
    this.psp,
    this.sync,
  });

  String get id => folderName;

  String get displayTitle => psp?.displayTitle ?? sync?.displayTitle ?? folderName;

  String get gameId => psp?.gameId ?? sync?.gameId ?? folderName;

  Uri? get iconUrl => psp?.iconUrl ?? sync?.iconUrl;

  Uri? get coverUrl => psp?.game?.coverUrl ?? sync?.game?.coverUrl;

  SaveState get state {
    if (psp != null && sync != null) {
      final diff = psp!.modifiedAt.difference(sync!.modifiedAt).inSeconds.abs();
      // Allow a small window (2 seconds) for FAT file system timestamp differences
      if (diff <= 2) {
        return SaveState.same;
      }
      return psp!.modifiedAt.isAfter(sync!.modifiedAt)
          ? SaveState.pspNewer
          : SaveState.syncNewer;
    } else if (psp != null) {
      return SaveState.onlyPSP;
    } else if (sync != null) {
      return SaveState.onlySync;
    } else {
      return SaveState.same;
    }
  }

  DateTime? get latestModifiedAt {
    if (psp != null && sync != null) {
      return psp!.modifiedAt.isAfter(sync!.modifiedAt) ? psp!.modifiedAt : sync!.modifiedAt;
    }
    return psp?.modifiedAt ?? sync?.modifiedAt;
  }

  int get size => psp != null && sync != null
      ? (psp!.size > sync!.size ? psp!.size : sync!.size)
      : (psp?.size ?? sync?.size ?? 0);
}

class GameCatalog {
  final Map<String, GameMetadata> games;

  GameCatalog({required this.games});

  static final empty = GameCatalog(games: {});

  GameMetadata? metadata(String folderName) {
    final id = GameIDParser.parse(folderName);
    if (id == null) {
      return games[folderName.toUpperCase()];
    }
    return games[id];
  }
}

class GameIDParser {
  static String? parse(String folderName) {
    final regex = RegExp(r'U[A-Z]{3}[0-9]{5}');
    final match = regex.firstMatch(folderName.toUpperCase());
    return match?.group(0);
  }
}