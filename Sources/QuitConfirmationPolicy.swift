import AppKit

enum QuitConfirmationPolicy {
    static func terminationReply(isSyncing: Bool, confirmQuit: () -> Bool) -> NSApplication.TerminateReply {
        guard isSyncing else {
            return .terminateNow
        }

        return confirmQuit() ? .terminateNow : .terminateCancel
    }
}
