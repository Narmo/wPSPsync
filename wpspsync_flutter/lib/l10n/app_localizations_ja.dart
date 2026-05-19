// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String lldSaveFoldersFound(int count) {
    return '$count 件のセーブフォルダが見つかりました。';
  }

  @override
  String lldTitleEntriesLoaded(int count) {
    return '$count 件のタイトル項目を読み込みました';
  }

  @override
  String get archiveCommandFailed => 'アーカイブコマンドに失敗しました。';

  @override
  String get backupRequired => 'バックアップが必要です';

  @override
  String get backups => 'バックアップ';

  @override
  String get backupsCouldNotBeLoaded => 'バックアップを読み込めませんでした';

  @override
  String get cancel => 'キャンセル';

  @override
  String get catalogCouldNotBeLoaded => 'カタログを読み込めませんでした';

  @override
  String get catalogImportFailed => 'カタログの読み込みに失敗しました';

  @override
  String get choosePspRoot => 'PSPルートを選択';

  @override
  String get chooseSyncRoot => '同期ルートを選択';

  @override
  String get chooseAPspStorageRootAndASyncRoot => 'PSPストレージルートと同期ルートを選択してください。';

  @override
  String
  get chooseTheTopLevelPspVolumeOrMemoryCardFolderThatContainsPspSavedata =>
      'PSP/SAVEDATAを含む最上位のPSPボリュームまたはメモリカードフォルダを選択してください。';

  @override
  String get chooseTheTopLevelFolderThatContainsOrWillContainPspSavedata =>
      'PSP/SAVEDATAを含む、またはこれから含む最上位フォルダを選択してください。';

  @override
  String get createBackupBeforeWriting => '書き込む前にバックアップを作成';

  @override
  String createdBackup(String item) {
    return 'バックアップ$itemを作成しました。';
  }

  @override
  String get delete => '削除';

  @override
  String get deleteBoth => '両方を削除';

  @override
  String get deleteBothCopies => '両方のコピーを削除しますか？';

  @override
  String get deleteFailed => '削除に失敗しました';

  @override
  String get deleteFromPspStorage => 'PSPストレージから削除しますか？';

  @override
  String get deleteFromSyncRoot => '同期ルートから削除しますか？';

  @override
  String deletedFromPspStorage(String item) {
    return '$itemをPSPストレージから削除しました。';
  }

  @override
  String deletedFromBothSides(String item) {
    return '$itemを両方から削除しました。';
  }

  @override
  String deletedFromTheSyncRoot(String item) {
    return '$itemを同期ルートから削除しました。';
  }

  @override
  String get deselectAll => 'すべて解除';

  @override
  String get detectedStorage => '検出されたストレージ';

  @override
  String get everythingIsAlreadyInSync => 'すべて既に同期されています。';

  @override
  String get folderSelectionCouldNotBeSaved => 'フォルダの選択を保存できませんでした';

  @override
  String get gameCatalog => 'ゲームカタログ';

  @override
  String get importJson => 'JSONを読み込む';

  @override
  String get importPspGameCatalog => 'PSPゲームカタログを読み込む';

  @override
  String importedLldCatalogEntries(int count) {
    return '$count 件のカタログ項目を読み込みました。';
  }

  @override
  String lookingUpLldTitlesOnSerialstation(int count) {
    return 'SerialStationで$count件のタイトルを検索中...';
  }

  @override
  String get noPspStorageRootSelected => 'PSPストレージルートが選択されていません';

  @override
  String get noPspStorageRootWithPspSavedataDetected =>
      'PSP/SAVEDATAを含むPSPストレージルートが検出されませんでした。';

  @override
  String get noPspStorageSelected => 'PSPストレージが選択されていません。';

  @override
  String get noSavesFound => 'セーブデータが見つかりません';

  @override
  String get noBackupsSaved => '保存されたバックアップはありません。';

  @override
  String get noSyncRootSelected => '同期ルートが選択されていません';

  @override
  String get notSelectedForSync => '同期対象に選択されていません';

  @override
  String get ok => 'OK';

  @override
  String get onlyInSync => '同期側のみ';

  @override
  String get onlyOnPsp => 'PSPのみ';

  @override
  String get psp => 'PSP';

  @override
  String get pspStorage => 'PSPストレージ';

  @override
  String get pspNewer => 'PSPが新しい';

  @override
  String get pspStorageDetectedChooseItToGrantAccess =>
      'PSPストレージを検出しました。アクセスを許可するには選択してください。';

  @override
  String get pspStorageRequired => 'PSPストレージが必要です';

  @override
  String get quit => '終了';

  @override
  String get quitWhileSyncIsRunning => '同期中に終了しますか？';

  @override
  String get rescanPspStorageRootAndSyncRoot => 'PSPストレージルートと同期ルートを再スキャン';

  @override
  String get restore => '復元';

  @override
  String get restoreBackup => 'バックアップを復元しますか？';

  @override
  String get restoreFailed => '復元に失敗しました';

  @override
  String restored(String item) {
    return '$itemを復元しました。';
  }

  @override
  String get saveGames => 'セーブデータ';

  @override
  String get savedBackups => '保存済みバックアップ';

  @override
  String get savedFoldersCouldNotBeRestored => '保存済みフォルダを復元できませんでした';

  @override
  String get scan => 'スキャン';

  @override
  String get scanFailed => 'スキャンに失敗しました。';

  @override
  String get searchSerialstationApi => 'SerialStation APIを検索';

  @override
  String get selectAll => 'すべて選択';

  @override
  String get selectPspStorageBeforeSyncing => '同期する前にPSPストレージを選択してください。';

  @override
  String get selectPspStorageRoot => 'PSPストレージルートを選択';

  @override
  String
  get selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata =>
      'PSP/SAVEDATAを含むPSPストレージルートと、PSP/SAVEDATAを含む、またはこれから含む同期ルートを選択してください。';

  @override
  String get selectABackupBeforeRestoring => '復元する前にバックアップを選択してください。';

  @override
  String get selectASyncRootBeforeRestoringABackup =>
      'バックアップを復元する前に同期ルートを選択してください。';

  @override
  String get selectASyncRootBeforeSyncing => '同期する前に同期ルートを選択してください。';

  @override
  String get selectSyncRoot => '同期ルートを選択';

  @override
  String get selectedForSync => '同期対象に選択済み';

  @override
  String serialstationReturnedHttpLld(int count) {
    return 'SerialStationからHTTP $countが返されました。';
  }

  @override
  String get serialstationReturnedAnInvalidResponse =>
      'SerialStationから無効な応答が返されました。';

  @override
  String sync(String item) {
    return '$itemを同期';
  }

  @override
  String get syncRoot => '同期ルート';

  @override
  String get syncSelected => '選択項目を同期';

  @override
  String get syncFailed => '同期に失敗しました';

  @override
  String get syncNewer => '同期側が新しい';

  @override
  String get syncRootRequired => '同期ルートが必要です';

  @override
  String
  get syncSelectedSavesByCopyingTheNewestOrMissingSaveFolderToTheOtherSide =>
      '最新または不足しているセーブフォルダを反対側へコピーして、選択したセーブを同期します';

  @override
  String get synced => '同期済み';

  @override
  String syncedLldSaveFolders(int count) {
    return '$count 件のセーブフォルダを同期しました。';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot(String item) {
    return '$itemをPSPストレージと同期ルートから完全に削除します。';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorage(String item) {
    return '$itemをPSPストレージから完全に削除します。';
  }

  @override
  String thisWillPermanentlyDeleteFromTheSyncRoot(String item) {
    return '$itemを同期ルートから完全に削除します。';
  }

  @override
  String thisWillReplaceTheCurrentSyncRootContentsWith(String item) {
    return '現在の同期ルートの内容を$itemで置き換えます。';
  }

  @override
  String get missing => 'なし';

  @override
  String get wpspsync => 'wPSPsync';

  @override
  String
  get wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated =>
      'wPSPsync は現在セーブフォルダをコピーしています。今終了すると、PSPストレージまたは同期ルートが部分的に更新された状態になる可能性があります。';

  @override
  String get filterByNameOrGameId => '名前またはIDでフィルタ…';

  @override
  String noResultsFor(String item) {
    return '「$item」の結果はありません';
  }
}
