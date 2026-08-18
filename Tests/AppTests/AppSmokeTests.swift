import XCTest

@testable import App

/// Unit-test target smoke (runs on simulator in Phase-2 CI; parse-checked
/// only in Phase 1). Generated apps extend this with per-feature tests.
@MainActor
final class AppSmokeTests: XCTestCase {
    func testPaidUpfrontModeIsUnlockedImmediately() {
        let manager = PurchaseManager(mode: .paidUpfront)
        XCTAssertTrue(manager.isUnlocked)
    }

    func testUnlockModeStartsLocked() {
        let manager = PurchaseManager(mode: .iapUnlock(productID: "example.foundry.template.unlock"))
        XCTAssertFalse(manager.isUnlocked)
    }

    func testGeneratedConfigURLsAreWellFormed() {
        XCTAssertNotNil(GeneratedConfig.supportURL.host)
        XCTAssertNotNil(GeneratedConfig.privacyURL.host)
    }
}
