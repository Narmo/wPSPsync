// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String lldSaveFoldersFound(int count) {
    return '$count save folders found.';
  }

  @override
  String lldTitleEntriesLoaded(int count) {
    return '$count title entries loaded';
  }

  @override
  String get archiveCommandFailed => 'Archive command failed.';

  @override
  String get backupRequired => 'Backup required';

  @override
  String get backups => 'Backups';

  @override
  String get backupsCouldNotBeLoaded => 'Backups could not be loaded';

  @override
  String get cancel => 'Cancel';

  @override
  String get catalogCouldNotBeLoaded => 'Catalog could not be loaded';

  @override
  String get catalogImportFailed => 'Catalog import failed';

  @override
  String get choosePspRoot => 'Choose PSP Root';

  @override
  String get chooseSyncRoot => 'Choose Sync Root';

  @override
  String get chooseAPspStorageRootAndASyncRoot =>
      'Choose a PSP storage root and a sync root.';

  @override
  String
  get chooseTheTopLevelPspVolumeOrMemoryCardFolderThatContainsPspSavedata =>
      'Choose the top-level PSP volume or memory card folder that contains PSP/SAVEDATA.';

  @override
  String get chooseTheTopLevelFolderThatContainsOrWillContainPspSavedata =>
      'Choose the top-level folder that contains or will contain PSP/SAVEDATA.';

  @override
  String get createBackupBeforeWriting => 'Create backup before writing';

  @override
  String createdBackup(String item) {
    return 'Created backup $item.';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteBoth => 'Delete Both';

  @override
  String get deleteBothCopies => 'Delete both copies?';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get deleteFromPspStorage => 'Delete from PSP storage?';

  @override
  String get deleteFromSyncRoot => 'Delete from sync root?';

  @override
  String deletedFromPspStorage(String item) {
    return 'Deleted $item from PSP storage.';
  }

  @override
  String deletedFromBothSides(String item) {
    return 'Deleted $item from both sides.';
  }

  @override
  String deletedFromTheSyncRoot(String item) {
    return 'Deleted $item from the sync root.';
  }

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get detectedStorage => 'Detected storage';

  @override
  String get everythingIsAlreadyInSync => 'Everything is already in sync.';

  @override
  String get folderSelectionCouldNotBeSaved =>
      'Folder selection could not be saved';

  @override
  String get gameCatalog => 'Game Catalog';

  @override
  String get importJson => 'Import JSON';

  @override
  String get importPspGameCatalog => 'Import PSP game catalog';

  @override
  String importedLldCatalogEntries(int count) {
    return 'Imported $count catalog entries.';
  }

  @override
  String lookingUpLldTitlesOnSerialstation(int count) {
    return 'Looking up $count titles on SerialStation...';
  }

  @override
  String get noPspStorageRootSelected => 'No PSP storage root selected';

  @override
  String get noPspStorageRootWithPspSavedataDetected =>
      'No PSP storage root with PSP/SAVEDATA detected.';

  @override
  String get noPspStorageSelected => 'No PSP storage selected.';

  @override
  String get noSavesFound => 'No Saves Found';

  @override
  String get noBackupsSaved => 'No backups saved.';

  @override
  String get noSyncRootSelected => 'No sync root selected';

  @override
  String get notSelectedForSync => 'Not selected for sync';

  @override
  String get ok => 'OK';

  @override
  String get onlyInSync => 'Only in sync';

  @override
  String get onlyOnPsp => 'Only on PSP';

  @override
  String get psp => 'PSP';

  @override
  String get pspStorage => 'PSP Storage';

  @override
  String get pspNewer => 'PSP newer';

  @override
  String get pspStorageDetectedChooseItToGrantAccess =>
      'PSP storage detected. Choose it to grant access.';

  @override
  String get pspStorageRequired => 'PSP storage required';

  @override
  String get quit => 'Quit';

  @override
  String get quitWhileSyncIsRunning => 'Quit while sync is running?';

  @override
  String get rescanPspStorageRootAndSyncRoot =>
      'Rescan PSP storage root and sync root';

  @override
  String get restore => 'Restore';

  @override
  String get restoreBackup => 'Restore backup?';

  @override
  String get restoreFailed => 'Restore failed';

  @override
  String restored(String item) {
    return 'Restored $item.';
  }

  @override
  String get saveGames => 'Save Games';

  @override
  String get savedBackups => 'Saved backups';

  @override
  String get savedFoldersCouldNotBeRestored =>
      'Saved folders could not be restored';

  @override
  String get scan => 'Scan';

  @override
  String get scanFailed => 'Scan failed.';

  @override
  String get searchSerialstationApi => 'Search SerialStation API';

  @override
  String get selectAll => 'Select All';

  @override
  String get selectPspStorageBeforeSyncing =>
      'Select PSP storage before syncing.';

  @override
  String get selectPspStorageRoot => 'Select PSP storage root';

  @override
  String
  get selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata =>
      'Select a PSP storage root with PSP/SAVEDATA and a sync root that contains or will contain PSP/SAVEDATA.';

  @override
  String get selectABackupBeforeRestoring =>
      'Select a backup before restoring.';

  @override
  String get selectASyncRootBeforeRestoringABackup =>
      'Select a sync root before restoring a backup.';

  @override
  String get selectASyncRootBeforeSyncing =>
      'Select a sync root before syncing.';

  @override
  String get selectSyncRoot => 'Select sync root';

  @override
  String get selectedForSync => 'Selected for sync';

  @override
  String serialstationReturnedHttpLld(int count) {
    return 'SerialStation returned HTTP $count.';
  }

  @override
  String get serialstationReturnedAnInvalidResponse =>
      'SerialStation returned an invalid response.';

  @override
  String sync(String item) {
    return 'Sync $item';
  }

  @override
  String get syncRoot => 'Sync Root';

  @override
  String get syncSelected => 'Sync Selected';

  @override
  String get syncFailed => 'Sync failed';

  @override
  String get syncNewer => 'Sync newer';

  @override
  String get syncRootRequired => 'Sync root required';

  @override
  String
  get syncSelectedSavesByCopyingTheNewestOrMissingSaveFolderToTheOtherSide =>
      'Sync selected saves by copying the newest or missing save folder to the other side';

  @override
  String get synced => 'Synced';

  @override
  String syncedLldSaveFolders(int count) {
    return 'Synced $count save folders.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot(String item) {
    return 'This will permanently delete $item from PSP storage and the sync root.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorage(String item) {
    return 'This will permanently delete $item from PSP storage.';
  }

  @override
  String thisWillPermanentlyDeleteFromTheSyncRoot(String item) {
    return 'This will permanently delete $item from the sync root.';
  }

  @override
  String thisWillReplaceTheCurrentSyncRootContentsWith(String item) {
    return 'This will replace the current sync root contents with $item.';
  }

  @override
  String get missing => 'missing';

  @override
  String get wpspsync => 'wPSPsync';

  @override
  String
  get wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated =>
      'wPSPsync is currently copying save folders. Quitting now may leave the PSP storage or sync root partially updated.';

  @override
  String get filterByNameOrGameId => 'Filter by name or game ID…';

  @override
  String noResultsFor(String item) {
    return 'No results for \"$item\"';
  }
}
