//
//  ProjectManagerTests.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 2/25/23.
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
