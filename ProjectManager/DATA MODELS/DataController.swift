//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 11/26/22.
//

import CoreData
import SwiftUI

class DataController: ObservableObject {
	
	let container: NSPersistentCloudKitContainer
	
	init(inMemory: Bool = false) {
		container = NSPersistentCloudKitContainer(name: "Main")
		
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}
		
		container.loadPersistentStores { storeDescription, error in
			if let error = error {
				fatalError("Fatal error loading store: \(error.localizedDescription)")
			}
		}
	}
	
	static var preview: DataController = {
		
		let dataController = DataController(inMemory: true)
		let viewContext = dataController.container.viewContext
		
		do {
			try dataController.createSampleData()
		} catch {
			fatalError("Fatal error creating preview: \(error.localizedDescription)")
		}
		
		return dataController
	}()
	
	func createSampleData() throws {
		let viewContext = container.viewContext
		
		for i in 1...5 {
			let project = Project(context: viewContext)
			project.title = "Project \(i)"
			project.items = []
			project.creationDate = Date()
			project.closed = Bool.random()
			
			for j in 1...10 {
				let item = Item(context: viewContext)
				item.title = "Item \(j)"
				item.creationDate = Date()
				item.completed = Bool.random()
				item.project = project
				item.priority = Int16.random(in: 1...3)
			}
		}
		try viewContext.save()
	}
	
	func save() {
		if container.viewContext.hasChanges {
			try? container.viewContext.save()
		}
	}
	
	func delete(_ object: NSManagedObject) {
		container.viewContext.delete(object)
	}
	
	func deleteAll() {
		
		let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Item.fetchRequest()
		let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
		_ = try? container.viewContext.execute(batchDeleteRequest1)
		
		let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
		let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
		_ = try? container.viewContext.execute(batchDeleteRequest2)
	}
	
	func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
		(try? container.viewContext.count(for: fetchRequest)) ?? 0
	}
	
	func hasEarned(award: Award) -> Bool {
		switch award.criterion {
		case "items":
			let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value
			
		case "complete":
			let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
			fetchRequest.predicate = NSPredicate(format: "completed = true")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value
			
		default:
//			fatalError("Unknown award criterion: \(award.criterion)")
			return false
		}
	}
}
