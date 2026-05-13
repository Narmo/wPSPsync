import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wpspsync_flutter/models/models.dart';
import 'package:wpspsync_flutter/services/sync_service.dart';

void main() {
  late Directory temporaryRoot;
  late SyncService engine;

  setUp(() async {
    final systemTemp = Directory.systemTemp;
    temporaryRoot = await systemTemp.createTemp('wpspsync_test_');
    engine = SyncService();
  });

  tearDown(() async {
    if (await temporaryRoot.exists()) {
      await temporaryRoot.delete(recursive: true);
    }
  });

  Future<SaveGame> makeSave({
    required Directory root,
    required String folderName,
    required String fileName,
    required String contents,
    required DateTime modifiedAt,
  }) async {
    final folderDir = Directory(p.join(root.path, folderName));
    await folderDir.create(recursive: true);
    
    final file = File(p.join(folderDir.path, fileName));
    await file.writeAsString(contents);
    
    // In tests, we rely on the object's modifiedAt directly for the mock,
    // so we don't strictly need to alter the file system timestamp here.
    return SaveGame(
      folderName: folderName,
      rootUri: Uri.file(folderDir.path),
      modifiedAt: modifiedAt,
      size: contents.length,
    );
  }

  Future<String> readSave({required Directory root, required String folderName}) async {
    final file = File(p.join(root.path, 'PSP', 'SAVEDATA', folderName, 'DATA.BIN'));
    return await file.readAsString();
  }

  test('syncLatest copies newer and missing saves both ways', () async {
    final pspRoot = Directory(p.join(temporaryRoot.path, 'psp'));
    final syncRoot = Directory(p.join(temporaryRoot.path, 'sync'));

    final olderDate = DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true);
    final newerDate = DateTime.fromMillisecondsSinceEpoch(1700000100000, isUtc: true);

    final pspNewer = await makeSave(
        root: Directory(p.join(pspRoot.path, 'PSP', 'SAVEDATA')),
        folderName: "ULUS10000DATA00",
        fileName: "DATA.BIN",
        contents: "psp-newer",
        modifiedAt: newerDate);
    final syncOlder = await makeSave(
        root: Directory(p.join(syncRoot.path, 'PSP', 'SAVEDATA')),
        folderName: "ULUS10000DATA00",
        fileName: "DATA.BIN",
        contents: "sync-older",
        modifiedAt: olderDate);
    final pspOlder = await makeSave(
        root: Directory(p.join(pspRoot.path, 'PSP', 'SAVEDATA')),
        folderName: "ULUS10001DATA00",
        fileName: "DATA.BIN",
        contents: "psp-older",
        modifiedAt: olderDate);
    final syncNewer = await makeSave(
        root: Directory(p.join(syncRoot.path, 'PSP', 'SAVEDATA')),
        folderName: "ULUS10001DATA00",
        fileName: "DATA.BIN",
        contents: "sync-newer",
        modifiedAt: newerDate);
    final onlyPSP = await makeSave(
        root: Directory(p.join(pspRoot.path, 'PSP', 'SAVEDATA')),
        folderName: "ULUS10002DATA00",
        fileName: "DATA.BIN",
        contents: "only-psp",
        modifiedAt: newerDate);
    final onlySync = await makeSave(
        root: Directory(p.join(syncRoot.path, 'PSP', 'SAVEDATA')),
        folderName: "ULUS10003DATA00",
        fileName: "DATA.BIN",
        contents: "only-sync",
        modifiedAt: newerDate);

    final rows = [
      SaveComparison(folderName: "ULUS10000DATA00", psp: pspNewer, sync: syncOlder),
      SaveComparison(folderName: "ULUS10001DATA00", psp: pspOlder, sync: syncNewer),
      SaveComparison(folderName: "ULUS10002DATA00", psp: onlyPSP, sync: null),
      SaveComparison(folderName: "ULUS10003DATA00", psp: null, sync: onlySync),
    ];

    final syncedCount = await engine.syncLatest(rows: rows, syncRoot: syncRoot, pspRoot: pspRoot);

    expect(syncedCount, equals(4));
    expect(await readSave(root: syncRoot, folderName: "ULUS10000DATA00"), equals("psp-newer"));
    expect(await readSave(root: pspRoot, folderName: "ULUS10001DATA00"), equals("sync-newer"));
    expect(await readSave(root: syncRoot, folderName: "ULUS10002DATA00"), equals("only-psp"));
    expect(await readSave(root: pspRoot, folderName: "ULUS10003DATA00"), equals("only-sync"));
  });

  test('syncLatest does not nest save data when sync root points at SAVEDATA folder', () async {
    final pspRoot = Directory(p.join(temporaryRoot.path, 'psp'));
    final syncRoot = Directory(p.join(temporaryRoot.path, 'sync'));
    final saveDataRoot = Directory(p.join(syncRoot.path, 'PSP', 'SAVEDATA'));

    final pspSave = await makeSave(
      root: Directory(p.join(pspRoot.path, 'PSP', 'SAVEDATA')),
      folderName: "ULUS10000DATA00",
      fileName: "DATA.BIN",
      contents: "psp-newer",
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(1700000100000, isUtc: true),
    );
    final syncSave = await makeSave(
      root: saveDataRoot,
      folderName: "ULUS10000DATA00",
      fileName: "DATA.BIN",
      contents: "sync-older",
      modifiedAt: DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true),
    );

    final row = SaveComparison(folderName: "ULUS10000DATA00", psp: pspSave, sync: syncSave);

    await engine.syncLatest(rows: [row], syncRoot: saveDataRoot, pspRoot: pspRoot);

    expect(await readSave(root: syncRoot, folderName: "ULUS10000DATA00"), equals("psp-newer"));
    expect(Directory(p.join(saveDataRoot.path, 'SAVEDATA')).existsSync(), isFalse);
  });

  test('syncLatest skips unchanged saves', () async {
    final pspRoot = Directory(p.join(temporaryRoot.path, 'psp'));
    final syncRoot = Directory(p.join(temporaryRoot.path, 'sync'));
    final sameDate = DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true);

    final pspSave = await makeSave(
      root: Directory(p.join(pspRoot.path, 'PSP', 'SAVEDATA')),
      folderName: "ULUS10000DATA00",
      fileName: "DATA.BIN",
      contents: "psp-copy",
      modifiedAt: sameDate,
    );
    final syncSave = await makeSave(
      root: Directory(p.join(syncRoot.path, 'PSP', 'SAVEDATA')),
      folderName: "ULUS10000DATA00",
      fileName: "DATA.BIN",
      contents: "sync-copy",
      modifiedAt: sameDate,
    );

    final row = SaveComparison(folderName: "ULUS10000DATA00", psp: pspSave, sync: syncSave);

    final syncedCount = await engine.syncLatest(rows: [row], syncRoot: syncRoot, pspRoot: pspRoot);

    expect(syncedCount, equals(0));
    expect(await readSave(root: pspRoot, folderName: "ULUS10000DATA00"), equals("psp-copy"));
    expect(await readSave(root: syncRoot, folderName: "ULUS10000DATA00"), equals("sync-copy"));
  });
}
