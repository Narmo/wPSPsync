# wPSPsync

Native macOS SwiftUI app for scanning and syncing PSP save folders.

Select top-level roots for both sides. PSP storage should be the volume or memory card root that contains `PSP/SAVEDATA`; the sync root should be the folder that contains or will contain `PSP/SAVEDATA`.

Selected roots are saved and restored between app launches.

The sync action copies newer save folders to the older side and copies missing save folders to the side where they are absent.

Backups are enabled by default. Before the app writes a new sync state, it stores a datetime-named zip backup under the app's Application Support directory:

```text
~/Library/Application Support/wPSPsync/Backups
```

The app keeps the five newest backups. Use Restore Backup in the sidebar to replace the selected sync root with the selected saved backup. Disable `Create backup before writing` to skip automatic backups.

## Risks and no warranty

wPSPsync copies, replaces, and restores save folders. A wrong root selection, interrupted copy, storage failure, software bug, or unexpected save layout can cause save data loss or overwrite newer saves. Review the checked rows before syncing and keep separate backups of important saves.

Automatic backups are a safety feature, not a guarantee. Backups are stored on the same Mac and only the five newest backups are retained.

The software is provided "as is", without warranty of any kind. See [LICENSE](LICENSE.txt) for the full MIT no-warranty terms.

## Cross-Platform Support (Windows & Linux)

A Flutter-based version of wPSPsync is available for **Windows**, **Linux**, and **macOS**. It offers the same features and aesthetics as the native macOS app in a cross-platform package.

See [wpspsync_flutter/README.md](wpspsync_flutter/README.md) for details.

## Run

Open `wPSPsync.xcodeproj` and run the `wPSPsync` scheme.

Run tests from the same scheme with Product > Test.

The macOS app target uses:

- App name: `wPSPsync`
- Bundle identifier: `com.briteapps.wpspsync`
- Minimum macOS: 14.0
- App sandbox with user-selected read/write access
- Network client entitlement for optional SerialStation lookup

## Save layout

PSP storage is expected to contain:

```text
PSP/SAVEDATA/<save folder>
```

The sync root uses the same PSP-style layout:

```text
PSP/SAVEDATA/<save folder>
```

## Catalog

The bundled catalog is intentionally small. Import a fuller JSON catalog from the app sidebar using this shape:

```json
[
  {
    "id": "ULUS10566",
    "title": "Persona 3 Portable",
    "region": "US",
    "publisher": "Atlus",
    "coverURL": "https://example.com/persona-3-portable.jpg"
  }
]
```

Good source candidates for building a PSP title catalog are Redump for serial/title metadata and SerialStation for broader serial metadata with images. The app also reads `ICON0.PNG` directly from each PSP save folder, which works even when a catalog entry has no external cover art.

## SerialStation lookup

SerialStation lookup is optional and disabled by default. Enable `Search SerialStation API` in the sidebar to enrich scanned saves through the documented API:

- `GET https://api.serialstation.com/v1/title-ids/{title_id}`
- `GET https://api.serialstation.com/v1/tmdb/{title_id}`

The local imported JSON catalog and PSP save icons continue to work without network access.

## License

The software source code is licensed under the MIT License. See [LICENSE](LICENSE.txt).

Project resources, including the application icon and other visual assets, are copyright © 2026 Nikita Denin. All rights reserved unless a separate resource license states otherwise.

## Trademark notice

wPSPsync is an independent project and is not affiliated with, endorsed by, or sponsored by Sony Group Corporation, Sony Interactive Entertainment Inc., or their affiliates.

PSP and PlayStation are registered trademarks or trademarks of Sony Interactive Entertainment Inc. SONY is a registered trademark or trademark of Sony Group Corporation. Other product names, service names, logos, and company names are trademarks or copyrighted properties of their respective owners.
