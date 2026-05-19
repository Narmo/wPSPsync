// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String lldSaveFoldersFound(int count) {
    return 'Найдено папок сохранений: $count.';
  }

  @override
  String lldTitleEntriesLoaded(int count) {
    return 'Загружено записей названий: $count';
  }

  @override
  String get archiveCommandFailed => 'Не удалось выполнить команду архивации.';

  @override
  String get backupRequired => 'Требуется резервная копия';

  @override
  String get backups => 'Резервные копии';

  @override
  String get backupsCouldNotBeLoaded => 'Не удалось загрузить резервные копии';

  @override
  String get cancel => 'Отмена';

  @override
  String get catalogCouldNotBeLoaded => 'Не удалось загрузить каталог';

  @override
  String get catalogImportFailed => 'Не удалось импортировать каталог';

  @override
  String get choosePspRoot => 'Выбрать корень PSP';

  @override
  String get chooseSyncRoot => 'Выбрать корень синхронизации';

  @override
  String get chooseAPspStorageRootAndASyncRoot =>
      'Выберите корень хранилища PSP и корень синхронизации.';

  @override
  String
  get chooseTheTopLevelPspVolumeOrMemoryCardFolderThatContainsPspSavedata =>
      'Выберите том PSP или папку карты памяти верхнего уровня, содержащую PSP/SAVEDATA.';

  @override
  String get chooseTheTopLevelFolderThatContainsOrWillContainPspSavedata =>
      'Выберите папку верхнего уровня, которая содержит или будет содержать PSP/SAVEDATA.';

  @override
  String get createBackupBeforeWriting =>
      'Создавать резервную копию перед записью';

  @override
  String createdBackup(String item) {
    return 'Создана резервная копия $item.';
  }

  @override
  String get delete => 'Удалить';

  @override
  String get deleteBoth => 'Удалить обе';

  @override
  String get deleteBothCopies => 'Удалить обе копии?';

  @override
  String get deleteFailed => 'Не удалось удалить';

  @override
  String get deleteFromPspStorage => 'Удалить из хранилища PSP?';

  @override
  String get deleteFromSyncRoot => 'Удалить из корня синхронизации?';

  @override
  String deletedFromPspStorage(String item) {
    return '$item удалено из хранилища PSP.';
  }

  @override
  String deletedFromBothSides(String item) {
    return '$item удалено с обеих сторон.';
  }

  @override
  String deletedFromTheSyncRoot(String item) {
    return '$item удалено из корня синхронизации.';
  }

  @override
  String get deselectAll => 'Снять выделение со всех';

  @override
  String get detectedStorage => 'Обнаруженное хранилище';

  @override
  String get everythingIsAlreadyInSync => 'Всё уже синхронизировано.';

  @override
  String get folderSelectionCouldNotBeSaved =>
      'Не удалось сохранить выбор папки';

  @override
  String get gameCatalog => 'Каталог игр';

  @override
  String get importJson => 'Импортировать JSON';

  @override
  String get importPspGameCatalog => 'Импорт каталога игр PSP';

  @override
  String importedLldCatalogEntries(int count) {
    return 'Импортировано записей каталога: $count.';
  }

  @override
  String lookingUpLldTitlesOnSerialstation(int count) {
    return 'Поиск названий в SerialStation: $count...';
  }

  @override
  String get noPspStorageRootSelected => 'Корень хранилища PSP не выбран';

  @override
  String get noPspStorageRootWithPspSavedataDetected =>
      'Корень хранилища PSP с PSP/SAVEDATA не обнаружен.';

  @override
  String get noPspStorageSelected => 'Хранилище PSP не выбрано.';

  @override
  String get noSavesFound => 'Сохранения не найдены';

  @override
  String get noBackupsSaved => 'Резервные копии не сохранены.';

  @override
  String get noSyncRootSelected => 'Корень синхронизации не выбран';

  @override
  String get notSelectedForSync => 'Не выбрано для синхронизации';

  @override
  String get ok => 'OK';

  @override
  String get onlyInSync => 'Только в синхронизации';

  @override
  String get onlyOnPsp => 'Только на PSP';

  @override
  String get psp => 'PSP';

  @override
  String get pspStorage => 'Хранилище PSP';

  @override
  String get pspNewer => 'PSP новее';

  @override
  String get pspStorageDetectedChooseItToGrantAccess =>
      'Обнаружено хранилище PSP. Выберите его, чтобы предоставить доступ.';

  @override
  String get pspStorageRequired => 'Требуется хранилище PSP';

  @override
  String get quit => 'Выйти';

  @override
  String get quitWhileSyncIsRunning => 'Выйти во время синхронизации?';

  @override
  String get rescanPspStorageRootAndSyncRoot =>
      'Повторно сканировать корень хранилища PSP и корень синхронизации';

  @override
  String get restore => 'Восстановить';

  @override
  String get restoreBackup => 'Восстановить резервную копию?';

  @override
  String get restoreFailed => 'Не удалось восстановить';

  @override
  String restored(String item) {
    return 'Восстановлено: $item.';
  }

  @override
  String get saveGames => 'Сохранения игр';

  @override
  String get savedBackups => 'Сохранённые резервные копии';

  @override
  String get savedFoldersCouldNotBeRestored =>
      'Не удалось восстановить сохранённые папки';

  @override
  String get scan => 'Сканировать';

  @override
  String get scanFailed => 'Сканирование не удалось.';

  @override
  String get searchSerialstationApi => 'Искать в API SerialStation';

  @override
  String get selectAll => 'Выбрать все';

  @override
  String get selectPspStorageBeforeSyncing =>
      'Выберите хранилище PSP перед синхронизацией.';

  @override
  String get selectPspStorageRoot => 'Выбрать корень хранилища PSP';

  @override
  String
  get selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata =>
      'Выберите корень хранилища PSP с PSP/SAVEDATA и корень синхронизации, который содержит или будет содержать PSP/SAVEDATA.';

  @override
  String get selectABackupBeforeRestoring =>
      'Выберите резервную копию перед восстановлением.';

  @override
  String get selectASyncRootBeforeRestoringABackup =>
      'Выберите корень синхронизации перед восстановлением резервной копии.';

  @override
  String get selectASyncRootBeforeSyncing =>
      'Выберите корень синхронизации перед синхронизацией.';

  @override
  String get selectSyncRoot => 'Выбрать корень синхронизации';

  @override
  String get selectedForSync => 'Выбрано для синхронизации';

  @override
  String serialstationReturnedHttpLld(int count) {
    return 'SerialStation вернул HTTP $count.';
  }

  @override
  String get serialstationReturnedAnInvalidResponse =>
      'SerialStation вернул недопустимый ответ.';

  @override
  String sync(String item) {
    return 'Синхронизировать $item';
  }

  @override
  String get syncRoot => 'Корень синхронизации';

  @override
  String get syncSelected => 'Синхронизировать выбранное';

  @override
  String get syncFailed => 'Синхронизация не удалась';

  @override
  String get syncNewer => 'Синхронизированная копия новее';

  @override
  String get syncRootRequired => 'Требуется корень синхронизации';

  @override
  String
  get syncSelectedSavesByCopyingTheNewestOrMissingSaveFolderToTheOtherSide =>
      'Синхронизировать выбранные сохранения, копируя самую новую или отсутствующую папку сохранения на другую сторону';

  @override
  String get synced => 'Синхронизировано';

  @override
  String syncedLldSaveFolders(int count) {
    return 'Синхронизировано папок сохранений: $count.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot(String item) {
    return 'Это навсегда удалит $item из хранилища PSP и корня синхронизации.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorage(String item) {
    return 'Это навсегда удалит $item из хранилища PSP.';
  }

  @override
  String thisWillPermanentlyDeleteFromTheSyncRoot(String item) {
    return 'Это навсегда удалит $item из корня синхронизации.';
  }

  @override
  String thisWillReplaceTheCurrentSyncRootContentsWith(String item) {
    return 'Это заменит текущее содержимое корня синхронизации на $item.';
  }

  @override
  String get missing => 'отсутствует';

  @override
  String get wpspsync => 'wPSPsync';

  @override
  String
  get wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated =>
      'wPSPsync сейчас копирует папки сохранений. Если выйти сейчас, хранилище PSP или корень синхронизации могут остаться частично обновлёнными.';

  @override
  String get filterByNameOrGameId => 'Фильтр по имени или ID…';

  @override
  String noResultsFor(String item) {
    return 'Нет результатов для \"$item\"';
  }
}
