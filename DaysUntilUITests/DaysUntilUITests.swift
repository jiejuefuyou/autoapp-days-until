import XCTest

final class DaysUntilUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testScreenshots() {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()

        // Snapshot mode seeds 5 events covering future + past so the list looks lived-in.
        XCTAssertTrue(app.staticTexts["DaysUntil"].waitForExistence(timeout: 10))

        // 1) Event list.
        snapshot("01-Events")

        // 2) Add event sheet.
        let addButton = app.navigationBars.buttons.element(boundBy: app.navigationBars.buttons.count - 1)
        if addButton.exists {
            addButton.tap()
            sleep(1)
            snapshot("02-AddEvent")
            let cancel = app.buttons["Cancel"]
            if cancel.exists { cancel.tap() }
        }

        // 3) Settings sheet.
        let settingsButton = app.navigationBars.buttons.element(boundBy: 0)
        if settingsButton.exists {
            settingsButton.tap()
            sleep(1)
            snapshot("03-Settings")
            let done = app.buttons["Done"]
            if done.exists { done.tap() }
        }

        // 4) Paywall.
        if settingsButton.exists {
            settingsButton.tap()
            sleep(1)
            let unlock = app.buttons["Unlock Premium"]
            if unlock.exists {
                unlock.tap()
                sleep(1)
                snapshot("04-Paywall")
            }
        }
    }
}
