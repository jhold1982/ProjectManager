//
//  ProjectManagerUITests.swift
//  ProjectManagerUITests
//
//  Created by Justin Hold on 12/10/22.
//

import XCTest

class ProjectManagerUITests: XCTestCase {
	var app: XCUIApplication!
	override func setUpWithError() throws {
		continueAfterFailure = false
		app = XCUIApplication()
		app.launchArguments = ["enable-testing"]
		app.launch()
	}
    func testAppHas4Tabs() throws {
		XCTAssertEqual(app.tabBars.buttons.count, 4, "4 Tabs should appear at the bottom of screen.")
    }
	func testOpenTabAddsProjects() {
		app.buttons["Open"].tap()
		XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
		for tapCount in 1..<5 {
			app.buttons["add"].tap()
			XCTAssertEqual(app.tables.cells.count, tapCount, "There should be \(tapCount) rows(s) in the list.")
		}
	}
//	func testAddingItemInsertsRows() {
//		app.buttons["Open"].tap()
//		XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
//		app.buttons["Add Project"].tap()
//		XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
//		app.buttons["Add New Item"].tap()
//		XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
//	}
//	func testEditingProjectUpdatesCorrectly() {
//		app.buttons["Open"].tap()
//		XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
//		app.buttons["add"].tap()
//		XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
//		app.buttons["NEW PROJECT"].tap()
//		app.textFields["Project name"].tap()
//	}
}
