//
//  AwardsTest.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 12/8/22.
//
import CoreData
import XCTest
@testable import ProjectManager

final class AwardsTest: BaseTestCase {
	let awards = Award.allAwards
	// This test method ensures that award ID and name match
	func testAwardIDMatchesName() {
		for award in awards {
			XCTAssertEqual(award.id, award.name, "Award ID should always match its name.")
		}
	}
	// This test method ensures that a new user starts with zero awards
	func testNewUserHasZeroAwards() {
		for award in awards {
			XCTAssertFalse(dataController.hasEarned(award: award), "New users should have zero unlocked awards.")
		}
	}
	// This test method checks that adding items unlocks awards
	func testAddingItems() {
		let values = [1, 10, 20, 50, 100, 250, 500, 1000]
		for (count, value) in values.enumerated() {
			var items = [Item]()
			for _ in 0..<value {
				let item = Item(context: managedObjectContext)
				items.append(item)
			}
			let matches = awards.filter { award in
				award.criterion == "items" && dataController.hasEarned(award: award)
			}
			XCTAssertEqual(matches.count, count + 1, "Adding \(value) items should unlock \(count + 1) awards.")
			for item in items {
				dataController.delete(item)
			}
		}
	}
	// This test method checks that awards value matches complete items value
	func testCompletingItems() {
		let values = [1, 10, 20, 50, 100, 250, 500, 1000]
		for (count, value) in values.enumerated() {
			var items = [Item]()
			for _ in 0..<value {
				let item = Item(context: managedObjectContext)
				item.completed = true
				items.append(item)
			}
			let matches = awards.filter { award in
				award.criterion == "complete" && dataController.hasEarned(award: award)
			}
			XCTAssertEqual(matches.count, count + 1, "Completing \(value) items should unlock \(count + 1) awards.")
			for item in items {
				dataController.delete(item)
			}
		}
	}
}
