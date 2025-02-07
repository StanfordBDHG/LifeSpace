//
//  HomeViewTests.swift
//  LifeSpaceUITests
//
//  Created by Vishnu Ravi on 2/7/25.
//

import XCTest
import XCTestExtensions

final class HomeViewTests: XCTestCase {
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        
        let app = XCUIApplication()
        app.launchArguments = ["--skipOnboarding", "--alwaysEnableSurvey"]
        app.deleteAndLaunch(withSpringboardAppName: "LifeSpace")
    }
    
    func testDailySurveyLaunch() throws {
        let app = XCUIApplication()
        
        waitForAndHandleLocationPermission()
        
        // Bypass Firebase configuration error
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 5) {
           alert.buttons["OK"].tap()
        }
        
        // Try to launch the daily survey
        let dailySurveyButton = app.buttons["Take Daily Survey"]
        XCTAssertTrue(dailySurveyButton.exists, "Take Daily Survey button should be visible on the home screen")
        dailySurveyButton.tap()
        
        let sheetText = app.staticTexts["Social Interaction"]
        XCTAssertTrue(sheetText.waitForExistence(timeout: 5))
    }
    
    private func waitForAndHandleLocationPermission() {
       let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
       let allowButton = springboard.buttons["Allow While Using App"]
       
       if allowButton.waitForExistence(timeout: 5) {
           allowButton.tap()
       }
    }
}
