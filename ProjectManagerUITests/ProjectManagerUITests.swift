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
		XCTAssertEqual(app.tables.cells.count, 0, "There should be zero list rows initially.")
		for _ in 1...5 {
			app.buttons["Add Project"].tap()
			XCTAssertEqual(app.tables.cells.count, 5, "There should be 5 list rows.")
		}
	}
	func testAddingItemInsertsRows() {
		app.buttons["Open"].tap()
		XCTAssertEqual(app.tables.cells.count, 0, "There should be zero list rows.")
		app.buttons["Add Project"].tap()
//		XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
		app.buttons["Add New Item"].tap()
//		XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
	}
	func testEditingProjectUpdatesCorrectly() {
		app.buttons["Open"].tap()
		XCTAssertEqual(app.tables.cells.count, 0, "There should be zero list rows.")
		app.buttons["Add Project"].tap()
//		XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
		app.buttons["COMPOSE"].tap()
		app.textFields["Project Name"].tap()
		app.keys["space"].tap()
		app.keys["more"].tap()
		app.keys["2"].tap()
		app.buttons["Return"].tap()
		app.buttons["Open Projects"].tap()
//			XCTAssertTrue(app.buttons["New Project 2"].exists,
//				"The new project name should be visible in the list.")
	}
	func testEditingItemUpdatesCorrectly() {
//		app.buttons["Open"].tap()
//		XCTAssertEqual(app.tables.cells.count, 0, "There should be no list rows initially.")
//		app.buttons["Add Project"].tap()
//		XCTAssertEqual(app.tables.cells.count, 1, "There should be 1 list row after adding a project.")
//		app.buttons["Add New Item"].tap()
//  	XCTAssertEqual(app.tables.cells.count, 2, "There should be 2 list rows after adding an item.")
        // Go to Open Projects and add one project and one item.
		testAddingItemInsertsRows()
		app.buttons["New Item"].tap()
		app.textFields["Item Name"].tap()
		app.keys["space"].tap()
		app.keys["more"].tap()
		app.keys["2"].tap()
		app.buttons["Return"].tap()
		app.buttons["Open Projects"].tap()
//		XCTAssertTrue(app.buttons["New Item 2"].exists, "The new item name should be visible in the list.")
	}
	func testAllAwardsShowLockedAlert() {
		app.buttons["Awards"].tap()
		for award in app.scrollViews.buttons.allElementsBoundByIndex {
			award.tap()
//			XCTAssertTrue(app.alerts["Locked"].exists, "There should be a Locked alert showing for awards.")
			app.buttons["Okay"].tap()
		}
	}
}
