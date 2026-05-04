# wPSPsync project knowledge

## Project overview

wPSPsync is a native macOS SwiftUI app for scanning and syncing PSP save folders.

The app expects both selected roots to be top-level folders:

- PSP storage root: contains `PSP/SAVEDATA`
- Sync root: contains or will contain `PSP/SAVEDATA`

The sync operation uses rsync-style behavior: it copies newer save folders to the older side and copies missing folders to the side where they are absent.

## Important conventions

- App name must be written consistently as `wPSPsync`.
- Bundle identifier is `com.briteapps.wpspsync`.
- Minimum macOS is 14.0.
- Keep responses and project docs in English unless a task explicitly asks for translations.
- Do not add code comments unless explicitly requested.
- Commit messages, when requested, should use conventional commits style and lowercase summaries.
- Do not revert unrelated dirty worktree changes.

## Project layout

- `wPSPsync.xcodeproj`: Xcode project.
- `Sources/`: app source files.
- `Tests/`: XCTest tests.
- `Resources/Localizable.xcstrings`: Swift string catalog.
- `Resources/wPSPsync.help/`: Apple Help Book resources.
- `Resources/wPSPsync.icon/`: app icon source resources.
- `wPSPsync/Config/Info.plist`: app Info.plist.
- `wPSPsync/Config/wPSPsync.entitlements`: sandbox/network entitlements.

## Main source files

- `Sources/wPSPsyncApp.swift`: app entry point and Help Book registration.
- `Sources/ContentView.swift`: SwiftUI sidebar, save list, row context menus, backup controls.
- `Sources/AppModel.swift`: app state, scanning, syncing, delete actions, backup restore, root persistence, SerialStation cache use.
- `Sources/SaveScanner.swift`: PSP and sync-root folder scanning.
- `Sources/SyncEngine.swift`: comparison and sync behavior.
- `Sources/BackupStore.swift`: zip backup creation, retention, restore.
- `Sources/DirectoryBookmarkStore.swift`: persisted security-scoped directory bookmarks.
- `Sources/CatalogStore.swift`: bundled/imported game catalog loading.
- `Sources/SerialStationClient.swift`: remote API client.
- `Sources/SerialStationCacheStore.swift`: cached SerialStation metadata in the app cache directory.
- `Sources/Models.swift`: shared data models.

## Build and test

Build:

```sh
xcodebuild -project wPSPsync.xcodeproj -scheme wPSPsync -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/wpspsync-xcode-dd CODE_SIGNING_ALLOWED=NO build
```

Run tests:

```sh
xcodebuild -project wPSPsync.xcodeproj -scheme wPSPsync -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/wpspsync-xcode-dd CODE_SIGNING_ALLOWED=NO test
```

When filtering build output, keep enough context for diagnostics:

```sh
xcodebuild -project wPSPsync.xcodeproj -scheme wPSPsync -configuration Debug -destination 'platform=macOS' -derivedDataPath /tmp/wpspsync-xcode-dd CODE_SIGNING_ALLOWED=NO build 2>&1 | rg -n "error:|warning:|BUILD FAILED|BUILD SUCCEEDED|Localizable|CopyStringsFile|Info.plist"
```

## Localization workflow

The app uses `Resources/Localizable.xcstrings` with English source strings and Spanish, Russian, Japanese, and German localizations.

After adding or changing user-facing Swift strings:

1. Build once so Xcode generates `.stringsdata`.
2. Sync the catalog:

```sh
xcrun xcstringstool sync Resources/Localizable.xcstrings --stringsdata /tmp/wpspsync-xcode-dd/Build/Intermediates.noindex/wPSPsync.build/Debug/wPSPsync.build/Objects-normal/arm64/*.stringsdata
```

3. Add translations for any new strings.
4. Verify no extracted keys are missing from the catalog:

```sh
for f in /tmp/wpspsync-xcode-dd/Build/Intermediates.noindex/wPSPsync.build/Debug/wPSPsync.build/Objects-normal/arm64/*.stringsdata; do plutil -p "$f"; done | sed -n 's/.*"key" => "\(.*\)"/\1/p' | sort -u > /tmp/wpspsync-extracted-keys.txt
xcrun xcstringstool print Resources/Localizable.xcstrings | sort -u > /tmp/wpspsync-catalog-keys.txt
comm -23 /tmp/wpspsync-extracted-keys.txt /tmp/wpspsync-catalog-keys.txt
```

5. Verify every translatable catalog key has localizations:

```sh
ruby -rjson -e 'data=JSON.parse(File.read("Resources/Localizable.xcstrings")); missing=data["strings"].select{|_,v| !v.key?("localizations") && v["shouldTranslate"] != false}.keys; puts missing.empty? ? "all catalog keys localized or non-translatable" : missing.sort'
```

Use `String(localized:)` for strings that live in custom non-SwiftUI wrappers such as `AppAlert`, `ConfirmationDialog`, picker titles, and status messages. Keep `PSP` and `wPSPsync` non-translatable where appropriate.

Russian translations should use `Ё` where linguistically required.

## Help Book

Help resources live in:

- `Resources/wPSPsync.help/Contents/Resources/English.lproj/index.html`
- `Resources/wPSPsync.help/Contents/Resources/es.lproj/index.html`
- `Resources/wPSPsync.help/Contents/Resources/ru.lproj/index.html`
- `Resources/wPSPsync.help/Contents/Resources/ja.lproj/index.html`
- `Resources/wPSPsync.help/Contents/Resources/de.lproj/index.html`

Keep the no-warranty and risk disclaimer near the top of each help page, after the header and table of contents area.

If Help Book edits do not appear after rebuild, macOS Help Viewer may be showing cached content. Quit Help Viewer and the app, clean DerivedData for the app, and relaunch from the rebuilt app bundle.

## Data storage

- Backups are stored under `~/Library/Application Support/wPSPsync/Backups`.
- The app keeps the five newest backup zip files.
- SerialStation metadata cache is stored under the app default cache directory, currently `~/Library/Caches/wPSPsync/serialstation-metadata.json`.
- Selected PSP storage and sync roots are persisted as security-scoped bookmarks.

## Tests

Tests that create temporary files must remove them after completion, usually through teardown cleanup.

Relevant test files:

- `Tests/SaveScannerTests.swift`
- `Tests/SyncEngineTests.swift`
- `Tests/BackupStoreTests.swift`
- `Tests/SerialStationClientTests.swift`
- `Tests/SerialStationCacheStoreTests.swift`
- `Tests/GameIDParserTests.swift`

## UX and behavior notes

- Rows use checkboxes to show which saves will be synced.
- Row context menus support deleting a save from PSP storage, from the sync root, or from both when both copies exist.
- Destructive actions should ask for confirmation.
- Selecting `Search SerialStation API` should enrich metadata without changing sync comparison state when file contents have not changed.
- Avoid recreating nested `SAVEDATA` folders. The sync root and PSP root are both top-level roots, and `PSP/SAVEDATA` is appended by scanner/sync logic.

## Legal notes

The source code is MIT licensed. Project resources, including icon assets, are copyrighted by Nikita Denin unless a separate resource license says otherwise.

wPSPsync is independent and is not affiliated with, endorsed by, or sponsored by Sony Group Corporation, Sony Interactive Entertainment Inc., or their affiliates. PSP and PlayStation are trademarks or registered trademarks of Sony Interactive Entertainment Inc.; SONY is a trademark or registered trademark of Sony Group Corporation.
