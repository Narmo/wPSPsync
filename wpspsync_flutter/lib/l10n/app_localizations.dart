import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// No description provided for @lldSaveFoldersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} save folders found.'**
  String lldSaveFoldersFound(int count);

  /// No description provided for @lldTitleEntriesLoaded.
  ///
  /// In en, this message translates to:
  /// **'{count} title entries loaded'**
  String lldTitleEntriesLoaded(int count);

  /// No description provided for @archiveCommandFailed.
  ///
  /// In en, this message translates to:
  /// **'Archive command failed.'**
  String get archiveCommandFailed;

  /// No description provided for @backupRequired.
  ///
  /// In en, this message translates to:
  /// **'Backup required'**
  String get backupRequired;

  /// No description provided for @backups.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get backups;

  /// No description provided for @backupsCouldNotBeLoaded.
  ///
  /// In en, this message translates to:
  /// **'Backups could not be loaded'**
  String get backupsCouldNotBeLoaded;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @catalogCouldNotBeLoaded.
  ///
  /// In en, this message translates to:
  /// **'Catalog could not be loaded'**
  String get catalogCouldNotBeLoaded;

  /// No description provided for @catalogImportFailed.
  ///
  /// In en, this message translates to:
  /// **'Catalog import failed'**
  String get catalogImportFailed;

  /// No description provided for @choosePspRoot.
  ///
  /// In en, this message translates to:
  /// **'Choose PSP Root'**
  String get choosePspRoot;

  /// No description provided for @chooseSyncRoot.
  ///
  /// In en, this message translates to:
  /// **'Choose Sync Root'**
  String get chooseSyncRoot;

  /// No description provided for @chooseAPspStorageRootAndASyncRoot.
  ///
  /// In en, this message translates to:
  /// **'Choose a PSP storage root and a sync root.'**
  String get chooseAPspStorageRootAndASyncRoot;

  /// No description provided for @chooseTheTopLevelPspVolumeOrMemoryCardFolderThatContainsPspSavedata.
  ///
  /// In en, this message translates to:
  /// **'Choose the top-level PSP volume or memory card folder that contains PSP/SAVEDATA.'**
  String
  get chooseTheTopLevelPspVolumeOrMemoryCardFolderThatContainsPspSavedata;

  /// No description provided for @chooseTheTopLevelFolderThatContainsOrWillContainPspSavedata.
  ///
  /// In en, this message translates to:
  /// **'Choose the top-level folder that contains or will contain PSP/SAVEDATA.'**
  String get chooseTheTopLevelFolderThatContainsOrWillContainPspSavedata;

  /// No description provided for @createBackupBeforeWriting.
  ///
  /// In en, this message translates to:
  /// **'Create backup before writing'**
  String get createBackupBeforeWriting;

  /// No description provided for @createdBackup.
  ///
  /// In en, this message translates to:
  /// **'Created backup {item}.'**
  String createdBackup(String item);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteBoth.
  ///
  /// In en, this message translates to:
  /// **'Delete Both'**
  String get deleteBoth;

  /// No description provided for @deleteBothCopies.
  ///
  /// In en, this message translates to:
  /// **'Delete both copies?'**
  String get deleteBothCopies;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @deleteFromPspStorage.
  ///
  /// In en, this message translates to:
  /// **'Delete from PSP storage?'**
  String get deleteFromPspStorage;

  /// No description provided for @deleteFromSyncRoot.
  ///
  /// In en, this message translates to:
  /// **'Delete from sync root?'**
  String get deleteFromSyncRoot;

  /// No description provided for @deletedFromPspStorage.
  ///
  /// In en, this message translates to:
  /// **'Deleted {item} from PSP storage.'**
  String deletedFromPspStorage(String item);

  /// No description provided for @deletedFromBothSides.
  ///
  /// In en, this message translates to:
  /// **'Deleted {item} from both sides.'**
  String deletedFromBothSides(String item);

  /// No description provided for @deletedFromTheSyncRoot.
  ///
  /// In en, this message translates to:
  /// **'Deleted {item} from the sync root.'**
  String deletedFromTheSyncRoot(String item);

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @detectedStorage.
  ///
  /// In en, this message translates to:
  /// **'Detected storage'**
  String get detectedStorage;

  /// No description provided for @everythingIsAlreadyInSync.
  ///
  /// In en, this message translates to:
  /// **'Everything is already in sync.'**
  String get everythingIsAlreadyInSync;

  /// No description provided for @folderSelectionCouldNotBeSaved.
  ///
  /// In en, this message translates to:
  /// **'Folder selection could not be saved'**
  String get folderSelectionCouldNotBeSaved;

  /// No description provided for @gameCatalog.
  ///
  /// In en, this message translates to:
  /// **'Game Catalog'**
  String get gameCatalog;

  /// No description provided for @importJson.
  ///
  /// In en, this message translates to:
  /// **'Import JSON'**
  String get importJson;

  /// No description provided for @importPspGameCatalog.
  ///
  /// In en, this message translates to:
  /// **'Import PSP game catalog'**
  String get importPspGameCatalog;

  /// No description provided for @importedLldCatalogEntries.
  ///
  /// In en, this message translates to:
  /// **'Imported {count} catalog entries.'**
  String importedLldCatalogEntries(int count);

  /// No description provided for @lookingUpLldTitlesOnSerialstation.
  ///
  /// In en, this message translates to:
  /// **'Looking up {count} titles on SerialStation...'**
  String lookingUpLldTitlesOnSerialstation(int count);

  /// No description provided for @noPspStorageRootSelected.
  ///
  /// In en, this message translates to:
  /// **'No PSP storage root selected'**
  String get noPspStorageRootSelected;

  /// No description provided for @noPspStorageRootWithPspSavedataDetected.
  ///
  /// In en, this message translates to:
  /// **'No PSP storage root with PSP/SAVEDATA detected.'**
  String get noPspStorageRootWithPspSavedataDetected;

  /// No description provided for @noPspStorageSelected.
  ///
  /// In en, this message translates to:
  /// **'No PSP storage selected.'**
  String get noPspStorageSelected;

  /// No description provided for @noSavesFound.
  ///
  /// In en, this message translates to:
  /// **'No Saves Found'**
  String get noSavesFound;

  /// No description provided for @noBackupsSaved.
  ///
  /// In en, this message translates to:
  /// **'No backups saved.'**
  String get noBackupsSaved;

  /// No description provided for @noSyncRootSelected.
  ///
  /// In en, this message translates to:
  /// **'No sync root selected'**
  String get noSyncRootSelected;

  /// No description provided for @notSelectedForSync.
  ///
  /// In en, this message translates to:
  /// **'Not selected for sync'**
  String get notSelectedForSync;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @onlyInSync.
  ///
  /// In en, this message translates to:
  /// **'Only in sync'**
  String get onlyInSync;

  /// No description provided for @onlyOnPsp.
  ///
  /// In en, this message translates to:
  /// **'Only on PSP'**
  String get onlyOnPsp;

  /// No description provided for @psp.
  ///
  /// In en, this message translates to:
  /// **'PSP'**
  String get psp;

  /// No description provided for @pspStorage.
  ///
  /// In en, this message translates to:
  /// **'PSP Storage'**
  String get pspStorage;

  /// No description provided for @pspNewer.
  ///
  /// In en, this message translates to:
  /// **'PSP newer'**
  String get pspNewer;

  /// No description provided for @pspStorageDetectedChooseItToGrantAccess.
  ///
  /// In en, this message translates to:
  /// **'PSP storage detected. Choose it to grant access.'**
  String get pspStorageDetectedChooseItToGrantAccess;

  /// No description provided for @pspStorageRequired.
  ///
  /// In en, this message translates to:
  /// **'PSP storage required'**
  String get pspStorageRequired;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @quitWhileSyncIsRunning.
  ///
  /// In en, this message translates to:
  /// **'Quit while sync is running?'**
  String get quitWhileSyncIsRunning;

  /// No description provided for @rescanPspStorageRootAndSyncRoot.
  ///
  /// In en, this message translates to:
  /// **'Rescan PSP storage root and sync root'**
  String get rescanPspStorageRootAndSyncRoot;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @restoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreBackup;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed'**
  String get restoreFailed;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Restored {item}.'**
  String restored(String item);

  /// No description provided for @saveGames.
  ///
  /// In en, this message translates to:
  /// **'Save Games'**
  String get saveGames;

  /// No description provided for @savedBackups.
  ///
  /// In en, this message translates to:
  /// **'Saved backups'**
  String get savedBackups;

  /// No description provided for @savedFoldersCouldNotBeRestored.
  ///
  /// In en, this message translates to:
  /// **'Saved folders could not be restored'**
  String get savedFoldersCouldNotBeRestored;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @scanFailed.
  ///
  /// In en, this message translates to:
  /// **'Scan failed.'**
  String get scanFailed;

  /// No description provided for @searchSerialstationApi.
  ///
  /// In en, this message translates to:
  /// **'Search SerialStation API'**
  String get searchSerialstationApi;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @selectPspStorageBeforeSyncing.
  ///
  /// In en, this message translates to:
  /// **'Select PSP storage before syncing.'**
  String get selectPspStorageBeforeSyncing;

  /// No description provided for @selectPspStorageRoot.
  ///
  /// In en, this message translates to:
  /// **'Select PSP storage root'**
  String get selectPspStorageRoot;

  /// No description provided for @selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata.
  ///
  /// In en, this message translates to:
  /// **'Select a PSP storage root with PSP/SAVEDATA and a sync root that contains or will contain PSP/SAVEDATA.'**
  String
  get selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata;

  /// No description provided for @selectABackupBeforeRestoring.
  ///
  /// In en, this message translates to:
  /// **'Select a backup before restoring.'**
  String get selectABackupBeforeRestoring;

  /// No description provided for @selectASyncRootBeforeRestoringABackup.
  ///
  /// In en, this message translates to:
  /// **'Select a sync root before restoring a backup.'**
  String get selectASyncRootBeforeRestoringABackup;

  /// No description provided for @selectASyncRootBeforeSyncing.
  ///
  /// In en, this message translates to:
  /// **'Select a sync root before syncing.'**
  String get selectASyncRootBeforeSyncing;

  /// No description provided for @selectSyncRoot.
  ///
  /// In en, this message translates to:
  /// **'Select sync root'**
  String get selectSyncRoot;

  /// No description provided for @selectedForSync.
  ///
  /// In en, this message translates to:
  /// **'Selected for sync'**
  String get selectedForSync;

  /// No description provided for @serialstationReturnedHttpLld.
  ///
  /// In en, this message translates to:
  /// **'SerialStation returned HTTP {count}.'**
  String serialstationReturnedHttpLld(int count);

  /// No description provided for @serialstationReturnedAnInvalidResponse.
  ///
  /// In en, this message translates to:
  /// **'SerialStation returned an invalid response.'**
  String get serialstationReturnedAnInvalidResponse;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync {item}'**
  String sync(String item);

  /// No description provided for @syncRoot.
  ///
  /// In en, this message translates to:
  /// **'Sync Root'**
  String get syncRoot;

  /// No description provided for @syncSelected.
  ///
  /// In en, this message translates to:
  /// **'Sync Selected'**
  String get syncSelected;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncFailed;

  /// No description provided for @syncNewer.
  ///
  /// In en, this message translates to:
  /// **'Sync newer'**
  String get syncNewer;

  /// No description provided for @syncRootRequired.
  ///
  /// In en, this message translates to:
  /// **'Sync root required'**
  String get syncRootRequired;

  /// No description provided for @syncSelectedSavesByCopyingTheNewestOrMissingSaveFolderToTheOtherSide.
  ///
  /// In en, this message translates to:
  /// **'Sync selected saves by copying the newest or missing save folder to the other side'**
  String
  get syncSelectedSavesByCopyingTheNewestOrMissingSaveFolderToTheOtherSide;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @syncedLldSaveFolders.
  ///
  /// In en, this message translates to:
  /// **'Synced {count} save folders.'**
  String syncedLldSaveFolders(int count);

  /// No description provided for @thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {item} from PSP storage and the sync root.'**
  String thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot(String item);

  /// No description provided for @thisWillPermanentlyDeleteFromPspStorage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {item} from PSP storage.'**
  String thisWillPermanentlyDeleteFromPspStorage(String item);

  /// No description provided for @thisWillPermanentlyDeleteFromTheSyncRoot.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete {item} from the sync root.'**
  String thisWillPermanentlyDeleteFromTheSyncRoot(String item);

  /// No description provided for @thisWillReplaceTheCurrentSyncRootContentsWith.
  ///
  /// In en, this message translates to:
  /// **'This will replace the current sync root contents with {item}.'**
  String thisWillReplaceTheCurrentSyncRootContentsWith(String item);

  /// No description provided for @missing.
  ///
  /// In en, this message translates to:
  /// **'missing'**
  String get missing;

  /// No description provided for @wpspsync.
  ///
  /// In en, this message translates to:
  /// **'wPSPsync'**
  String get wpspsync;

  /// No description provided for @wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated.
  ///
  /// In en, this message translates to:
  /// **'wPSPsync is currently copying save folders. Quitting now may leave the PSP storage or sync root partially updated.'**
  String
  get wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated;

  /// No description provided for @filterByNameOrGameId.
  ///
  /// In en, this message translates to:
  /// **'Filter by name or game ID…'**
  String get filterByNameOrGameId;

  /// No description provided for @noResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{item}\"'**
  String noResultsFor(String item);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'ja',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
