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


import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/models.dart';

class ScannerService {
  // Discovers potential PSP storage roots by checking mounted drives/volumes
  Future<List<VolumeCandidate>> discoverVolumeCandidates() async {
    List<Directory> roots = [];

    if (Platform.isWindows) {
      // On Windows, check all logical drives (A:\ to Z:\)
      for (var letter in List.generate(26, (i) => String.fromCharCode(65 + i))) {
        var drive = Directory('$letter:\\');
        try {
          if (await drive.exists()) {
            roots.add(drive);
          }
        } catch (_) {
          // Ignore inaccessible drives
        }
      }
    } else if (Platform.isMacOS) {
      // On macOS, check the /Volumes directory
      var volumesDir = Directory('/Volumes');
      if (await volumesDir.exists()) {
        try {
          var entities = await volumesDir.list().toList();
          for (var entity in entities) {
            if (entity is Directory) {
              roots.add(entity);
            }
          }
        } catch (_) {}
      }
    } else if (Platform.isLinux) {
      // On Linux, common mount points are /media, /run/media and /mnt
      final user = Platform.environment['USER'] ?? Platform.environment['LOGNAME'] ?? '';
      for (var path in [
        if (user.isNotEmpty) '/media/$user',
        if (user.isNotEmpty) '/run/media/$user',
        '/media',
        '/run/media',
        '/mnt'
      ]) {
        var dir = Directory(path);
        if (await dir.exists()) {
          try {
            var entities = await dir.list().toList();
            for (var entity in entities) {
              if (entity is Directory) {
                roots.add(entity);
              }
            }
          } catch (_) {}
        }
      }
    }

    List<VolumeCandidate> candidates = [];
    for (var root in roots) {
      var pspRoot = await resolvePSPStorageRoot(root);
      if (pspRoot != null) {
        var saveDataPath = p.join(pspRoot.path, 'PSP', 'SAVEDATA');
        var name = p.basename(pspRoot.path);
        if (name.isEmpty) name = pspRoot.path; // Fallback for drive roots

        candidates.add(VolumeCandidate(
          name: name,
          rootUri: Uri.file(pspRoot.path),
          saveDataUri: Uri.file(saveDataPath),
        ));
      }
    }

    // Sort by name alphabetically
    candidates.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return candidates;
  }

  // Scans for PSP saves in a given storage root
  Future<List<SaveGame>> scanPSPSaves(Directory storageRoot, GameCatalog catalog) async {
    var pspRoot = await resolvePSPStorageRoot(storageRoot);
    if (pspRoot == null) return [];

    var saveDataPath = p.join(pspRoot.path, 'PSP', 'SAVEDATA');
    return scanSaveFolders(Directory(saveDataPath), catalog);
  }

  // Identifies if a directory is a valid PSP storage root
  Future<Directory?> resolvePSPStorageRoot(Directory dir) async {
    try {
      // 1. Direct check (fastest)
      if (await Directory(p.join(dir.path, 'PSP', 'SAVEDATA')).exists()) {
        return dir;
      }

      // 2. Case-insensitive check for Linux/macOS
      var entities = await dir.list().toList();
      for (var entity in entities) {
        if (entity is Directory && p.basename(entity.path).toUpperCase() == 'PSP') {
          var pspEntities = await entity.list().toList();
          for (var pspEntity in pspEntities) {
            if (pspEntity is Directory && p.basename(pspEntity.path).toUpperCase() == 'SAVEDATA') {
              return dir;
            }
          }
        }
      }

      // 3. Check if the directory itself is "PSP" and contains "SAVEDATA"
      if (p.basename(dir.path).toUpperCase() == 'PSP') {
        var pspEntities = await dir.list().toList();
        for (var pspEntity in pspEntities) {
          if (pspEntity is Directory && p.basename(pspEntity.path).toUpperCase() == 'SAVEDATA') {
            return dir.parent;
          }
        }
      }

      // 4. Check if the directory itself is "SAVEDATA" and is inside "PSP"
      if (p.basename(dir.path).toUpperCase() == 'SAVEDATA' &&
          p.basename(dir.parent.path).toUpperCase() == 'PSP') {
        return dir.parent.parent;
      }
    } catch (_) {}

    return null;
  }

  // Scans for saves in a sync root (which might or might not have a PSP structure)
  Future<List<SaveGame>> scanSyncSaves(Directory syncRoot, GameCatalog catalog) async {
    var normalizedRoot = await resolveSyncRoot(syncRoot);
    var saveDataDir = Directory(p.join(normalizedRoot.path, 'PSP', 'SAVEDATA'));
    
    if (await saveDataDir.exists()) {
      return scanSaveFolders(saveDataDir, catalog);
    }
    return scanSaveFolders(normalizedRoot, catalog);
  }

  // Normalizes a sync root by going up to the parent if inside a PSP structure
  Future<Directory> resolveSyncRoot(Directory dir) async {
    if (p.basename(dir.path).toUpperCase() == 'PSP' &&
        await Directory(p.join(dir.path, 'SAVEDATA')).exists()) {
      return dir.parent;
    }

    if (p.basename(dir.path).toUpperCase() == 'SAVEDATA' &&
        p.basename(dir.parent.path).toUpperCase() == 'PSP') {
      return dir.parent.parent;
    }

    return dir;
  }

  // Recursively scans a directory for save folders
  Future<List<SaveGame>> scanSaveFolders(Directory root, GameCatalog catalog) async {
    if (!await root.exists()) return [];

    List<SaveGame> saves = [];
    try {
      var entities = await root.list().toList();
      for (var entity in entities) {
        if (entity is Directory) {
          // Skip hidden directories (starts with .)
          if (p.basename(entity.path).startsWith('.')) continue;

          // Optimization/Security: Only consider it a save if it contains a PARAM.SFO
          // This prevents system folders like 'lib' or 'data' from being listed.
          var sfoFile = File(p.join(entity.path, 'PARAM.SFO'));
          var sfoFileLower = File(p.join(entity.path, 'param.sfo'));
          if (!await sfoFile.exists() && !await sfoFileLower.exists()) {
            continue;
          }

          var save = await _makeSaveGame(entity, catalog);
          saves.add(save);
        }
      }
    } catch (_) {}

    // Sort by display title alphabetically
    saves.sort((a, b) => a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));
    return saves;
  }

  // Creates a SaveGame model from a directory
  Future<SaveGame> _makeSaveGame(Directory dir, GameCatalog catalog) async {
    var modifiedAt = await _recursiveModifiedDate(dir);
    var size = await _recursiveSize(dir);
    
    // Look for common icon files
    Uri? iconUrl;
    for (var iconName in ['ICON0.PNG', 'ICON0.png', 'PIC1.PNG', 'PIC1.png']) {
      var iconFile = File(p.join(dir.path, iconName));
      if (await iconFile.exists()) {
        iconUrl = Uri.file(iconFile.path);
        break;
      }
    }

    var folderName = p.basename(dir.path);
    return SaveGame(
      folderName: folderName,
      rootUri: Uri.file(dir.path),
      modifiedAt: modifiedAt,
      size: size,
      game: catalog.metadata(folderName),
      iconUrl: iconUrl,
    );
  }

  // Calculates the latest modification date among all files in a directory
  Future<DateTime> _recursiveModifiedDate(Directory dir) async {
    DateTime latest = (await dir.stat()).modified;
    
    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          var mod = (await entity.stat()).modified;
          if (mod.isAfter(latest)) {
            latest = mod;
          }
        }
      }
    } catch (_) {}
    
    return latest;
  }

  // Calculates total size of all files in a directory
  Future<int> _recursiveSize(Directory dir) async {
    int total = 0;
    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          total += (await entity.stat()).size;
        }
      }
    } catch (_) {}
    return total;
  }
}