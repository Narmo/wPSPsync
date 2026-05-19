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


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_model.dart';
import '../l10n/app_localizations.dart';
import '../models/models.dart';
import 'save_row.dart';

class SaveListView extends StatefulWidget {
  const SaveListView({super.key});

  @override
  State<SaveListView> createState() => _SaveListViewState();
}

class _SaveListViewState extends State<SaveListView> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SaveComparison> _applyFilter(List<SaveComparison> rows) {
    if (_query.isEmpty) return rows;
    final q = _query.toLowerCase();
    return rows.where((row) {
      final nameMatch = row.displayTitle.toLowerCase().contains(q);
      final idMatch = row.folderName.toLowerCase().contains(q);
      return nameMatch || idMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();
    final loc = AppLocalizations.of(context)!;
    final hasRows = model.rows.isNotEmpty;
    final filtered = _applyFilter(model.rows);

    return Column(
      children: [
        // Header with title and select all/none
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            children: [
              Text(
                loc.saveGames,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
                      ? loc.deselectAll
                      : loc.selectAll,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),

        // Search Box — only visible when there are saves
        if (hasRows)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
            child: SizedBox(
              height: 32,
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                style: const TextStyle(fontSize: 13, color: Colors.white),
                cursorColor: Colors.white54,
                decoration: InputDecoration(
                  hintText: loc.filterByNameOrGameId,
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, size: 16, color: Colors.white38),
                  suffixIcon: _query.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          child: const Icon(Icons.close, size: 14, color: Colors.white38),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E1E22),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Colors.white30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),
          ),

        // List or Empty View
        Expanded(
          child: !hasRows
              ? _buildEmptyView(context)
              : filtered.isEmpty
                  ? _buildNoResultsView(context)
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = filtered[index];
                        return SaveRow(row: row);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyView(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
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
          Text(
            loc.noSavesFound,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              loc.selectAPspStorageRootWithPspSavedataAndASyncRootThatContainsOrWillContainPspSavedata,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            loc.noResultsFor(_query),
            style: const TextStyle(fontSize: 15, color: Colors.white54),
          ),
        ],
      ),
    );
  }
}