import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/app_model.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();

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
                    const Text(
                      'wPSPsync',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                    Text(
                      model.statusMessage,
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
                  const SectionHeader(
                    title: 'PSP Storage',
                    icon: Icons.usb,
                  ),
                  const SizedBox(height: 8),
                  PathChip(
                    path: model.selectedExternalRoot?.path,
                    placeholder: 'No PSP storage root selected',
                  ),
                  const SizedBox(height: 6),
                  if (model.externalCandidates.isEmpty) ...[
                    const Text(
                      'No PSP storage root with PSP/SAVEDATA detected.',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                  ],
                  _ActionButton(
                    icon: Icons.folder_outlined,
                    label: 'Choose PSP Root',
                    onPressed: () => model.selectExternalRoot(),
                  ),
                  const SizedBox(height: 24),

                  // Sync Root Section
                  const SectionHeader(
                    title: 'Sync Root',
                    icon: Icons.cloud_upload_outlined,
                  ),
                  const SizedBox(height: 8),
                  PathChip(
                    path: model.selectedSyncRoot?.path,
                    placeholder: 'No sync root selected',
                  ),
                  const SizedBox(height: 6),
                  _ActionButton(
                    icon: Icons.folder_special_outlined,
                    label: 'Choose Sync Root',
                    onPressed: () => model.selectSyncRoot(),
                  ),
                  const SizedBox(height: 24),

                  // Game Catalog Section
                  const SectionHeader(
                    title: 'Game Catalog',
                    icon: Icons.bar_chart_outlined,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${model.catalog.games.length} title entries loaded',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  _MacCheckbox(
                    label: 'Search SerialStation API',
                    value: model.useSerialStationAPI,
                    onChanged: (val) => model.toggleSerialStation(val!),
                  ),
                  const SizedBox(height: 6),
                  _ActionButton(
                    icon: Icons.file_download_outlined,
                    label: 'Import JSON',
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['json'],
                        dialogTitle: 'Import PSP game catalog',
                      );
                      if (result != null && result.files.single.path != null) {
                        await model.importCatalog(File(result.files.single.path!));
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Backups Section
                  const SectionHeader(
                    title: 'Backups',
                    icon: Icons.archive_outlined,
                  ),
                  const SizedBox(height: 8),
                  _MacCheckbox(
                    label: 'Create backup before writing',
                    value: model.backupsEnabled,
                    onChanged: (val) => model.toggleBackups(val!),
                  ),
                  const SizedBox(height: 6),
                  if (model.backups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text('No backups saved.', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                    label: 'Restore Backup',
                    onPressed: (model.selectedSyncRoot == null || model.selectedBackupId == null || model.isWorking)
                        ? null
                        : () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Restore backup?'),
                                content: const Text('This will replace the current sync root contents with the selected backup.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Restore')),
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
