//
//  DailySurveyTests.swift
//  LifeSpaceUITests
//
//  Created by Vishnu Ravi on 2/7/25.
//

import XCTest
import XCTestExtensions

final class DailySurveyTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--disableFirebase", "--alwaysEnableSurvey"]
        app.deleteAndLaunch(withSpringboardAppName: "LifeSpace")
    }
    
    func testDailySurvey() throws {
        let app = XCUIApplication()
        
        waitForAndHandleLocationPermission()
        
        // Dismisses alert caused by disabled Firebase
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 5) {
           alert.buttons["OK"].tap()
        }
        
        XCTAssertTrue(app.buttons["Take Daily Survey"].waitForExistence(timeout: 3))
        app.buttons["Take Daily Survey"].tap()
        
        XCTAssertTrue(app.staticTexts["Social Interaction"].waitForExistence(timeout: 3))
        app.staticTexts["0"].tap()
        app.buttons["Next"].tap()
        
        XCTAssertTrue(app.staticTexts["Leaving the House"].waitForExistence(timeout: 3))
        app.staticTexts["None"].tap()
        app.buttons["Next"].tap()
        
        XCTAssertTrue(app.staticTexts["Emotional Well-being"].waitForExistence(timeout: 3))
        app.staticTexts["Yes"].tap()
        app.buttons["Next"].tap()

        XCTAssertTrue(app.staticTexts["Physical Well-being"].waitForExistence(timeout: 3))
        app.staticTexts["Not at all"].tap()
        app.buttons["Next"].tap()
        
        XCTAssertTrue(app.staticTexts["Review Answers"].waitForExistence(timeout: 3))
        app.buttons["Next"].tap()
        
        XCTAssertTrue(app.staticTexts["Thank you!"].waitForExistence(timeout: 3))
        app.buttons["Done"].tap()
    }
    
    private func waitForAndHandleLocationPermission() {
       let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
       let allowButton = springboard.buttons["Allow While Using App"]
       
       if allowButton.waitForExistence(timeout: 5) {
           allowButton.tap()
       }
    }
}
