import XCTest

/// UI-test smoke target (Phase-2 CI: also drives `simctl` screenshot
/// capture per device class — see docs/phase-2-mac-gate.md).
final class LaunchUITests: XCTestCase {
    func testAppLaunchesToHome() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.navigationBars.element.waitForExistence(timeout: 10))
    }
}
