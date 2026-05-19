import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/models.dart';

class SyncService {
  // Compares saves from PSP and Sync root to create a list of comparisons
  List<SaveComparison> compare({
    required List<SaveGame> pspSaves,
    required List<SaveGame> syncSaves,
  }) {
    final Map<String, SaveGame> pspByFolder = {
      for (var s in pspSaves) s.folderName: s
    };
    final Map<String, SaveGame> syncByFolder = {
      for (var s in syncSaves) s.folderName: s
    };

    final Set<String> allFolders = {...pspByFolder.keys, ...syncByFolder.keys};

    final List<SaveComparison> comparisons = allFolders.map((folder) {
      return SaveComparison(
        folderName: folder,
        psp: pspByFolder[folder],
        sync: syncByFolder[folder],
      );
    }).toList();

    // Sort by display title alphabetically
    comparisons.sort((a, b) => 
      a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));
    
    return comparisons;
  }

  // Executes the sync process for the selected rows
  Future<int> syncLatest({
    required List<SaveComparison> rows,
    required Directory syncRoot,
    required Directory pspRoot,
  }) async {
    int syncedCount = 0;

    for (var row in rows) {
      switch (row.state) {
        case SaveState.pspNewer:
        case SaveState.onlyPSP:
          if (row.psp != null) {
            final source = Directory(row.psp!.rootUri.toFilePath());
            final destination = _saveDestination(row.folderName, syncRoot);
            await _replaceDirectory(source, destination);
            syncedCount++;
          }
          break;
        case SaveState.syncNewer:
        case SaveState.onlySync:
          if (row.sync != null) {
            final source = Directory(row.sync!.rootUri.toFilePath());
            final destination = _pspDestination(row.folderName, pspRoot);
            await _replaceDirectory(source, destination);
            syncedCount++;
          }
          break;
        case SaveState.same:
          continue;
      }
    }

    return syncedCount;
  }

  // Determines the destination path on the PSP side
  Directory _pspDestination(String folderName, Directory pspRoot) {
    final root = _storageRoot(pspRoot);
    return Directory(p.join(root.path, 'PSP', 'SAVEDATA', folderName));
  }

  // Determines the destination path on the sync side
  Directory _saveDestination(String folderName, Directory syncRoot) {
    final normalizedRoot = _storageRoot(syncRoot);
    final pspStyleRoot = Directory(p.join(normalizedRoot.path, 'PSP', 'SAVEDATA'));
    
    // Check if we should use the PSP structure or flat structure
    if (pspStyleRoot.existsSync() || !_directoryContainsSaveFolders(normalizedRoot)) {
      return Directory(p.join(pspStyleRoot.path, folderName));
    }
    return Directory(p.join(normalizedRoot.path, folderName));
  }

  // Finds the base root (removing PSP/SAVEDATA suffix if present)
  Directory _storageRoot(Directory dir) {
    final path = dir.path;
    final parts = p.split(path);
    
    if (parts.isNotEmpty && parts.last.toUpperCase() == 'PSP') {
      final saveDataDir = Directory(p.join(path, 'SAVEDATA'));
      if (saveDataDir.existsSync()) {
        return dir.parent;
      }
    }

    if (parts.length >= 2 && 
        parts.last.toUpperCase() == 'SAVEDATA' && 
        parts[parts.length - 2].toUpperCase() == 'PSP') {
      return dir.parent.parent;
    }

    return dir;
  }

  // Replaces a directory by deleting the destination and copying the source
  Future<void> _replaceDirectory(Directory source, Directory destination) async {
    if (await destination.exists()) {
      await destination.delete(recursive: true);
    }
    await destination.create(recursive: true);
    await _copyDirectory(source, destination);
  }

  // Helper to recursively copy a directory
  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await for (var entity in source.list(recursive: false)) {
      if (entity is Directory) {
        final newDir = Directory(p.join(destination.path, p.basename(entity.path)));
        await newDir.create();
        await _copyDirectory(entity, newDir);
      } else if (entity is File) {
        await entity.copy(p.join(destination.path, p.basename(entity.path)));
      }
    }
  }

  // Checks if a directory contains any folder that looks like a PSP game ID
  bool _directoryContainsSaveFolders(Directory dir) {
    if (!dir.existsSync()) return false;
    try {
      final contents = dir.listSync();
      return contents.any((entity) => 
        entity is Directory && GameIDParser.parse(p.basename(entity.path)) != null
      );
    } catch (_) {
      return false;
    }
  }
}
