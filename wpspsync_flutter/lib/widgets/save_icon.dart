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