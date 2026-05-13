import 'dart:io';
import 'package:flutter/material.dart';

class SaveIcon extends StatelessWidget {
  final Uri? localUrl;
  final Uri? remoteUrl;

  const SaveIcon({super.key, this.localUrl, this.remoteUrl});

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (localUrl != null) {
      content = Image.file(
        File(localUrl!.toFilePath()),
        fit: BoxFit.contain,
        errorBuilder: (context, e, s) => _buildPlaceholder(),
      );
    } else if (remoteUrl != null) {
      content = Image.network(
        remoteUrl!.toString(),
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, e, s) => _buildPlaceholder(),
      );
    } else {
      content = _buildPlaceholder();
    }

    return Container(
      width: 72,
      height: 40,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: content,
    );
  }

  Widget _buildPlaceholder() {
    return const Icon(Icons.sports_esports, size: 20, color: Colors.grey);
  }
}
