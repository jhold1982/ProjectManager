//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 11/26/22.
//

import CoreData
import CoreSpotlight
import UserNotifications
import SwiftUI

/// An environment singleton respoonsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {
	/// This is the lone CloudKit container used to store all of our data
	let container: NSPersistentCloudKitContainer
	/// This initializes a Data Controller either in memory for temp use or on perm storage.
	/// Defaults to perm storage.
	/// - Parameter inMemory: Whether to store this data in temp memory or not.
	init(inMemory: Bool = false) {
		container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
		// For testing purposes, this creates a temp in-memory
		// database by writing to /dev/null so our data is
		// destroyed after the app finishes running.
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		}
		container.loadPersistentStores { _, error in
			if let error = error {
				fatalError("Fatal error loading store: \(error.localizedDescription)")
			}
			#if DEBUG
			if CommandLine.arguments.contains("enable-testing") {
				self.deleteAll()
				UIView.setAnimationsEnabled(false)
			}
			#endif
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
	static let model: NSManagedObjectModel = {
		guard let url = Bundle.main.url(forResource: "Main", withExtension: "momd") else {
			fatalError("Failed to locate model file.")
		}
		guard let managedObjectModel = NSManagedObjectModel(contentsOf: url) else {
			fatalError("Failed to load model file.")
		}
		return managedObjectModel
	}()
	/// Creates example projects and items for manual testing.
	/// - Throws: An NSError sent from calling save() on the NSManagedObjectContext
	func createSampleData() throws {
		let viewContext = container.viewContext
		for projectCounter in 1...5 {
			let project = Project(context: viewContext)
			project.title = "Project \(projectCounter)"
			project.items = []
			project.creationDate = Date()
			project.closed = Bool.random()
			for itemCounter in 1...10 {
				let item = Item(context: viewContext)
				item.title = "Item \(itemCounter)"
				item.creationDate = Date()
				item.completed = Bool.random()
				item.project = project
				item.priority = Int16.random(in: 1...3)
			}
		}
		try viewContext.save()
	}
	/// Saves our Core Data context if and only if there are changes. This silently
	/// ignores any errors caused by saving, but this should be fine because our
	/// attributes are optional.
	func save() {
		if container.viewContext.hasChanges {
			try? container.viewContext.save()
		}
	}
	func delete(_ object: Project) {
		let id = object.objectID.uriRepresentation().absoluteString
		CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
		container.viewContext.delete(object)
	}
	func delete(_ object: Item) {
		let id = object.objectID.uriRepresentation().absoluteString
		CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
		container.viewContext.delete(object)
	}
	// delete method as a single func
//	func delete(_ object: NSManagedObject) {
//		let id = object.objectID.uriRepresentation().absoluteString
//		if object is Item {
//			CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [id])
//		} else {
//			CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [id])
//		}
//		container.viewContext.delete(object)
//	}

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
			// returns true if user added a certain number of items.
			let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value
		case "complete":
			// returns true if user completed a certain number of items.
			let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
			fetchRequest.predicate = NSPredicate(format: "completed = true")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value
		default:
			// an unknown award criterion; this should never be allowed.
//			fatalError("Unknown award criterion: \(award.criterion)")
			return false
		}
	}
	// enables ability to write to Spotlight
	func update(_ item: Item) {
		let itemID = item.objectID.uriRepresentation().absoluteString
		let projectID = item.project?.objectID.uriRepresentation().absoluteString
		let attributeSet = CSSearchableItemAttributeSet(contentType: .text)
		attributeSet.title = item.itemTitle
		attributeSet.contentDescription = item.itemDetail
		let searchableItem = CSSearchableItem(
			uniqueIdentifier: itemID,
			domainIdentifier: projectID,
			attributeSet: attributeSet
		)
		CSSearchableIndex.default().indexSearchableItems([searchableItem])
		save()
	}
	func item(with uniqueIdentifier: String) -> Item? {
		// if invalid url, fail
		guard let url = URL(string: uniqueIdentifier) else {
			return nil
		}
		// if valid url but invalid objectID, fail
		guard let id = container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url) else {
			return nil
		}
		// if unable to find object as an Item, fail
		return try? container.viewContext.existingObject(with: id) as? Item
	}
	func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
		let center = UNUserNotificationCenter.current()
		center.getNotificationSettings { settings in
			switch settings.authorizationStatus {
			case .notDetermined:
				self.requestNotification { success in
					if success {
						self.placeReminders(for: project, completion: completion)
					} else {
						DispatchQueue.main.async {
							completion(false)
						}
					}
				}
			case .authorized:
				self.placeReminders(for: project, completion: completion)
			default:
				DispatchQueue.main.async {
					completion(false)
				}
			}
		}
	}
	func removeReminders(for project: Project) {
		let center = UNUserNotificationCenter.current()
		let id = project.objectID.uriRepresentation().absoluteString
		center.removePendingNotificationRequests(withIdentifiers: [id])
	}
	private func requestNotification(completion: @escaping (Bool) -> Void) {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
			completion(granted)
		}
	}
	private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
		let content = UNMutableNotificationContent()
		content.title = project.projectTitle
		content.sound = .default
		if let projectDetail = project.detail {
			content.subtitle = projectDetail
		}
		let components = Calendar.current.dateComponents(
			[.hour, .minute],
			from: project.reminderTime ?? Date()
		)
		let trigger = UNCalendarNotificationTrigger(
			dateMatching: components,
			repeats: true
		)
		let id = project.objectID.uriRepresentation().absoluteString
		let request = UNNotificationRequest(
			identifier: id,
			content: content,
			trigger: trigger
		)
		UNUserNotificationCenter.current().add(request) { error in
			DispatchQueue.main.async {
				if error == nil {
					completion(true)
				} else {
					completion(false)
				}
			}
		}
	}
}
