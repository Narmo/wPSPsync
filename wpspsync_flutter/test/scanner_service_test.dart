import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wpspsync_flutter/models/models.dart';
import 'package:wpspsync_flutter/services/scanner_service.dart';

void main() {
  late Directory temporaryRoot;
  late ScannerService scanner;

  setUp(() async {
    final systemTemp = Directory.systemTemp;
    temporaryRoot = await systemTemp.createTemp('wpspsync_test_');
    scanner = ScannerService();
  });

  tearDown(() async {
    if (await temporaryRoot.exists()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  Future<void> writeSaveFile(Directory folder, String contents, DateTime modifiedAt) async {
    final file = File(p.join(folder.path, 'DATA.BIN'));
    await file.writeAsString(contents);
    
    // We now require PARAM.SFO to consider a directory a save folder
    final sfo = File(p.join(folder.path, 'PARAM.SFO'));
    await sfo.writeAsString('fake-sfo-content');
  }

  test('resolves PSP storage root from root, PSP, and SAVEDATA folders', () async {
    final root = Directory(p.join(temporaryRoot.path, 'memory-stick'));
    final psp = Directory(p.join(root.path, 'PSP'));
    final savedata = Directory(p.join(psp.path, 'SAVEDATA'));
    await savedata.create(recursive: true);

    expect((await scanner.resolvePSPStorageRoot(root))?.path, equals(root.path));
    expect((await scanner.resolvePSPStorageRoot(psp))?.path, equals(root.path));
    expect((await scanner.resolvePSPStorageRoot(savedata))?.path, equals(root.path));
  });

  test('scanPSPSaves accepts normalized storage root', () async {
    final root = Directory(p.join(temporaryRoot.path, 'memory-stick'));
    final saveRoot = Directory(p.join(root.path, 'PSP', 'SAVEDATA'));
    final save = Directory(p.join(saveRoot.path, 'ULUS10000DATA00'));
    await save.create(recursive: true);
    await writeSaveFile(save, 'data', DateTime.now());

    final saves = await scanner.scanPSPSaves(Directory(p.join(root.path, 'PSP')), GameCatalog.empty);

    expect(saves.map((e) => e.folderName).toList(), equals(['ULUS10000DATA00']));
  });

  test('scanSyncSaves normalizes PSP and SAVEDATA folders', () async {
    final root = Directory(p.join(temporaryRoot.path, 'sync'));
    final saveRoot = Directory(p.join(root.path, 'PSP', 'SAVEDATA'));
    final save = Directory(p.join(saveRoot.path, 'ULUS10000DATA00'));
    await save.create(recursive: true);
    await writeSaveFile(save, 'data', DateTime.now());

    final pspSaves = await scanner.scanSyncSaves(Directory(p.join(root.path, 'PSP')), GameCatalog.empty);
    final saveDataSaves = await scanner.scanSyncSaves(saveRoot, GameCatalog.empty);

    expect(pspSaves.map((e) => e.folderName).toList(), equals(['ULUS10000DATA00']));
    expect(saveDataSaves.map((e) => e.folderName).toList(), equals(['ULUS10000DATA00']));
    expect((await scanner.resolveSyncRoot(saveRoot)).path, equals(root.path));
  });
}
