//
//  PerformanceTests.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 2/26/23.
//

import XCTest
@testable import ProjectManager

class PerformanceTests: BaseTestCase {
	func testAwardCalculationPerformanceBasic() throws {
		try dataController.createSampleData()
		let awards = Award.allAwards
		measure {
			_ = awards.filter(dataController.hasEarned)
		}
	}
	func testAwardCalculationPerformanceAdvanced() throws {
		// Create a significant amount of test data
		for _ in 1...100 {
			try dataController.createSampleData()
		}
		// Simulate lots of awards to check
		let awards = Array(repeating: Award.allAwards, count: 25).joined()
		XCTAssertEqual(
			awards.count,
			500,
			"This checks the awards count is constant. Change this if you add awards."
		)
		measure {
			_ = awards.filter(dataController.hasEarned).count
		}
	}
}
