//
//  HLSudokuSolverUITests.swift
//  HLSudokuSolverUITests
//
//  Created by Matthew Homer on 8/7/23.
//  Copyright © 2023 Matthew Homer. All rights reserved.
//

import XCTest

final class HLSudokuSolverUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()

        // We send a command line argument to our app,
        // to enable it to reset its state
        app.launchArguments.append("--uitesting")

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()        
        
        app/*@START_MENU_TOKEN@*/.buttons["Mono Cell"]/*[[".segmentedControls[\"mainView\"].buttons[\"Mono Cell\"]",".buttons[\"Mono Cell\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.buttons["Prune"].tap()
        app.buttons["Solve"].tap()
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

extension XCUIApplication {
    var isDisplayingMainView: Bool {
        return otherElements["mainView"].exists
    }
}
