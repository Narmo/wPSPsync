import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import '../models/models.dart';
import 'scanner_service.dart';
import 'sync_service.dart';
import 'backup_service.dart';
import 'catalog_service.dart';
import 'serial_station_service.dart';
import 'serial_station_cache_service.dart';

class AppModel extends ChangeNotifier {
  // Observable state
  List<VolumeCandidate> externalCandidates = [];
  Directory? selectedExternalRoot;
  Directory? selectedSyncRoot;
  List<SaveComparison> rows = [];
  GameCatalog catalog = GameCatalog.empty;
  Set<String> selectedRowIDs = {};
  bool useSerialStationAPI = false;
  bool backupsEnabled = true;
  String statusMessage = "Choose a PSP storage root and a sync root.";
  bool isWorking = false;
  bool isSyncing = false;
  List<BackupArchive> backups = [];
  String? selectedBackupId;

  // In-memory SerialStation cache (also persisted to disk)
  Map<String, GameMetadata> _serialStationCache = {};

  // Services
  final ScannerService _scanner = ScannerService();
  final SyncService _syncEngine = SyncService();
  final BackupService _backupStore = BackupService();
  final CatalogService _catalogStore = CatalogService();
  final SerialStationService _serialStation = SerialStationService();
  final SerialStationCacheService _serialStationCache_ = SerialStationCacheService();

  // Preference keys
  static const _externalRootKey = "externalRoot";
  static const _syncRootKey = "syncRoot";
  static const _backupsEnabledKey = "backupsEnabled";
  static const _useSerialStationKey = "useSerialStationAPI";

  AppModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    backupsEnabled = prefs.getBool(_backupsEnabledKey) ?? true;
    useSerialStationAPI = prefs.getBool(_useSerialStationKey) ?? false;

    // Load the on-disk SerialStation cache first
    _serialStationCache = await _serialStationCache_.load();

    await _restoreSelectedRoots();
    await refreshBackups();
    await loadCatalog();
    await refreshVolumes();
  }

  // Refreshes detected external volumes and auto-selects if needed
  Future<void> refreshVolumes() async {
    externalCandidates = await _scanner.discoverVolumeCandidates();

    if (selectedExternalRoot == null && externalCandidates.isNotEmpty) {
      selectedExternalRoot = Directory(externalCandidates.first.rootUri.toFilePath());
    }

    if (selectedExternalRoot == null) {
      rows = [];
      statusMessage = externalCandidates.isEmpty
          ? "No PSP storage selected."
          : "PSP storage detected. Choose it to grant access.";
    } else {
      await scan();
    }
    notifyListeners();
  }

  // Loads the game catalog from disk or bundled asset
  Future<void> loadCatalog() async {
    try {
      catalog = await _catalogStore.loadCatalog();
      notifyListeners();
    } catch (e) {
      statusMessage = "Catalog could not be loaded: $e";
      notifyListeners();
    }
  }

  // Full scan: discovers saves on both sides and compares them
  Future<void> scan() async {
    if (selectedExternalRoot == null) {
      rows = [];
      statusMessage = "No PSP storage selected.";
      notifyListeners();
      return;
    }

    isWorking = true;
    notifyListeners();

    try {
      var pspSaves = await _scanner.scanPSPSaves(selectedExternalRoot!, catalog);
      var syncSaves = selectedSyncRoot != null
          ? await _scanner.scanSyncSaves(selectedSyncRoot!, catalog)
          : <SaveGame>[];

      // Enrich with SerialStation metadata (uses disk cache, fetches only missing IDs)
      if (useSerialStationAPI) {
        final metadata = await _fetchSerialStationMetadata(pspSaves + syncSaves);
        if (metadata.isNotEmpty) {
          pspSaves = pspSaves.map((s) => s.enriched(metadata[s.gameId])).toList();
          syncSaves = syncSaves.map((s) => s.enriched(metadata[s.gameId])).toList();
        }
      } else if (_serialStationCache.isNotEmpty) {
        // Always apply cached metadata even when API toggle is off
        pspSaves = pspSaves.map((s) => s.enriched(_serialStationCache[s.gameId])).toList();
        syncSaves = syncSaves.map((s) => s.enriched(_serialStationCache[s.gameId])).toList();
      }

      rows = _syncEngine.compare(pspSaves: pspSaves, syncSaves: syncSaves);

      // Auto-select all rows that need action
      selectedRowIDs = rows
          .where((r) => r.state != SaveState.same)
          .map((r) => r.id)
          .toSet();

      statusMessage = "${rows.length} save folders found.";
    } catch (e) {
      rows = [];
      statusMessage = "Scan failed: $e";
    } finally {
      isWorking = false;
      notifyListeners();
    }
  }

  // Syncs all selected rows, creating a backup first if enabled
  Future<void> syncSelected() async {
    if (selectedSyncRoot == null || selectedExternalRoot == null) return;

    final selectedRows = rows.where((r) => selectedRowIDs.contains(r.id)).toList();
    final willWriteChanges = selectedRows.any((r) => r.state != SaveState.same);
    final shouldCreateBackup = backupsEnabled && willWriteChanges;

    isWorking = true;
    isSyncing = true;
    notifyListeners();

    try {
      if (shouldCreateBackup) {
        final backupFile = await _backupStore.createBackup(selectedSyncRoot!);
        await refreshBackups();
        statusMessage = "Created backup ${p.basename(backupFile.path)}.";
        notifyListeners();
      }

      final syncedCount = await _syncEngine.syncLatest(
        rows: selectedRows,
        syncRoot: selectedSyncRoot!,
        pspRoot: selectedExternalRoot!,
      );

      await scan();
      statusMessage = syncedCount == 0
          ? "Everything is already in sync."
          : "Synced $syncedCount save folders.";
    } catch (e) {
      statusMessage = "Sync failed: $e";
    } finally {
      isSyncing = false;
      isWorking = false;
      notifyListeners();
    }
  }

  // Deletes a save from PSP storage after confirmation
  Future<bool> deletePSPSave(SaveComparison row) async {
    if (row.psp == null) return false;
    return _deletePaths(
      [Directory(row.psp!.rootUri.toFilePath())],
      status: "Deleted ${row.displayTitle} from PSP storage.",
    );
  }

  // Deletes a save from the sync root after confirmation
  Future<bool> deleteSyncSave(SaveComparison row) async {
    if (row.sync == null) return false;
    return _deletePaths(
      [Directory(row.sync!.rootUri.toFilePath())],
      status: "Deleted ${row.displayTitle} from the sync root.",
    );
  }

  // Deletes a save from both sides
  Future<bool> deleteBothSaves(SaveComparison row) async {
    final paths = <Directory>[];
    if (row.psp != null) paths.add(Directory(row.psp!.rootUri.toFilePath()));
    if (row.sync != null) paths.add(Directory(row.sync!.rootUri.toFilePath()));
    if (paths.isEmpty) return false;
    return _deletePaths(paths, status: "Deleted ${row.displayTitle} from both sides.");
  }

  Future<bool> _deletePaths(List<Directory> dirs, {required String status}) async {
    isWorking = true;
    notifyListeners();
    try {
      for (final dir in dirs) {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      }
      await scan();
      statusMessage = status;
      return true;
    } catch (e) {
      statusMessage = "Delete failed: $e";
      notifyListeners();
      return false;
    } finally {
      isWorking = false;
      notifyListeners();
    }
  }

  // Imports a new game catalog from a JSON file
  Future<void> importCatalog(File file) async {
    try {
      catalog = await _catalogStore.importCatalog(file);
      await scan();
      statusMessage = "Imported ${catalog.games.length} catalog entries.";
    } catch (e) {
      statusMessage = "Catalog import failed: $e";
    } finally {
      notifyListeners();
    }
  }

  // Restores the selected backup to the sync root
  Future<void> restoreSelectedBackup() async {
    if (selectedSyncRoot == null) return;

    BackupArchive backup;
    try {
      backup = backups.firstWhere((b) => b.id == selectedBackupId);
    } catch (_) {
      statusMessage = "No backup selected.";
      notifyListeners();
      return;
    }

    isWorking = true;
    notifyListeners();

    try {
      if (backupsEnabled) {
        // Create a safety backup before overwriting (preserving the one being restored)
        await _backupStore.createBackup(selectedSyncRoot!, preservedBackup: backup.file);
        await refreshBackups();
      }

      await _backupStore.restoreBackup(backup.file, selectedSyncRoot!);
      await scan();
      await refreshBackups();
      statusMessage = "Restored ${p.basename(backup.file.path)}.";
    } catch (e) {
      statusMessage = "Restore failed: $e";
    } finally {
      isWorking = false;
      notifyListeners();
    }
  }

  // Refreshes the backup list, keeping the selection if still valid
  Future<void> refreshBackups() async {
    try {
      backups = await _backupStore.listBackups();
      if (selectedBackupId == null || !backups.any((b) => b.id == selectedBackupId)) {
        selectedBackupId = backups.isNotEmpty ? backups.first.id : null;
      }
      notifyListeners();
    } catch (e) {
      backups = [];
      selectedBackupId = null;
      statusMessage = "Backups could not be loaded: $e";
      notifyListeners();
    }
  }

  // Row selection helpers
  void toggleSelection(String id) {
    if (selectedRowIDs.contains(id)) {
      selectedRowIDs.remove(id);
    } else {
      selectedRowIDs.add(id);
    }
    notifyListeners();
  }

  void selectAllRows() {
    selectedRowIDs = rows.map((r) => r.id).toSet();
    notifyListeners();
  }

  void clearSelection() {
    selectedRowIDs.clear();
    notifyListeners();
  }

  void setSelectedBackupId(String? id) {
    selectedBackupId = id;
    notifyListeners();
  }

  // Directory pickers
  Future<void> selectExternalRoot() async {
    final path = await FilePicker.getDirectoryPath(
      dialogTitle: "Select PSP storage root",
    );
    if (path != null) {
      selectedExternalRoot = Directory(path);
      await _persistRoot(path, _externalRootKey);
      await scan();
    }
  }

  Future<void> selectSyncRoot() async {
    final path = await FilePicker.getDirectoryPath(
      dialogTitle: "Select sync root",
    );
    if (path != null) {
      selectedSyncRoot = Directory(path);
      await _persistRoot(path, _syncRootKey);
      await scan();
    }
  }

  // Toggle helpers (persist preferences)
  Future<void> toggleBackups(bool value) async {
    backupsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_backupsEnabledKey, value);
    notifyListeners();
  }

  Future<void> toggleSerialStation(bool value) async {
    useSerialStationAPI = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_useSerialStationKey, value);
    notifyListeners();
    if (value) await scan();
  }

  // Fetches SerialStation metadata for saves not already in cache
  Future<Map<String, GameMetadata>> _fetchSerialStationMetadata(List<SaveGame> saves) async {
    final ids = saves.map((s) => s.gameId).toSet()
        .where((id) => GameIDParser.parse(id) != null)
        .toList();

    final result = Map<String, GameMetadata>.from(_serialStationCache);
    final missingIds = ids.where((id) => !result.containsKey(id)).toList();

    if (missingIds.isEmpty) return result;

    statusMessage = "Looking up ${missingIds.length} titles on SerialStation...";
    notifyListeners();

    await Future.wait(missingIds.map((id) async {
      try {
        final meta = await _serialStation.fetchMetadata(id);
        if (meta != null) result[id] = meta;
      } catch (_) {}
    }));

    _serialStationCache = result;
    await _serialStationCache_.save(_serialStationCache);

    return result;
  }

  // Persistence helpers
  Future<void> _persistRoot(String path, String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, path);
  }

  Future<void> _restoreSelectedRoots() async {
    final prefs = await SharedPreferences.getInstance();
    final extPath = prefs.getString(_externalRootKey);
    final syncPath = prefs.getString(_syncRootKey);
    if (extPath != null) selectedExternalRoot = Directory(extPath);
    if (syncPath != null) selectedSyncRoot = Directory(syncPath);
  }
}
