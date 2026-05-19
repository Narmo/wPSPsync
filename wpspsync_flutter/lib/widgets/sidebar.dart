//
// Copyright (c) 2026 Nikita Denin <nik@brite-apps.com>
// Copyright (c) 2026 OniMock <onimock@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/app_model.dart';

String _getTranslatedStatus(AppLocalizations loc, String message) {
  if (message == "Choose a PSP storage root and a sync root.") return loc.chooseAPspStorageRootAndASyncRoot;
  if (message == "No PSP storage selected.") return loc.noPspStorageSelected;
  if (message == "PSP storage detected. Choose it to grant access.") return loc.pspStorageDetectedChooseItToGrantAccess;
  if (message == "No PSP storage root with PSP/SAVEDATA detected.") return loc.noPspStorageRootWithPspSavedataDetected;
  if (message == "Everything is already in sync.") return loc.everythingIsAlreadyInSync;
  
  // Regex matches
  final lookingUpMatch = RegExp(r'Looking up (\d+) titles').firstMatch(message);
  if (lookingUpMatch != null) {
    return loc.lookingUpLldTitlesOnSerialstation(int.parse(lookingUpMatch.group(1)!));
  }
  
  final foundMatch = RegExp(r'(\d+) save folders found').firstMatch(message);
  if (foundMatch != null) {
    return loc.lldSaveFoldersFound(int.parse(foundMatch.group(1)!));
  }
  
  final syncedMatch = RegExp(r'Synced (\d+) save folders').firstMatch(message);
  if (syncedMatch != null) {
    return loc.syncedLldSaveFolders(int.parse(syncedMatch.group(1)!));
  }
  
  final importedMatch = RegExp(r'Imported (\d+) catalog entries').firstMatch(message);
  if (importedMatch != null) {
    return loc.importedLldCatalogEntries(int.parse(importedMatch.group(1)!));
  }
  
  return message;
}

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();
    final loc = AppLocalizations.of(context)!;

    return Container(
      width: 280,
      color: const Color(0xFF1E1E22), // Matching macOS sidebar dark color
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Logo and Title Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/icon_composite.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.wpspsync,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    Text(
                      _getTranslatedStatus(loc, model.statusMessage),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Scrollable sections
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PSP Storage Section
                  SectionHeader(
                    title: loc.pspStorage,
                    icon: Icons.usb,
                  ),
                  const SizedBox(height: 8),
                  PathChip(
                    path: model.selectedExternalRoot?.path,
                    placeholder: loc.noPspStorageRootSelected,
                  ),
                  const SizedBox(height: 6),
                  if (model.externalCandidates.isEmpty) ...[
                    Text(
                      loc.noPspStorageRootWithPspSavedataDetected,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                  ],
                  _ActionButton(
                    icon: Icons.folder_outlined,
                    label: loc.choosePspRoot,
                    onPressed: () => model.selectExternalRoot(title: loc.selectPspStorageRoot),
                  ),
                  const SizedBox(height: 24),

                  // Sync Root Section
                  SectionHeader(
                    title: loc.syncRoot,
                    icon: Icons.cloud_upload_outlined,
                  ),
                  const SizedBox(height: 8),
                  PathChip(
                    path: model.selectedSyncRoot?.path,
                    placeholder: loc.noSyncRootSelected,
                  ),
                  const SizedBox(height: 6),
                  _ActionButton(
                    icon: Icons.folder_special_outlined,
                    label: loc.chooseSyncRoot,
                    onPressed: () => model.selectSyncRoot(title: loc.syncRoot),
                  ),
                  const SizedBox(height: 24),

                  // Game Catalog Section
                  SectionHeader(
                    title: loc.gameCatalog,
                    icon: Icons.bar_chart_outlined,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    loc.lldTitleEntriesLoaded(model.catalog.games.length),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  _MacCheckbox(
                    label: loc.searchSerialstationApi,
                    value: model.useSerialStationAPI,
                    onChanged: (val) => model.toggleSerialStation(val!),
                  ),
                  const SizedBox(height: 6),
                  _ActionButton(
                    icon: Icons.file_download_outlined,
                    label: loc.importJson,
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                        dialogTitle: loc.importPspGameCatalog,
                      );
                      if (result != null && result.files.single.path != null) {
                        await model.importCatalog(File(result.files.single.path!));
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Backups Section
                  SectionHeader(
                    title: loc.backups,
                    icon: Icons.archive_outlined,
                  ),
                  const SizedBox(height: 8),
                  _MacCheckbox(
                    label: loc.createBackupBeforeWriting,
                    value: model.backupsEnabled,
                    onChanged: (val) => model.toggleBackups(val!),
                  ),
                  const SizedBox(height: 6),
                  if (model.backups.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(loc.noBackupsSaved, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    )
                  else
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF323235),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: model.selectedBackupId,
                          iconSize: 16,
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                          dropdownColor: const Color(0xFF323235),
                          items: model.backups.map((b) {
                            return DropdownMenuItem(
                              value: b.id,
                              child: Text(b.title),
                            );
                          }).toList(),
                          onChanged: (val) => model.setSelectedBackupId(val),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  _ActionButton(
                    icon: Icons.settings_backup_restore,
                    label: loc.restoreBackup.replaceAll('?', ''), // Temporary fix if string has ?
                    onPressed: (model.selectedSyncRoot == null || model.selectedBackupId == null || model.isWorking)
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(loc.restoreBackup),
                                content: Text(loc.thisWillReplaceTheCurrentSyncRootContentsWith(model.backups.firstWhere((b) => b.id == model.selectedBackupId).title)),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.restore)),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await model.restoreSelectedBackup();
                            }
                          },
                  ),
                ],
              ),
            ),
          ),

          // Activity Indicator
          if (model.isWorking)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }
}

class PathChip extends StatelessWidget {
  final String? path;
  final String placeholder;

  const PathChip({super.key, this.path, required this.placeholder});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF38383F),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_outlined, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              path ?? placeholder,
              style: TextStyle(
                fontSize: 12,
                color: path == null ? Colors.white54 : Colors.white,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _ActionButton({required this.icon, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        side: const BorderSide(color: Colors.white10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        minimumSize: const Size(0, 26),
      ),
      icon: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _MacCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _MacCheckbox({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      canRequestFocus: false,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) return Colors.blue;
                return Colors.transparent;
              }),
              side: const BorderSide(color: Colors.white54, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }
}