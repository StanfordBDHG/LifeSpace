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
        app.launchArguments = ["--skipOnboarding"]
        app.deleteAndLaunch(withSpringboardAppName: "LifeSpace")
    }
    
    func testTakeDailySurveyButtonExists() throws {
        let app = XCUIApplication()
        
        waitForAndHandleLocationPermission()
        
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 5) {
           alert.buttons["OK"].tap()
        }
        
        // Check if the button exists
        let dailySurveyButton = app.buttons["Take Daily Survey"]
        XCTAssertTrue(dailySurveyButton.exists, "Take Daily Survey button should be visible on the home screen")
        
        // Verify the button is enabled
        XCTAssertTrue(dailySurveyButton.isEnabled, "Take Daily Survey button should be enabled")
        
        // Optional: Verify the button is hittable (visible and interactable)
        XCTAssertTrue(dailySurveyButton.isHittable, "Take Daily Survey button should be hittable")
    }
    
    private func waitForAndHandleLocationPermission() {
       let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
       let allowButton = springboard.buttons["Allow While Using App"]
       
       if allowButton.waitForExistence(timeout: 5) {
           allowButton.tap()
       }
    }
}
