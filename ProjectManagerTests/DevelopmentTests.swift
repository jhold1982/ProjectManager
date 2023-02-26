//
//  DevelopmentTests.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 2/26/23.
//

import XCTest
import CoreData
@testable import ProjectManager

class DevelopmentTests: BaseTestCase {
	func testSampleDataCreationWorks() throws {
		try dataController.createSampleData()
		XCTAssertEqual(
			dataController.count(for: Project.fetchRequest()),
			5,
			"There should be 5 sample projects."
		)
		XCTAssertEqual(
			dataController.count(for: Item.fetchRequest()),
			50,
			"There should be 5 sample items."
		)
	}
	func testSampleDataDeletionWorks() throws {
		try dataController.createSampleData()
		dataController.deleteAll()
		XCTAssertEqual(
			dataController.count(for: Project.fetchRequest()),
			0,
			"There should be zero sample projects."
		)
		XCTAssertEqual(
			dataController.count(for: Item.fetchRequest()),
			0,
			"There should be zero sample items."
		)
	}
	func testExampleProjectIsClosed() {
		let project = Project.example
		XCTAssertTrue(project.closed, "The example project should be closed.")
	}
	func testExampleItemIsHighPriority() {
		let item = Item.example
		XCTAssertEqual(item.priority, 3, "The example item priority should be high.")
	}
}
