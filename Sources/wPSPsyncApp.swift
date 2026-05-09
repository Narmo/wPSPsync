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

@main
struct WPSPsyncApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 1080, minHeight: 700)
                .onAppear {
                    appDelegate.model = model
                }
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Sync") {
                Button("Scan") {
                    Task {
                        await model.scan()
                    }
                }
                .keyboardShortcut("r", modifiers: [.command])

                Button("Sync Selected") {
                    Task {
                        await model.syncSelected()
                    }
                }
                .keyboardShortcut("s", modifiers: [.command])
                .disabled(model.selectedRowIDs.isEmpty || model.selectedExternalRoot == nil || model.selectedSyncRoot == nil || model.isWorking)

                Button("Restore Backup") {
                    Task {
                        await model.restoreSelectedBackup()
                    }
                }
                .disabled(model.selectedSyncRoot == nil || model.selectedBackupID == nil || model.isWorking)
            }
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    weak var model: AppModel?

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        QuitConfirmationPolicy.terminationReply(isSyncing: model?.isSyncing == true, confirmQuit: confirmQuitDuringSync)
    }

    private func confirmQuitDuringSync() -> Bool {
        let alert = NSAlert()
        alert.messageText = String(localized: "Quit while sync is running?")
        alert.informativeText = String(localized: "wPSPsync is currently copying save folders. Quitting now may leave the PSP storage or sync root partially updated.")
        alert.alertStyle = .warning
        alert.addButton(withTitle: String(localized: "Quit"))
        alert.addButton(withTitle: String(localized: "Cancel"))

        return alert.runModal() == .alertFirstButtonReturn
    }
}
