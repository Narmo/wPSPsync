import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_model.dart';
import 'save_row.dart';

class SaveListView extends StatelessWidget {
  const SaveListView({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();

    return Column(
      children: [
        // Header with title and select all/none
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            children: [
              const Text(
                'Save Games',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: model.rows.isEmpty
                    ? null
                    : () {
                        if (model.selectedRowIDs.length == model.rows.length) {
                          model.clearSelection();
                        } else {
                          model.selectAllRows();
                        }
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF323235),
                  side: const BorderSide(color: Colors.white10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 24),
                ),
                child: Text(
                  model.selectedRowIDs.length == model.rows.length
                      ? 'Deselect All'
                      : 'Select All',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // List or Empty View
        Expanded(
          child: model.rows.isEmpty
              ? _buildEmptyView(context)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: model.rows.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final row = model.rows[index];
                    return SaveRow(row: row);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.memory_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Saves Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Select a PSP storage root with PSP/SAVEDATA and a sync root that contains or will contain PSP/SAVEDATA.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
