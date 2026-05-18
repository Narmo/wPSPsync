# wPSPsync (Flutter Port)

[![CI/CD Pipeline](https://github.com/Narmo/wPSPsync/actions/workflows/ci.yml/badge.svg)](https://github.com/Narmo/wPSPsync/actions)

A feature-perfect, cross-platform port of the original wPSPsync macOS application. Built with Flutter, this tool allows you to synchronize PSP save folders between a physical device (or emulator) and a synchronization root (e.g., a cloud-synced folder) with native-like aesthetics and robust logic.

## 🚀 Key Features

- **Cross-Platform Compatibility**: Run natively on **Windows, macOS, and Linux**.
- **Native macOS Aesthetic**: Precise dark mode styling matching the original SwiftUI implementation.
- **Smart Sync Engine**:
  - Intelligent comparison of save folders.
  - FAT32 timestamp drift handling (2-second threshold).
  - One-click synchronization of multiple selections.
- **Automated Backups**:
  - Integrated ZIP backup system.
  - Automatic 5-file rotation policy to save space while keeping your data safe.
- **SerialStation API Integration**:
  - Automatic identification of Game IDs.
  - Fetches official game titles and cover art for a premium experience.
  - Local caching for offline performance.
- **Robust Management**:
  - Right-click context menus for granular save deletion.
  - Automatic PSP storage root detection.
  - Importable game catalogs via JSON.

## 🛠️ Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel recommended)
- Visual Studio (Windows), Xcode (macOS), or GTK development headers (Linux).

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/OniMock/wPSPsync.git
   cd wPSPsync/wpspsync_flutter
   ```

2. Fetch dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   flutter run -d windows  # or macos/linux
   ```

## 🧪 Testing

The project includes a comprehensive test suite ported from the original Swift implementation, ensuring core logic stability:

```bash
flutter test
```

## 📦 Building for Production

To generate a standalone executable for your platform:

```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

The resulting artifacts can be found in `build/<platform>/x64/release/`.

## 📄 License

This project is licensed under the same terms as the original wPSPsync project.

---
*Maintained by OniMock*
