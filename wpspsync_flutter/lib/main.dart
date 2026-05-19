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
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'services/app_model.dart';
import 'widgets/sidebar.dart';
import 'widgets/save_list_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: const Size(1080, 700),
    minimumSize: const Size(1080, 700),
    center: true,
    title: 'wPSPsync',
    titleBarStyle: Platform.isMacOS ? TitleBarStyle.hidden : TitleBarStyle.normal,
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppModel(),
      child: const WPSPsyncApp(),
    ),
  );
}

class WPSPsyncApp extends StatelessWidget {
  const WPSPsyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wPSPsync',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E22), // macOS dark background
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          surface: const Color(0xFF28282D), // Content area
          surfaceContainerHighest: const Color(0xFF38383F), // Path fields
        ),
        checkboxTheme: CheckboxThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    windowManager.setPreventClose(true); // Intercept close events
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowClose() async {
    final model = context.read<AppModel>();
    final loc = AppLocalizations.of(context)!;
    
    if (model.isSyncing) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.quitWhileSyncIsRunning.replaceAll('?', '')),
          content: Text(loc.wpspsyncIsCurrentlyCopyingSaveFoldersQuittingNowMayLeaveThePspStorageOrSyncRootPartiallyUpdated),
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(loc.quit),
            ),
          ],
        ),
      );
      if (confirm == true) {
        await windowManager.destroy();
      }
    } else {
      await windowManager.destroy();
    }
  }

  void _scan(AppModel model) {
    if (!model.isWorking) {
      model.scan();
    }
  }

  void _syncSelected(AppModel model) {
    if (model.selectedRowIDs.isNotEmpty && 
        model.selectedExternalRoot != null && 
        model.selectedSyncRoot != null && 
        !model.isWorking) {
      model.syncSelected();
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AppModel>();
    final loc = AppLocalizations.of(context)!;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyR, control: true): () => _scan(model),
        const SingleActivator(LogicalKeyboardKey.keyR, meta: true): () => _scan(model),
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () => _syncSelected(model),
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () => _syncSelected(model),
      },
      child: Focus(
        autofocus: true,
        child: PlatformMenuBar(
          menus: _buildMenus(context, model),
          child: Material(
            color: const Color(0xFF1E1E22),
            child: Row(
              children: [
                const Sidebar(),
                const VerticalDivider(width: 1, thickness: 1, color: Colors.white10),
                Expanded(
                  child: Scaffold(
                    backgroundColor: const Color(0xFF28282D),
                    appBar: AppBar(
                      titleSpacing: 0,
                      toolbarHeight: 56,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          tooltip: '${loc.rescanPspStorageRootAndSyncRoot} (Cmd/Ctrl+R)',
                          onPressed: model.isWorking ? null : () => model.refreshVolumes(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.sync),
                          tooltip: '${loc.syncSelected} (Cmd/Ctrl+S)',
                          onPressed: (model.selectedRowIDs.isEmpty || 
                                      model.selectedExternalRoot == null || 
                                      model.selectedSyncRoot == null || 
                                      model.isWorking)
                              ? null
                              : () => model.syncSelected(),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                    body: const SaveListView(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<PlatformMenuItem> _buildMenus(BuildContext context, AppModel model) {
    final loc = AppLocalizations.of(context)!;
    return [
      PlatformMenu(
        label: loc.wpspsync,
        menus: [
          if (PlatformProvidedMenuItem.hasMenu(PlatformProvidedMenuItemType.about))
            const PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.about),
          if (PlatformProvidedMenuItem.hasMenu(PlatformProvidedMenuItemType.quit))
            const PlatformProvidedMenuItem(type: PlatformProvidedMenuItemType.quit),
        ],
      ),
      PlatformMenu(
        label: loc.syncRoot.replaceAll(' Root', '').replaceAll(' Raiz', ''), // Temporary hack to reuse string
        menus: [
          PlatformMenuItem(
            label: loc.scan,
            shortcut: const SingleActivator(LogicalKeyboardKey.keyR, meta: true),
            onSelected: model.isWorking ? null : () => _scan(model),
          ),
          PlatformMenuItem(
            label: loc.syncSelected,
            shortcut: const SingleActivator(LogicalKeyboardKey.keyS, meta: true),
            onSelected: (model.selectedRowIDs.isEmpty || 
                          model.selectedExternalRoot == null || 
                          model.selectedSyncRoot == null || 
                          model.isWorking)
                  ? null
                  : () => _syncSelected(model),
          ),
          PlatformMenuItem(
            label: loc.restoreBackup.replaceAll('?', ''),
            onSelected: (model.selectedSyncRoot == null || model.selectedBackupId == null || model.isWorking)
                ? null
                : () => model.restoreSelectedBackup(),
          ),
        ],
      ),
    ];
  }
}
