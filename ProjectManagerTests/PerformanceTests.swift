//
//  PerformanceTests.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 12/10/22.
//

import XCTest
@testable import ProjectManager

final class PerformanceTests: BaseTestCase {
	func testAwardCalculationPerformance() throws {
		// Create a significant amount of sample data
		for _ in 1...100 {
			try dataController.createSampleData()
		}
		// Simulate a large amount of awards to check
		let awards = Array(repeating: Award.allAwards, count: 25).joined()
		XCTAssertEqual(awards.count, 500, "This checks the number of awards is constant. Change this if you add new awards.")
		measure {
			_ = awards.filter(dataController.hasEarned)
		}
	}
}
