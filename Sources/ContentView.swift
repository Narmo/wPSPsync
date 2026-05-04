//
// Copyright (c) 2026 Nikita Denin <nik@brite-apps.com>
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
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        NavigationSplitView {
            Sidebar()
                .navigationSplitViewColumnWidth(min: 270, ideal: 310)
        } detail: {
            SaveListView()
        }
        .toolbar {
            ToolbarItemGroup {
                Button {
                    Task {
                        await model.refreshVolumes()
                    }
                } label: {
                    Label("Scan", systemImage: "arrow.clockwise")
                }
                .help("Rescan PSP storage root and sync root")
                .disabled(model.isWorking)

                Button {
                    Task {
                        await model.syncSelected()
                    }
                } label: {
                    Label("Sync", systemImage: "arrow.triangle.2.circlepath")
                }
                .help("Sync selected saves by copying the newest or missing save folder to the other side")
                .disabled(model.selectedRowIDs.isEmpty || model.selectedExternalRoot == nil || model.selectedSyncRoot == nil || model.isWorking)
            }
        }
        .alert(item: $model.alert) { alert in
            Alert(title: Text(alert.title), message: Text(alert.message), dismissButton: .default(Text("OK")))
        }
    }
}

struct Sidebar: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("wPSPsync")
                    .font(.largeTitle.weight(.semibold))
                Text(model.statusMessage)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: String(localized: "PSP Storage"), systemImage: "externaldrive")

                PathChip(url: model.selectedExternalRoot, placeholder: String(localized: "No PSP storage root selected"))

                if model.externalCandidates.isEmpty {
                    Text("No PSP storage root with PSP/SAVEDATA detected.")
                        .foregroundStyle(.secondary)
                }

                Button {
                    model.selectExternalRoot()
                } label: {
                    Label("Choose PSP Root", systemImage: "folder")
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: String(localized: "Sync Root"), systemImage: "icloud.and.arrow.up")

                PathChip(url: model.selectedSyncRoot, placeholder: String(localized: "No sync root selected"))

                Button {
                    model.selectSyncRoot()
                } label: {
                    Label("Choose Sync Root", systemImage: "folder.badge.gearshape")
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: String(localized: "Game Catalog"), systemImage: "books.vertical")

                Text("\(model.catalog.games.count) title entries loaded")
                    .foregroundStyle(.secondary)

                Toggle("Search SerialStation API", isOn: $model.useSerialStationAPI)
                    .onChange(of: model.useSerialStationAPI) {
                        Task {
                            await model.scan()
                        }
                    }

                Button {
                    if let url = FilePicker.pickJSON(title: String(localized: "Import PSP game catalog")) {
                        Task {
                            await model.importCatalog(from: url)
                        }
                    }
                } label: {
                    Label("Import JSON", systemImage: "square.and.arrow.down")
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                SectionHeader(title: String(localized: "Backups"), systemImage: "archivebox")

                Toggle("Create backup before writing", isOn: $model.backupsEnabled)

                if model.backups.isEmpty {
                    Text("No backups saved.")
                        .foregroundStyle(.secondary)
                } else {
                    Picker("Saved backups", selection: $model.selectedBackupID) {
                        ForEach(model.backups) { backup in
                            Text(backup.title).tag(Optional(backup.id))
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }

                Button {
                    Task {
                        await model.restoreSelectedBackup()
                    }
                } label: {
                    Label("Restore Backup", systemImage: "arrow.counterclockwise")
                }
                .disabled(model.selectedSyncRoot == nil || model.selectedBackupID == nil || model.isWorking)
            }

            Spacer()

            if model.isWorking {
                ProgressView()
                    .controlSize(.small)
            }
        }
        .padding(24)
    }
}

struct SaveListView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Save Games")
                    .font(.title2.weight(.semibold))
                Spacer()
                Button {
                    if model.selectedRowIDs.count == model.rows.count {
                        model.selectedRowIDs.removeAll()
                    } else {
                        model.selectedRowIDs = Set(model.rows.map(\.id))
                    }
                } label: {
                    Text(model.selectedRowIDs.count == model.rows.count ? String(localized: "Deselect All") : String(localized: "Select All"))
                }
                .disabled(model.rows.isEmpty)
            }
            .padding([.horizontal, .top], 24)
            .padding(.bottom, 12)

            if model.rows.isEmpty {
                ContentUnavailableView(
                    "No Saves Found",
                    systemImage: "memorychip",
                    description: Text("Select a PSP storage root with PSP/SAVEDATA and a sync root that contains or will contain PSP/SAVEDATA.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(model.rows) { row in
                    SaveRow(
                        row: row,
                        isSelected: Binding(
                            get: {
                                model.selectedRowIDs.contains(row.id)
                            },
                            set: { isSelected in
                                if isSelected {
                                    model.selectedRowIDs.insert(row.id)
                                } else {
                                    model.selectedRowIDs.remove(row.id)
                                }
                            }
                        ),
                        deleteFromPSP: {
                            Task {
                                await model.deletePSPSave(row)
                            }
                        },
                        deleteFromSync: {
                            Task {
                                await model.deleteSyncSave(row)
                            }
                        },
                        deleteBoth: {
                            Task {
                                await model.deleteBothSaves(row)
                            }
                        }
                    )
                }
                .listStyle(.inset)
            }
        }
    }
}

struct SaveRow: View {
    let row: SaveComparison
    @Binding var isSelected: Bool
    let deleteFromPSP: () -> Void
    let deleteFromSync: () -> Void
    let deleteBoth: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Toggle("Sync \(row.displayTitle)", isOn: $isSelected)
                .labelsHidden()
                .toggleStyle(.checkbox)
                .help(isSelected ? "Selected for sync" : "Not selected for sync")

            SaveIcon(localURL: row.iconURL, remoteURL: row.coverURL)

            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Text(row.displayTitle)
                        .font(.headline)
                        .lineLimit(1)
                    StateBadge(state: row.state)
                }

                HStack(spacing: 12) {
                    Text(row.gameID)
                    if let latestModifiedAt = row.latestModifiedAt {
                        Text(latestModifiedAt.formatted(date: .abbreviated, time: .shortened))
                    }
                    Text(ByteCountFormatter.string(fromByteCount: row.size, countStyle: .file))
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                DateLabel(title: String(localized: "PSP"), date: row.psp?.modifiedAt)
                DateLabel(title: String(localized: "Sync"), date: row.sync?.modifiedAt)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .contextMenu {
            if row.psp != nil {
                Button(role: .destructive, action: deleteFromPSP) {
                    Label("Delete from PSP Storage", systemImage: "trash")
                }
            }
            if row.sync != nil {
                Button(role: .destructive, action: deleteFromSync) {
                    Label("Delete from Sync Root", systemImage: "trash")
                }
            }
            if row.psp != nil, row.sync != nil {
                Divider()
                Button(role: .destructive, action: deleteBoth) {
                    Label("Delete Both", systemImage: "trash")
                }
            }
        }
    }
}

struct SaveIcon: View {
    let localURL: URL?
    let remoteURL: URL?

    var body: some View {
        Group {
            if let image {
                iconImage(Image(nsImage: image))
            } else if let remoteURL {
                AsyncImage(url: remoteURL) { phase in
                    switch phase {
                    case .success(let image):
                        iconImage(image)
                    case .empty:
                        placeholder {
                            ProgressView()
                                .controlSize(.small)
                        }
                    case .failure:
                        placeholder {
                            fallback
                        }
                    @unknown default:
                        placeholder {
                            fallback
                        }
                    }
                }
            } else {
                placeholder {
                    fallback
                }
            }
        }
    }

    private var image: NSImage? {
        guard let localURL else {
            return nil
        }
        return NSImage(contentsOf: localURL)
    }

    private func iconImage(_ image: Image) -> some View {
        image
            .resizable()
            .scaledToFit()
            .frame(width: 72, height: 40)
    }

    private func placeholder<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ZStack {
            Rectangle()
                .fill(.quaternary)
            content()
        }
        .frame(width: 72, height: 40)
    }

    private var fallback: some View {
        Image(systemName: "gamecontroller")
            .font(.title2)
            .foregroundStyle(.secondary)
    }
}

struct StateBadge: View {
    let state: SaveState

    var body: some View {
        Text(state.title)
            .font(.caption.weight(.medium))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(background, in: Capsule())
            .foregroundStyle(foreground)
    }

    private var background: Color {
        switch state {
        case .same:
            return .green.opacity(0.16)
        case .pspNewer:
            return .blue.opacity(0.16)
        case .syncNewer:
            return .orange.opacity(0.18)
        case .onlyPSP:
            return .teal.opacity(0.16)
        case .onlySync:
            return .purple.opacity(0.16)
        }
    }

    private var foreground: Color {
        switch state {
        case .same:
            return .green
        case .pspNewer:
            return .blue
        case .syncNewer:
            return .orange
        case .onlyPSP:
            return .teal
        case .onlySync:
            return .purple
        }
    }
}

struct DateLabel: View {
    let title: String
    let date: Date?

    var body: some View {
        HStack(spacing: 6) {
            Text(title)
                .fontWeight(.medium)
            Text(date?.formatted(date: .numeric, time: .shortened) ?? String(localized: "missing"))
                .monospacedDigit()
        }
    }
}

struct PathChip: View {
    let url: URL?
    let placeholder: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "folder")
            Text(url?.path(percentEncoded: false) ?? placeholder)
                .lineLimit(2)
                .truncationMode(.middle)
        }
        .font(.callout)
        .foregroundStyle(url == nil ? .secondary : .primary)
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

struct SectionHeader: View {
    let title: String
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.headline)
    }
}

enum FilePicker {
    static func pickJSON(title: String) -> URL? {
        let panel = NSOpenPanel()
        panel.title = title
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.json]
        return panel.runModal() == .OK ? panel.url : nil
    }
}
