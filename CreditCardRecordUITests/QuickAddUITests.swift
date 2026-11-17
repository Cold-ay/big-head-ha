import XCTest

final class QuickAddUITests: XCTestCase {
    private func launch(_ language: String = "system") -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "-appLanguage", language, "-appearanceMode", "light"]
        app.launch()
        return app
    }

    func testHomeIsOverviewWithFourTabsAndAddCard() {
        let app = launch()
        XCTAssertTrue(app.navigationBars["Overview"].exists)
        XCTAssertEqual(app.tabBars.buttons.count, 4)
        XCTAssertFalse(app.tabBars.buttons["More"].exists)
        XCTAssertFalse(app.tabBars.buttons["Trends"].exists)
        XCTAssertTrue(app.buttons["home.addCard"].exists)
        capture("Overview - first launch", app: app)
    }

    func testHomeScreenShowsBigHeadHaNameAndIcon() {
        let app = launch()
        XCUIDevice.shared.press(.home)
        let home = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let icon = home.icons["BigHeadHa"]
        for _ in 0..<3 {
            if icon.waitForExistence(timeout: 2) { break }
            home.swipeLeft()
        }
        XCTAssertTrue(icon.exists)
        capture("BigHeadHa - installed Home Screen icon", app: home)
        app.activate()
    }

    func testAppearanceUpdatesWhileSettingsStayOpen() {
        let app = XCUIApplication()
        app.launchArguments = ["--uitesting", "-appLanguage", "system"]
        app.launch()
        app.buttons["navigation.settings"].tap()
        let picker = app.buttons["settings.appearance"]
        let originalSystemValue = picker.value as? String ?? ""
        XCTAssertTrue(["system:light", "system:dark"].contains(originalSystemValue))
        picker.tap()
        app.buttons["Dark"].tap()
        XCTAssertTrue(waitForValue("dark:dark", of: picker))
        capture("Settings - dark while open", app: app)
        picker.tap()
        app.buttons["Light"].tap()
        XCTAssertTrue(waitForValue("light:light", of: picker))
        capture("Settings - light while open", app: app)
        picker.tap()
        app.buttons["System"].tap()
        XCTAssertTrue(waitForValue(originalSystemValue, of: picker))
    }

    func testQuickAddScreenShowsCoreFieldsAndAllCategoryTiles() {
        let app = launch()
        app.tabBars.buttons["Quick"].tap()
        XCTAssertTrue(app.textFields["quickAdd.amount"].exists)
        XCTAssertTrue(app.textFields["quickAdd.merchant"].exists)
        XCTAssertTrue(app.buttons["quickAdd.save"].exists)
        XCTAssertTrue(app.buttons["quickAdd.noCards"].exists || app.buttons["home.addCard"].exists)
        XCTAssertFalse(app.buttons["quickAdd.save"].isEnabled)
        reveal(app.buttons["category.other"], in: app)
        for name in ["dining", "transport", "grocery", "shopping", "bills", "entertainment", "travel", "online", "health", "education", "other"] {
            XCTAssertTrue(app.buttons["category." + name].exists)
        }
        XCTAssertLessThan(app.buttons["category.other"].frame.maxY - app.buttons["category.dining"].frame.minY, 390)
        capture("All categories - icon grid", app: app)
    }

    func testAmountFieldAcceptsDecimalInput() {
        let app = launch()
        app.tabBars.buttons["Quick"].tap()
        let amount = app.textFields["quickAdd.amount"]
        reveal(amount, in: app)
        amount.tap()
        amount.typeText("12.34")
        XCTAssertEqual(amount.value as? String, "12.34")
        app.buttons["keyboard.done"].tap()
    }

    func testTaiwanCardForeignCurrencySwipeChoiceAndRemovalFlow() {
        let app = launch()
        addTaiwanCard(app)
        app.tabBars.buttons["Quick"].tap()
        let rate = app.textFields["quickAdd.exchangeRate"]
        XCTAssertTrue(rate.waitForExistence(timeout: 5))
        let amount = app.textFields["quickAdd.amount"]
        reveal(amount, in: app)
        amount.tap()
        amount.typeText("1000")
        app.buttons["keyboard.done"].tap()
        let merchant = app.textFields["quickAdd.merchant"]
        reveal(merchant, in: app)
        merchant.tap()
        merchant.typeText("Taipei Cafe")
        app.buttons["keyboard.done"].tap()
        XCTAssertFalse(app.buttons["quickAdd.save"].isEnabled)
        app.swipeDown()
        reveal(rate, in: app)
        rate.tap()
        rate.typeText("0.24")
        app.buttons["keyboard.done"].tap()
        reveal(app.buttons["category.other"], in: app)
        app.buttons["category.shopping"].tap()
        capture("TWD spending - all category choices", app: app)
        XCTAssertTrue(app.buttons["quickAdd.save"].isEnabled)
        app.buttons["quickAdd.save"].tap()
        XCTAssertTrue(app.staticTexts["quickAdd.saved"].exists)
        app.tabBars.buttons["Overview"].tap()
        XCTAssertTrue(app.staticTexts["HK$240.00"].firstMatch.exists)

        addTaiwanCard(app, easyCard: true)
        app.tabBars.buttons["Cards"].tap()
        let carousel = app.scrollViews["cards.carousel"]
        XCTAssertTrue(carousel.exists)
        carousel.swipeLeft()
        XCTAssertTrue(app.staticTexts["Stored value"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["Taipei Cafe"].exists)
        app.buttons["cards.choose"].tap()
        app.buttons["card.choice.tw-cathay-cube"].tap()
        XCTAssertTrue(app.staticTexts["Taipei Cafe"].exists)
        capture("Single-card spending and category breakdown", app: app)
        let remove = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH %@", "cards.remove.")).firstMatch
        reveal(remove, in: app)
        remove.tap()
        app.alerts.buttons["Remove"].tap()
        app.tabBars.buttons["Repayment"].tap()
        XCTAssertTrue(app.staticTexts["repayment.noCards"].exists)
        app.tabBars.buttons["Overview"].tap()
        XCTAssertTrue(app.staticTexts["HK$240.00"].firstMatch.exists)
        capture("Overall spending - history retained", app: app)
    }

    func testQuickCardSwipeAndCheckboxSelection() {
        let app = launch()
        addTaiwanCard(app)
        addTaiwanCard(app, easyCard: true)
        app.tabBars.buttons["Quick"].tap()
        XCTAssertTrue(app.images["card.artwork.tw-cathay-cube"].exists)
        capture("Quick - official CUBE card", app: app)
        app.scrollViews["cards.carousel"].swipeLeft()
        XCTAssertEqual(app.buttons["cards.choose"].value as? String, "悠遊卡 EasyCard")
        XCTAssertTrue(app.images["card.artwork.tw-easycard"].exists)
        capture("Quick - portrait EasyCard", app: app)
        app.buttons["cards.choose"].tap()
        app.buttons["card.choice.tw-cathay-cube"].tap()
        XCTAssertEqual(app.buttons["cards.choose"].value as? String, "CUBE信用卡")
        capture("Quick card selection - swipe and checklist", app: app)
    }

    func testOfficialLandscapePortraitAndFallbackPreviews() {
        let app = launch()
        app.buttons["navigation.addCard"].tap()
        XCTAssertTrue(app.images["card.artwork.hsbc-red"].exists)
        capture("Card preview - official HSBC Red", app: app)
        app.buttons["cards.product"].tap()
        XCTAssertTrue(app.buttons["HSBC Premier Mastercard"].waitForExistence(timeout: 5))
        app.buttons["HSBC Premier Mastercard"].tap()
        XCTAssertTrue(app.images["card.artwork.hsbc-premier-mastercard"].exists)
        capture("Card preview - official portrait Premier", app: app)
        app.buttons["cards.product"].tap()
        XCTAssertTrue(app.buttons["HSBC easy Credit Card"].waitForExistence(timeout: 5))
        app.buttons["HSBC easy Credit Card"].tap()
        XCTAssertTrue(app.images["card.artwork.fallback"].exists)
        capture("Card preview - brushed fallback", app: app)
    }

    func testTraditionalChineseSettingsDefaultsWithoutPreview() {
        let app = launch("zh-Hant")
        app.buttons["navigation.settings"].tap()
        XCTAssertFalse(app.staticTexts["預覽"].exists)
        XCTAssertTrue(app.buttons["settings.defaultCategory"].exists)
        XCTAssertTrue(app.switches["settings.privacy"].exists)
        XCTAssertTrue(app.descendants(matching: .any)["settings.shortcuts"].firstMatch.exists)
        capture("Settings - useful preferences", app: app)
        app.buttons["settings.defaultCategory"].tap()
        app.buttons["category.education"].tap()
        capture("Traditional Chinese category grid", app: app)
        app.buttons["settings.categoryDone"].tap()
        let privacy = app.switches["settings.privacy"]
        privacy.coordinate(withNormalizedOffset: CGVector(dx: 0.9, dy: 0.5)).tap()
        XCTAssertEqual(privacy.value as? String, "1")
        capture("Settings privacy enabled", app: app)
        app.buttons["settings.done"].tap()
        XCTAssertTrue(app.staticTexts["••••"].waitForExistence(timeout: 5))
        capture("Overview with amounts hidden", app: app)
        app.tabBars.buttons["快速"].tap()
        reveal(app.buttons["category.education"], in: app)
        XCTAssertTrue(app.buttons["category.education"].isSelected)
    }

    private func addTaiwanCard(_ app: XCUIApplication, easyCard: Bool = false) {
        app.buttons["navigation.addCard"].tap()
        app.segmentedControls["cards.market"].buttons["Taiwan"].tap()
        if easyCard {
            app.buttons["cards.issuer"].tap()
            app.buttons["悠遊卡公司"].tap()
            XCTAssertFalse(app.datePickers.count > 0)
        } else {
            let digits = app.textFields["cards.last4"]
            reveal(digits, in: app)
            digits.tap()
            digits.typeText("1234")
            app.buttons["keyboard.done"].tap()
        }
        let add = app.buttons["cards.addPreset"]
        reveal(add, in: app)
        XCTAssertTrue(add.isEnabled)
        add.tap()
        XCTAssertFalse(app.buttons["cards.addPreset"].waitForExistence(timeout: 1))
    }

    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<6 {
            if element.isHittable { return }
            app.swipeUp()
        }
    }
    private func waitForValue(_ value: String, of element: XCUIElement) -> Bool {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "value == %@", value), object: element)
        return XCTWaiter.wait(for: [expectation], timeout: 5) == .completed
    }
    private func capture(_ name: String, app: XCUIApplication) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
