// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String lldSaveFoldersFound(int count) {
    return '$count Speicherordner gefunden.';
  }

  @override
  String lldTitleEntriesLoaded(int count) {
    return '$count Titeleinträge geladen';
  }

  @override
  String get archiveCommandFailed => 'Archivbefehl fehlgeschlagen.';

  @override
  String get backupRequired => 'Backup erforderlich';

  @override
  String get backups => 'Backups';

  @override
  String get backupsCouldNotBeLoaded => 'Backups konnten nicht geladen werden';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get catalogCouldNotBeLoaded => 'Katalog konnte nicht geladen werden';

  @override
  String get catalogImportFailed => 'Katalogimport fehlgeschlagen';

  @override
  String get choosePspRoot => 'PSP-Stammordner auswählen';

  @override
  String get chooseSyncRoot => 'Sync-Stammordner auswählen';

  @override
  String get chooseAPspStorageRootAndASyncRoot =>
      'Wählen Sie einen PSP-Speicherstamm und einen Sync-Stamm aus.';

  @override
  String
  get chooseTheTopLevelPspVolumeOrMemoryCardFolderThatContainsPspSavedata =>
      'Wählen Sie das oberste PSP-Volume oder den Speicherkartenordner, der PSP/SAVEDATA enthält.';

  @override
  String get chooseTheTopLevelFolderThatContainsOrWillContainPspSavedata =>
      'Wählen Sie den obersten Ordner, der PSP/SAVEDATA enthält oder enthalten wird.';

  @override
  String get createBackupBeforeWriting => 'Backup vor dem Schreiben erstellen';

  @override
  String createdBackup(String item) {
    return 'Backup $item erstellt.';
  }

  @override
  String get delete => 'Löschen';

  @override
  String get deleteBoth => 'Beide löschen';

  @override
  String get deleteBothCopies => 'Beide Kopien löschen?';

  @override
  String get deleteFailed => 'Löschen fehlgeschlagen';

  @override
  String get deleteFromPspStorage => 'Aus PSP-Speicher löschen?';

  @override
  String get deleteFromSyncRoot => 'Aus Sync-Stamm löschen?';

  @override
  String deletedFromPspStorage(String item) {
    return '$item aus PSP-Speicher gelöscht.';
  }

  @override
  String deletedFromBothSides(String item) {
    return '$item von beiden Seiten gelöscht.';
  }

  @override
  String deletedFromTheSyncRoot(String item) {
    return '$item aus dem Sync-Stamm gelöscht.';
  }

  @override
  String get deselectAll => 'Alle abwählen';

  @override
  String get detectedStorage => 'Erkannter Speicher';

  @override
  String get everythingIsAlreadyInSync => 'Alles ist bereits synchronisiert.';

  @override
  String get folderSelectionCouldNotBeSaved =>
      'Ordnerauswahl konnte nicht gespeichert werden';

  @override
  String get gameCatalog => 'Spielekatalog';

  @override
  String get importJson => 'JSON importieren';

  @override
  String get importPspGameCatalog => 'PSP-Spielekatalog importieren';

  @override
  String importedLldCatalogEntries(int count) {
    return '$count Katalogeinträge importiert.';
  }

  @override
  String lookingUpLldTitlesOnSerialstation(int count) {
    return '$count Titel werden auf SerialStation gesucht...';
  }

  @override
  String get noPspStorageRootSelected => 'Kein PSP-Speicherstamm ausgewählt';

  @override
  String get noPspStorageRootWithPspSavedataDetected =>
      'Kein PSP-Speicherstamm mit PSP/SAVEDATA erkannt.';

  @override
  String get noPspStorageSelected => 'Kein PSP-Speicher ausgewählt.';

  @override
  String get noSavesFound => 'Keine Spielstände gefunden';

  @override
  String get noBackupsSaved => 'Keine Backups gespeichert.';

  @override
  String get noSyncRootSelected => 'Kein Sync-Stamm ausgewählt';

  @override
  String get notSelectedForSync => 'Nicht für die Synchronisierung ausgewählt';

  @override
  String get ok => 'OK';

  @override
  String get onlyInSync => 'Nur in Sync';

  @override
  String get onlyOnPsp => 'Nur auf PSP';

  @override
  String get psp => 'PSP';

  @override
  String get pspStorage => 'PSP-Speicher';

  @override
  String get pspNewer => 'PSP neuer';

  @override
  String get pspStorageDetectedChooseItToGrantAccess =>
      'PSP-Speicher erkannt. Wählen Sie ihn aus, um Zugriff zu gewähren.';

  @override
  String get pspStorageRequired => 'PSP-Speicher erforderlich';

  @override
  String get quit => 'Beenden';

  @override
  String get quitWhileSyncIsRunning =>
      'Beenden, während die Synchronisierung läuft?';

  @override
  String get rescanPspStorageRootAndSyncRoot =>
      'PSP-Speicherstamm und Sync-Stamm erneut scannen';

  @override
  String get restore => 'Wiederherstellen';

  @override
  String get restoreBackup => 'Backup wiederherstellen?';

  @override
  String get restoreFailed => 'Wiederherstellung fehlgeschlagen';

  @override
  String restored(String item) {
    return '$item wiederhergestellt.';
  }

  @override
  String get saveGames => 'Spielstände';

  @override
  String get savedBackups => 'Gespeicherte Backups';

  @override
  String get savedFoldersCouldNotBeRestored =>
      'Gespeicherte Ordner konnten nicht wiederhergestellt werden';

  @override
  String get scan => 'Scannen';

  @override
  String get scanFailed => 'Scan fehlgeschlagen.';

  @override
  String get searchSerialstationApi => 'SerialStation-API durchsuchen';

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get selectPspStorageBeforeSyncing =>
      'Wählen Sie vor dem Synchronisieren den PSP-Speicher aus.';

  @override
  String get selectPspStorageRoot => 'PSP-Speicherstamm auswählen';

  @override
  String
  get selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata =>
      'Wählen Sie einen PSP-Speicherstamm mit PSP/SAVEDATA und einen Sync-Stamm, der PSP/SAVEDATA enthält oder enthalten wird.';

  @override
  String get selectABackupBeforeRestoring =>
      'Wählen Sie vor der Wiederherstellung ein Backup aus.';

  @override
  String get selectASyncRootBeforeRestoringABackup =>
      'Wählen Sie vor der Backup-Wiederherstellung einen Sync-Stamm aus.';

  @override
  String get selectASyncRootBeforeSyncing =>
      'Wählen Sie vor dem Synchronisieren einen Sync-Stamm aus.';

  @override
  String get selectSyncRoot => 'Sync-Stamm auswählen';

  @override
  String get selectedForSync => 'Für die Synchronisierung ausgewählt';

  @override
  String serialstationReturnedHttpLld(int count) {
    return 'SerialStation hat HTTP $count zurückgegeben.';
  }

  @override
  String get serialstationReturnedAnInvalidResponse =>
      'SerialStation hat eine ungültige Antwort zurückgegeben.';

  @override
  String sync(String item) {
    return '$item synchronisieren';
  }

  @override
  String get syncRoot => 'Sync-Stamm';

  @override
  String get syncSelected => 'Auswahl synchronisieren';

  @override
  String get syncFailed => 'Synchronisierung fehlgeschlagen';

  @override
  String get syncNewer => 'Sync neuer';

  @override
  String get syncRootRequired => 'Sync-Stamm erforderlich';

  @override
  String
  get syncSelectedSavesByCopyingTheNewestOrMissingSaveFolderToTheOtherSide =>
      'Ausgewählte Spielstände synchronisieren, indem der neueste oder fehlende Speicherordner auf die andere Seite kopiert wird';

  @override
  String get synced => 'Synchronisiert';

  @override
  String syncedLldSaveFolders(int count) {
    return '$count Speicherordner synchronisiert.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot(String item) {
    return 'Dadurch wird $item dauerhaft aus dem PSP-Speicher und dem Sync-Stamm gelöscht.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorage(String item) {
    return 'Dadurch wird $item dauerhaft aus dem PSP-Speicher gelöscht.';
  }

  @override
  String thisWillPermanentlyDeleteFromTheSyncRoot(String item) {
    return 'Dadurch wird $item dauerhaft aus dem Sync-Stamm gelöscht.';
  }

  @override
  String thisWillReplaceTheCurrentSyncRootContentsWith(String item) {
    return 'Dadurch wird der aktuelle Inhalt des Sync-Stamms durch $item ersetzt.';
  }

  @override
  String get missing => 'fehlt';

  @override
  String get wpspsync => 'wPSPsync';

  @override
  String
  get wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated =>
      'wPSPsync kopiert gerade Speicherordner. Wenn du jetzt beendest, kann der PSP-Speicher oder Sync-Stamm teilweise aktualisiert bleiben.';

  @override
  String get filterByNameOrGameId => 'Nach Name oder ID filtern…';

  @override
  String noResultsFor(String item) {
    return 'Keine Ergebnisse für \"$item\"';
  }
}
