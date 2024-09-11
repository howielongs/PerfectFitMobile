//
//  Perfect_FitUITests.swift
//  Perfect FitUITests
//
//  Created by Howie Long on 9/3/24.
//

import XCTest

final class Perfect_FitUITests: XCTestCase {

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Verify that the main screen is displayed
        XCTAssert(app.staticTexts["Clothing List"].exists)
    }
}
