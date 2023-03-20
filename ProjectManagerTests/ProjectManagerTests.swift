//
//  ProjectManagerTests.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 12/8/22.
//
import CoreData
import XCTest
@testable import ProjectManager

class BaseTestCase: XCTestCase {
	var dataController: DataController!
	var managedObjectContext: NSManagedObjectContext!

	override func setUpWithError() throws {
		dataController = DataController(inMemory: true)
		managedObjectContext = dataController.container.viewContext
	}
}
