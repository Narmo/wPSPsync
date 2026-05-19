import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class BackupArchive {
  final File file;
  final DateTime modifiedAt;

  BackupArchive({required this.file, required this.modifiedAt});

  String get id => file.path;
  String get title => p.basenameWithoutExtension(file.path);
}

class BackupService {
  static const int maximumBackupCount = 5;
  final Directory? customBackupsDirectory;

  BackupService({this.customBackupsDirectory});

  // Gets the default backups directory using platform-specific application support path
  Future<Directory> getBackupsDirectory() async {
    if (customBackupsDirectory != null) {
      if (!await customBackupsDirectory!.exists()) {
        await customBackupsDirectory!.create(recursive: true);
      }
      return customBackupsDirectory!;
    }
    final appSupport = await getApplicationSupportDirectory();
    final backupDir = Directory(p.join(appSupport.path, 'Backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  // Creates a ZIP backup of the specified sync root
  Future<File> createBackup(Directory syncRoot, {File? preservedBackup}) async {
    if (!await syncRoot.exists()) {
      await syncRoot.create(recursive: true);
    }
    
    final backupsDir = await getBackupsDirectory();
    final destination = await _nextBackupFile(backupsDir);

    // Create zip archive manually for precise control over paths and streams
    final archive = Archive();
    
    // Add all files from sync root to the archive
    if (await syncRoot.exists()) {
      final files = await syncRoot.list(recursive: true).toList();
      for (var entity in files) {
        if (entity is File) {
          final relativePath = p.relative(entity.path, from: syncRoot.path).replaceAll('\\', '/');
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));
        }
      }
    }
    
    final zipData = ZipEncoder().encode(archive);
    await destination.writeAsBytes(zipData);

    await pruneBackups(preservedBackup: preservedBackup);
    return destination;
  }

  // Lists all available backup archives sorted by date (newest first)
  Future<List<BackupArchive>> listBackups() async {
    final backupsDir = await getBackupsDirectory();
    if (!await backupsDir.exists()) return [];

    final List<BackupArchive> backups = [];
    try {
      final entities = await backupsDir.list().toList();
      for (var entity in entities) {
        if (entity is File && p.extension(entity.path).toLowerCase() == '.zip') {
          final stat = await entity.stat();
          backups.add(BackupArchive(file: entity, modifiedAt: stat.modified));
        }
      }
    } catch (_) {}

    // Sort by filename descending (matching the original Swift logic)
    backups.sort((a, b) => p.basename(b.file.path).compareTo(p.basename(a.file.path)));
    return backups;
  }

  // Restores a backup by unzipping it to the specified sync root
  Future<void> restoreBackup(File backupFile, Directory syncRoot) async {
    if (!await syncRoot.exists()) {
      await syncRoot.create(recursive: true);
    } else {
      // Clear existing contents before restoration
      try {
        final contents = await syncRoot.list().toList();
        for (var entity in contents) {
          await entity.delete(recursive: true);
        }
      } catch (_) {}
    }

    // Extract ZIP archive
    final bytes = await backupFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final filename = file.name;
      final outFile = File(p.join(syncRoot.path, filename));
      if (file.isFile) {
        final data = file.content as List<int>;
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(data);
      } else {
        await Directory(outFile.path).create(recursive: true);
      }
    }
  }

  // Determines the next available backup filename with timestamp
  Future<File> _nextBackupFile(Directory backupsDir) async {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd-HHmmss');
    final baseName = 'sync-${formatter.format(now)}';
    
    var candidate = File(p.join(backupsDir.path, '$baseName.zip'));
    int index = 2;

    while (await candidate.exists()) {
      candidate = File(p.join(backupsDir.path, '$baseName-$index.zip'));
      index++;
    }

    return candidate;
  }

  // Removes old backups, keeping only the most recent ones
  Future<void> pruneBackups({File? preservedBackup}) async {
    var backups = await listBackups();
    final preservedPath = preservedBackup?.path;

    while (backups.length > maximumBackupCount) {
      // Find the oldest backup that is not the preserved one
      BackupArchive? toRemove;
      for (var i = backups.length - 1; i >= 0; i--) {
        if (backups[i].file.path != preservedPath) {
          toRemove = backups[i];
          break;
        }
      }
      
      if (toRemove == null || toRemove.file.path == preservedPath) break;

      await toRemove.file.delete();
      backups.removeWhere((b) => b.file.path == toRemove!.file.path);
    }
  }
}
