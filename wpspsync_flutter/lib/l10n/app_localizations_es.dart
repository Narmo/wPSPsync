// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String lldSaveFoldersFound(int count) {
    return '$count carpetas de guardado encontradas.';
  }

  @override
  String lldTitleEntriesLoaded(int count) {
    return '$count entradas de títulos cargadas';
  }

  @override
  String get archiveCommandFailed => 'Error al crear o restaurar el archivo.';

  @override
  String get backupRequired => 'Se requiere una copia de seguridad';

  @override
  String get backups => 'Copias de seguridad';

  @override
  String get backupsCouldNotBeLoaded =>
      'No se pudieron cargar las copias de seguridad';

  @override
  String get cancel => 'Cancelar';

  @override
  String get catalogCouldNotBeLoaded => 'No se pudo cargar el catálogo';

  @override
  String get catalogImportFailed => 'Error al importar el catálogo';

  @override
  String get choosePspRoot => 'Elegir raíz de PSP';

  @override
  String get chooseSyncRoot => 'Elegir raíz de sincronización';

  @override
  String get chooseAPspStorageRootAndASyncRoot =>
      'Elija una raíz de almacenamiento PSP y una raíz de sincronización.';

  @override
  String
  get chooseTheTopLevelPspVolumeOrMemoryCardFolderThatContainsPspSavedata =>
      'Elija el volumen PSP o la carpeta de tarjeta de memoria de nivel superior que contiene PSP/SAVEDATA.';

  @override
  String get chooseTheTopLevelFolderThatContainsOrWillContainPspSavedata =>
      'Elija la carpeta de nivel superior que contiene o contendrá PSP/SAVEDATA.';

  @override
  String get createBackupBeforeWriting =>
      'Crear copia de seguridad antes de escribir';

  @override
  String createdBackup(String item) {
    return 'Copia de seguridad creada: $item.';
  }

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteBoth => 'Eliminar ambas';

  @override
  String get deleteBothCopies => '¿Eliminar ambas copias?';

  @override
  String get deleteFailed => 'Error al eliminar';

  @override
  String get deleteFromPspStorage => '¿Eliminar del almacenamiento PSP?';

  @override
  String get deleteFromSyncRoot => '¿Eliminar de la raíz de sincronización?';

  @override
  String deletedFromPspStorage(String item) {
    return '$item eliminado del almacenamiento PSP.';
  }

  @override
  String deletedFromBothSides(String item) {
    return '$item eliminado de ambos lados.';
  }

  @override
  String deletedFromTheSyncRoot(String item) {
    return '$item eliminado de la raíz de sincronización.';
  }

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String get detectedStorage => 'Almacenamiento detectado';

  @override
  String get everythingIsAlreadyInSync => 'Todo ya está sincronizado.';

  @override
  String get folderSelectionCouldNotBeSaved =>
      'No se pudo guardar la selección de carpeta';

  @override
  String get gameCatalog => 'Catálogo de juegos';

  @override
  String get importJson => 'Importar JSON';

  @override
  String get importPspGameCatalog => 'Importar catálogo de juegos PSP';

  @override
  String importedLldCatalogEntries(int count) {
    return '$count entradas del catálogo importadas.';
  }

  @override
  String lookingUpLldTitlesOnSerialstation(int count) {
    return 'Buscando $count títulos en SerialStation...';
  }

  @override
  String get noPspStorageRootSelected =>
      'No se seleccionó una raíz de almacenamiento PSP';

  @override
  String get noPspStorageRootWithPspSavedataDetected =>
      'No se detectó una raíz de almacenamiento PSP con PSP/SAVEDATA.';

  @override
  String get noPspStorageSelected => 'No se seleccionó almacenamiento PSP.';

  @override
  String get noSavesFound => 'No se encontraron partidas guardadas';

  @override
  String get noBackupsSaved => 'No hay copias de seguridad guardadas.';

  @override
  String get noSyncRootSelected =>
      'No se seleccionó una raíz de sincronización';

  @override
  String get notSelectedForSync => 'No seleccionado para sincronizar';

  @override
  String get ok => 'Aceptar';

  @override
  String get onlyInSync => 'Solo en sincronización';

  @override
  String get onlyOnPsp => 'Solo en PSP';

  @override
  String get psp => 'PSP';

  @override
  String get pspStorage => 'Almacenamiento PSP';

  @override
  String get pspNewer => 'PSP más reciente';

  @override
  String get pspStorageDetectedChooseItToGrantAccess =>
      'Almacenamiento PSP detectado. Selecciónelo para conceder acceso.';

  @override
  String get pspStorageRequired => 'Se requiere almacenamiento PSP';

  @override
  String get quit => 'Salir';

  @override
  String get quitWhileSyncIsRunning =>
      '¿Salir mientras la sincronización está en curso?';

  @override
  String get rescanPspStorageRootAndSyncRoot =>
      'Volver a escanear la raíz de almacenamiento PSP y la raíz de sincronización';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreBackup => '¿Restaurar copia de seguridad?';

  @override
  String get restoreFailed => 'Error al restaurar';

  @override
  String restored(String item) {
    return '$item restaurado.';
  }

  @override
  String get saveGames => 'Partidas guardadas';

  @override
  String get savedBackups => 'Copias guardadas';

  @override
  String get savedFoldersCouldNotBeRestored =>
      'No se pudieron restaurar las carpetas guardadas';

  @override
  String get scan => 'Escanear';

  @override
  String get scanFailed => 'Error al escanear.';

  @override
  String get searchSerialstationApi => 'Buscar en la API de SerialStation';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get selectPspStorageBeforeSyncing =>
      'Seleccione almacenamiento PSP antes de sincronizar.';

  @override
  String get selectPspStorageRoot => 'Seleccionar raíz de almacenamiento PSP';

  @override
  String
  get selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata =>
      'Seleccione una raíz de almacenamiento PSP con PSP/SAVEDATA y una raíz de sincronización que contenga o contendrá PSP/SAVEDATA.';

  @override
  String get selectABackupBeforeRestoring =>
      'Seleccione una copia de seguridad antes de restaurar.';

  @override
  String get selectASyncRootBeforeRestoringABackup =>
      'Seleccione una raíz de sincronización antes de restaurar una copia.';

  @override
  String get selectASyncRootBeforeSyncing =>
      'Seleccione una raíz de sincronización antes de sincronizar.';

  @override
  String get selectSyncRoot => 'Seleccionar raíz de sincronización';

  @override
  String get selectedForSync => 'Seleccionado para sincronizar';

  @override
  String serialstationReturnedHttpLld(int count) {
    return 'SerialStation devolvió HTTP $count.';
  }

  @override
  String get serialstationReturnedAnInvalidResponse =>
      'SerialStation devolvió una respuesta no válida.';

  @override
  String sync(String item) {
    return 'Sincronizar $item';
  }

  @override
  String get syncRoot => 'Raíz de sincronización';

  @override
  String get syncSelected => 'Sincronizar seleccionados';

  @override
  String get syncFailed => 'Error al sincronizar';

  @override
  String get syncNewer => 'Sincronización más reciente';

  @override
  String get syncRootRequired => 'Se requiere una raíz de sincronización';

  @override
  String
  get syncSelectedSavesByCopyingTheNewestOrMissingSaveFolderToTheOtherSide =>
      'Sincroniza las partidas seleccionadas copiando la carpeta de guardado más reciente o faltante al otro lado';

  @override
  String get synced => 'Sincronizado';

  @override
  String syncedLldSaveFolders(int count) {
    return '$count carpetas de guardado sincronizadas.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot(String item) {
    return 'Esto eliminará permanentemente $item del almacenamiento PSP y de la raíz de sincronización.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorage(String item) {
    return 'Esto eliminará permanentemente $item del almacenamiento PSP.';
  }

  @override
  String thisWillPermanentlyDeleteFromTheSyncRoot(String item) {
    return 'Esto eliminará permanentemente $item de la raíz de sincronización.';
  }

  @override
  String thisWillReplaceTheCurrentSyncRootContentsWith(String item) {
    return 'Esto reemplazará el contenido actual de la raíz de sincronización con $item.';
  }

  @override
  String get missing => 'falta';

  @override
  String get wpspsync => 'wPSPsync';

  @override
  String
  get wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated =>
      'wPSPsync está copiando carpetas de partidas guardadas. Si sales ahora, el almacenamiento PSP o la raíz de sincronización pueden quedar actualizados parcialmente.';

  @override
  String get filterByNameOrGameId => 'Filtrar por nombre o ID…';

  @override
  String noResultsFor(String item) {
    return 'Sin resultados para \"$item\"';
  }
}
