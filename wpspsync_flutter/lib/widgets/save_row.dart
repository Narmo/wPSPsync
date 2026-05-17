import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/app_model.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'save_icon.dart';

class SaveRow extends StatelessWidget {
  final SaveComparison row;

  const SaveRow({super.key, required this.row});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();
    final isSelected = model.selectedRowIDs.contains(row.id);

    return GestureDetector(
      onSecondaryTapDown: (details) => _showContextMenu(context, model, details.globalPosition),
      child: InkWell(
        onTap: () => model.toggleSelection(row.id),
        canRequestFocus: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Checkbox for sync selection
              SizedBox(
                width: 32,
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => model.toggleSelection(row.id),
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) return Colors.blue;
                        return Colors.transparent;
                      }),
                      side: const BorderSide(color: Colors.white54, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Save Icon
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 52,
                  height: 30, // PSP exact save data icon aspect ratio is 144x80 (1.8)
                  child: SaveIcon(
                    localUrl: row.iconUrl,
                    remoteUrl: row.coverUrl,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Save Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            row.displayTitle,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StateBadge(state: row.state),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(row.gameId, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(width: 12),
                        if (row.latestModifiedAt != null)
                          Text(
                            DateFormat.yMMMd(Localizations.localeOf(context).toString()).add_jm().format(row.latestModifiedAt!),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        const SizedBox(width: 12),
                        Text(
                          _formatSize(row.size),
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Modification Dates per side
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _DateLabel(title: AppLocalizations.of(context)!.psp, date: row.psp?.modifiedAt),
                  const SizedBox(height: 2),
                  _DateLabel(title: AppLocalizations.of(context)!.sync('').trim(), date: row.sync?.modifiedAt),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context, AppModel model, Offset position) async {
    final loc = AppLocalizations.of(context)!;
    final items = <PopupMenuEntry<int>>[];
    
    if (row.psp != null) {
      items.add(PopupMenuItem(value: 1, child: Text(loc.deleteFromPspStorage.replaceAll('?', ''))));
    }
    if (row.sync != null) {
      items.add(PopupMenuItem(value: 2, child: Text(loc.deleteFromSyncRoot.replaceAll('?', ''))));
    }
    if (row.psp != null && row.sync != null) {
      items.add(PopupMenuItem(value: 3, child: Text(loc.deleteBoth)));
    }

    if (items.isEmpty) return;

    final value = await showMenu<int>(
      context: context,
      position: RelativeRect.fromLTRB(position.dx, position.dy, position.dx, position.dy),
      items: items,
    );

    if (value == null || !context.mounted) return;

    String contentText = '';
    if (value == 1) contentText = loc.thisWillPermanentlyDeleteFromPspStorage(row.displayTitle);
    if (value == 2) contentText = loc.thisWillPermanentlyDeleteFromTheSyncRoot(row.displayTitle);
    if (value == 3) contentText = loc.thisWillPermanentlyDeleteFromPspStorageAndTheSyncRoot(row.displayTitle);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.delete),
        content: Text(contentText),
        icon: const Icon(Icons.delete_forever, color: Colors.red, size: 48),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      switch (value) {
        case 1:
          await model.deletePSPSave(row);
          break;
        case 2:
          await model.deleteSyncSave(row);
          break;
        case 3:
          await model.deleteBothSaves(row);
          break;
      }
    }
  }

  String _formatSize(int bytes) {
    if (bytes == 0) return '0 KB';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class StateBadge extends StatelessWidget {
  final SaveState state;

  const StateBadge({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = '';
    final loc = AppLocalizations.of(context)!;

    switch (state) {
      case SaveState.same:
        bg = Colors.green.withValues(alpha: 0.16);
        fg = Colors.green;
        label = loc.synced;
        break;
      case SaveState.pspNewer:
        bg = Colors.blue.withValues(alpha: 0.16);
        fg = Colors.blue;
        label = loc.pspNewer;
        break;
      case SaveState.syncNewer:
        bg = Colors.orange.withValues(alpha: 0.18);
        fg = Colors.orange;
        label = loc.syncNewer;
        break;
      case SaveState.onlyPSP:
        bg = Colors.teal.withValues(alpha: 0.16);
        fg = Colors.tealAccent;
        label = loc.onlyOnPsp;
        break;
      case SaveState.onlySync:
        bg = Colors.purple.withValues(alpha: 0.16);
        fg = Colors.purpleAccent;
        label = loc.onlyInSync;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  final String title;
  final DateTime? date;

  const _DateLabel({required this.title, this.date});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 65,
          child: Text(title, textAlign: TextAlign.right, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey), maxLines: 1, overflow: TextOverflow.visible),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 100,
          child: Text(
            date != null 
                ? DateFormat.yMd(Localizations.localeOf(context).toString()).add_jm().format(date!) 
                : AppLocalizations.of(context)!.missing,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
