//
//  AssetTest.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 12/8/22.
//

import XCTest
@testable import ProjectManager

final class AssetTest: XCTestCase {
    func testColorsExist() {
		for color in Project.colors {
			XCTAssertNotNil(UIColor(named: color), "Failed to load color '\(color)' from asset catalog.")
		}
    }
	func testJSONLoadsCorrectly() {
		XCTAssertFalse(Award.allAwards.isEmpty, "Failed to load awards from JSON")
	}
}
