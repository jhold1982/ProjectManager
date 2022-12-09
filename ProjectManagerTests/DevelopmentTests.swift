//
//  DevelopmentTests.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 12/9/22.
//

import CoreData
import XCTest
@testable import ProjectManager

final class DevelopmentTests: BaseTestCase {
	func testSampleDataCreationWorks() throws {
		try dataController.createSampleData()
		XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 5,
		"There should be at least 5 sample projects.")
		XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 50,
		"There should be at least 50 sample items.")
	}
	func testDeleteAllClearsEverything() throws {
		try dataController.createSampleData()
		dataController.deleteAll()
		XCTAssertEqual(dataController.count(for: Project.fetchRequest()), 0, "There should be Zero projects.")
		XCTAssertEqual(dataController.count(for: Item.fetchRequest()), 0, "There should be Zero items.")
	}
	func testExampleProjectIsClosed() {
		let project = Project.example
		XCTAssertTrue(project.closed, "This example project should return closed.")
	}
	func testExampleItemIsHighPriority() {
		let item = Item.example
		XCTAssertEqual(item.priority, 3, "This example item should return high priority.")
	}
}
