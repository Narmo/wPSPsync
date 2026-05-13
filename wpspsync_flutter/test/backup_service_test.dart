import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wpspsync_flutter/services/backup_service.dart';

void main() {
  late Directory temporaryRoot;

  setUp(() async {
    final systemTemp = Directory.systemTemp;
    temporaryRoot = await systemTemp.createTemp('wpspsync_test_');
  });

  tearDown(() async {
    if (await temporaryRoot.exists()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  test('creates Zip backup and restores sync root contents', () async {
    final syncRoot = Directory(p.join(temporaryRoot.path, 'sync'));
    final backupsRoot = Directory(p.join(temporaryRoot.path, 'backups'));
    final store = BackupService(customBackupsDirectory: backupsRoot);
    
    final save = Directory(p.join(syncRoot.path, 'PSP', 'SAVEDATA', 'ULUS10000DATA00'));
    await save.create(recursive: true);
    await File(p.join(save.path, 'DATA.BIN')).writeAsString('original');

    final backupFile = await store.createBackup(syncRoot);
    
    await File(p.join(save.path, 'DATA.BIN')).writeAsString('changed');
    await File(p.join(syncRoot.path, 'EXTRA.BIN')).writeAsString('extra');

    await store.restoreBackup(backupFile, syncRoot);

    final restoredUrl = File(p.join(save.path, 'DATA.BIN'));
    expect(await restoredUrl.readAsString(), equals('original'));
    expect(File(p.join(syncRoot.path, 'EXTRA.BIN')).existsSync(), isFalse);
    expect(backupFile.existsSync(), isTrue);
    expect(backupFile.parent.path, equals(backupsRoot.path));
  });

  test('keeps only five newest backups', () async {
    final syncRoot = Directory(p.join(temporaryRoot.path, 'sync'));
    final backupsRoot = Directory(p.join(temporaryRoot.path, 'backups'));
    await syncRoot.create(recursive: true);
    final dataUrl = File(p.join(syncRoot.path, 'DATA.BIN'));
    final store = BackupService(customBackupsDirectory: backupsRoot);

    // Create 6 backups with slight delays to ensure unique timestamps
    for (int index = 0; index < 6; index++) {
      await dataUrl.writeAsString('$index');
      await store.createBackup(syncRoot);
      await Future.delayed(const Duration(milliseconds: 1100)); // Ensure different second
    }

    final backups = await store.listBackups();
    expect(backups.length, equals(5));
    
    // Check that we only kept the last 5
    final zips = backupsRoot.listSync().whereType<File>().toList();
    expect(zips.length, equals(5));
  });
}
