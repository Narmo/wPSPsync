// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String lldSaveFoldersFound(int count) {
    return '$count pastas de save encontradas.';
  }

  @override
  String lldTitleEntriesLoaded(int count) {
    return '$count entradas de títulos carregadas';
  }

  @override
  String get archiveCommandFailed => 'Falha no comando de arquivamento.';

  @override
  String get backupRequired => 'Backup obrigatório';

  @override
  String get backups => 'Backups';

  @override
  String get backupsCouldNotBeLoaded => 'Não foi possível carregar os backups';

  @override
  String get cancel => 'Cancelar';

  @override
  String get catalogCouldNotBeLoaded => 'Não foi possível carregar o catálogo';

  @override
  String get catalogImportFailed => 'Falha ao importar catálogo';

  @override
  String get choosePspRoot => 'Escolher Raiz do PSP';

  @override
  String get chooseSyncRoot => 'Escolher Raiz de Sincronização';

  @override
  String get chooseAPspStorageRootAndASyncRoot =>
      'Escolha a raiz de armazenamento do PSP e a raiz de sincronização.';

  @override
  String
  get chooseTheTopLevelPspVolumeOrMemoryCardFolderThatContainsPspSavedata =>
      'Escolha o volume do PSP ou pasta do cartão de memória de nível superior que contém PSP/SAVEDATA.';

  @override
  String get chooseTheTopLevelFolderThatContainsOrWillContainPspSavedata =>
      'Escolha a pasta de nível superior que contém ou conterá PSP/SAVEDATA.';

  @override
  String get createBackupBeforeWriting => 'Criar backup antes de gravar';

  @override
  String createdBackup(String item) {
    return 'Backup criado: $item.';
  }

  @override
  String get delete => 'Excluir';

  @override
  String get deleteBoth => 'Excluir Ambos';

  @override
  String get deleteBothCopies => 'Excluir ambas as cópias?';

  @override
  String get deleteFailed => 'Falha ao excluir';

  @override
  String get deleteFromPspStorage => 'Excluir do armazenamento do PSP?';

  @override
  String get deleteFromSyncRoot => 'Excluir da raiz de sincronização?';

  @override
  String deletedFromPspStorage(String item) {
    return 'Excluído $item do armazenamento do PSP.';
  }

  @override
  String deletedFromBothSides(String item) {
    return 'Excluído $item de ambos os lados.';
  }

  @override
  String deletedFromTheSyncRoot(String item) {
    return 'Excluído $item da raiz de sincronização.';
  }

  @override
  String get deselectAll => 'Desmarcar Todos';

  @override
  String get detectedStorage => 'Armazenamento detectado';

  @override
  String get everythingIsAlreadyInSync => 'Tudo já está sincronizado.';

  @override
  String get folderSelectionCouldNotBeSaved =>
      'A seleção da pasta não pôde ser salva';

  @override
  String get gameCatalog => 'Catálogo de Jogos';

  @override
  String get importJson => 'Importar JSON';

  @override
  String get importPspGameCatalog => 'Importar catálogo de jogos do PSP';

  @override
  String importedLldCatalogEntries(int count) {
    return '$count entradas do catálogo importadas.';
  }

  @override
  String lookingUpLldTitlesOnSerialstation(int count) {
    return 'Buscando $count títulos no SerialStation...';
  }

  @override
  String get noPspStorageRootSelected =>
      'Nenhuma raiz de armazenamento do PSP selecionada';

  @override
  String get noPspStorageRootWithPspSavedataDetected =>
      'Nenhuma raiz de armazenamento com PSP/SAVEDATA detectada.';

  @override
  String get noPspStorageSelected => 'Nenhum armazenamento de PSP selecionado.';

  @override
  String get noSavesFound => 'Nenhum Save Encontrado';

  @override
  String get noBackupsSaved => 'Nenhum backup salvo.';

  @override
  String get noSyncRootSelected => 'Nenhuma raiz de sincronização selecionada';

  @override
  String get notSelectedForSync => 'Não selecionado para sincronização';

  @override
  String get ok => 'OK';

  @override
  String get onlyInSync => 'Apenas na sincronização';

  @override
  String get onlyOnPsp => 'Apenas no PSP';

  @override
  String get psp => 'PSP';

  @override
  String get pspStorage => 'Armazenamento do PSP';

  @override
  String get pspNewer => 'PSP mais recente';

  @override
  String get pspStorageDetectedChooseItToGrantAccess =>
      'Armazenamento do PSP detectado. Selecione-o para conceder acesso.';

  @override
  String get pspStorageRequired => 'Armazenamento do PSP obrigatório';

  @override
  String get quit => 'Sair';

  @override
  String get quitWhileSyncIsRunning =>
      'Sair enquanto a sincronização está em andamento?';

  @override
  String get rescanPspStorageRootAndSyncRoot =>
      'Verificar novamente a raiz do PSP e a raiz de sincronização';

  @override
  String get restore => 'Restaurar';

  @override
  String get restoreBackup => 'Restaurar backup?';

  @override
  String get restoreFailed => 'Falha ao restaurar';

  @override
  String restored(String item) {
    return 'Restaurado: $item.';
  }

  @override
  String get saveGames => 'Saves de Jogos';

  @override
  String get savedBackups => 'Backups salvos';

  @override
  String get savedFoldersCouldNotBeRestored =>
      'Não foi possível restaurar as pastas salvas';

  @override
  String get scan => 'Verificar';

  @override
  String get scanFailed => 'Falha na verificação.';

  @override
  String get searchSerialstationApi => 'Buscar na API SerialStation';

  @override
  String get selectAll => 'Selecionar Todos';

  @override
  String get selectPspStorageBeforeSyncing =>
      'Selecione o armazenamento do PSP antes de sincronizar.';

  @override
  String get selectPspStorageRoot => 'Selecione a raiz de armazenamento do PSP';

  @override
  String
  get selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata =>
      'Selecione a raiz de armazenamento do PSP contendo PSP/SAVEDATA e uma raiz de sincronização.';

  @override
  String get selectABackupBeforeRestoring =>
      'Selecione um backup antes de restaurar.';

  @override
  String get selectASyncRootBeforeRestoringABackup =>
      'Selecione uma raiz de sincronização antes de restaurar o backup.';

  @override
  String get selectASyncRootBeforeSyncing =>
      'Selecione uma raiz de sincronização antes de sincronizar.';

  @override
  String get selectSyncRoot => 'Selecionar raiz de sincronização';

  @override
  String get selectedForSync => 'Selecionado para sincronização';

  @override
  String serialstationReturnedHttpLld(int count) {
    return 'SerialStation retornou HTTP $count.';
  }

  @override
  String get serialstationReturnedAnInvalidResponse =>
      'SerialStation retornou uma resposta inválida.';

  @override
  String sync(String item) {
    return 'Sincronizar $item';
  }

  @override
  String get syncRoot => 'Raiz de Sincronização';

  @override
  String get syncSelected => 'Sincronizar Selecionados';

  @override
  String get syncFailed => 'Falha na sincronização';

  @override
  String get syncNewer => 'Sincronização mais recente';

  @override
  String get syncRootRequired => 'Raiz de sincronização obrigatória';

  @override
  String
  get syncSelectedSavesByCopyingTheNewestOrMissingSaveFolderToTheOtherSide =>
      'Sincronize os saves copiando as pastas mais recentes ou ausentes para o outro lado';

  @override
  String get synced => 'Sincronizado';

  @override
  String syncedLldSaveFolders(int count) {
    return 'Sincronizadas $count pastas de saves.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot(String item) {
    return 'Isso excluirá permanentemente $item do armazenamento do PSP e da raiz de sincronização.';
  }

  @override
  String thisWillPermanentlyDeleteFromPspStorage(String item) {
    return 'Isso excluirá permanentemente $item do armazenamento do PSP.';
  }

  @override
  String thisWillPermanentlyDeleteFromTheSyncRoot(String item) {
    return 'Isso excluirá permanentemente $item da raiz de sincronização.';
  }

  @override
  String thisWillReplaceTheCurrentSyncRootContentsWith(String item) {
    return 'Isso substituirá o conteúdo atual da raiz de sincronização por $item.';
  }

  @override
  String get missing => 'ausente';

  @override
  String get wpspsync => 'wPSPsync';

  @override
  String
  get wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated =>
      'O wPSPsync está copiando as pastas. Sair agora pode deixar o PSP ou a raiz de sincronização atualizados pela metade.';

  @override
  String get filterByNameOrGameId => 'Filtrar por nome ou ID…';

  @override
  String noResultsFor(String item) {
    return 'Sem resultados para \"$item\"';
  }
}
