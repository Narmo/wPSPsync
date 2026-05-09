import AppKit
import XCTest

final class QuitConfirmationPolicyTests: XCTestCase {
    func testTerminationProceedsWithoutConfirmationWhenSyncIsNotRunning() {
        var didAskForConfirmation = false

        let reply = QuitConfirmationPolicy.terminationReply(isSyncing: false) {
            didAskForConfirmation = true
            return false
        }

        XCTAssertEqual(reply, .terminateNow)
        XCTAssertFalse(didAskForConfirmation)
    }

    func testTerminationIsCancelledWhenSyncIsRunningAndUserCancels() {
        let reply = QuitConfirmationPolicy.terminationReply(isSyncing: true) {
            false
        }

        XCTAssertEqual(reply, .terminateCancel)
    }

    func testTerminationProceedsWhenSyncIsRunningAndUserConfirmsQuit() {
        let reply = QuitConfirmationPolicy.terminationReply(isSyncing: true) {
            true
        }

        XCTAssertEqual(reply, .terminateNow)
    }
}
