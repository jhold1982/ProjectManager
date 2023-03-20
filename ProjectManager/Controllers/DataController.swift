//
//  DataController.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 11/26/22.
//

import CoreData
import CoreSpotlight
import StoreKit
import SwiftUI
import WidgetKit

/// An environment singleton respoonsible for managing our Core Data stack, including handling saving,
/// counting fetch requests, tracking awards, and dealing with sample data.
class DataController: ObservableObject {
	/// This is the lone CloudKit container used to store all of our data
	let container: NSPersistentCloudKitContainer
	/// The UserDefaults suite where we're saving user data
	let defaults: UserDefaults
	/// Loads and saves whether or not premium unlock has been purchased
	var fullVersionUnlocked: Bool {
		get {
			defaults.bool(forKey: "fullVersionUnlocked")
		}
		set {
			defaults.set(newValue, forKey: "fullVersionUnlocked")
		}
	}
	/// This initializes a Data Controller either in memory for temp use or on perm storage.
	/// Defaults to perm storage.
	/// - Parameter inMemory: Whether to store this data in temp memory or not.
	/// - Parameter defaults: The UserDefaults suite where user data should be stored.
	init(inMemory: Bool = false, defaults: UserDefaults = .standard) {
		self.defaults = defaults
		container = NSPersistentCloudKitContainer(name: "Main", managedObjectModel: Self.model)
		// For testing purposes, this creates a temp in-memory
		// database by writing to /dev/null so our data is
		// destroyed after the app finishes running.
		if inMemory {
			container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
		} else {
			let groupID = "group.com.leftHandedApps.ProjectManager"
			if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
				container.persistentStoreDescriptions.first?.url = url.appendingPathComponent("Main.sqlite")
			}
		}
		container.loadPersistentStores { _, error in
			if let error = error {
				fatalError("Fatal error loading store: \(error.localizedDescription)")
			}
			self.container.viewContext.automaticallyMergesChangesFromParent = true
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
			WidgetCenter.shared.reloadAllTimelines()
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
	// delete items and projects as a single function
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
		delete(fetchRequest1)
		let fetchRequest2: NSFetchRequest<NSFetchRequestResult> = Project.fetchRequest()
		delete(fetchRequest2)
	}
	private func delete(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
		let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
		batchDeleteRequest.resultType = .resultTypeObjectIDs
		if let delete = try? container.viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult {
			let changes = [NSDeletedObjectsKey: delete.result as? [NSManagedObjectID] ?? []]
			NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [container.viewContext])
		}
	}
	func count<T>(for fetchRequest: NSFetchRequest<T>) -> Int {
		(try? container.viewContext.count(for: fetchRequest)) ?? 0
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
	func appLaunched() {
		guard count(for: Project.fetchRequest()) >= 5 else { return }
		let allScenes = UIApplication.shared.connectedScenes
		let scene = allScenes.first { $0.activationState == .foregroundActive }
		if let windowScene = scene as? UIWindowScene {
			SKStoreReviewController.requestReview(in: windowScene)
		}
	}
	@discardableResult func addProject() -> Bool {
		let canCreate = fullVersionUnlocked || count(for: Project.fetchRequest()) < 3
		if canCreate {
			let project = Project(context: container.viewContext)
			project.closed = false
			project.creationDate = Date()
			save()
			return true
		} else {
			return false
		}
	}
	func fetchRequestForTopItems(count: Int) -> NSFetchRequest<Item> {
		let itemRequest: NSFetchRequest<Item> = Item.fetchRequest()
		let completedPredicate = NSPredicate(format: "completed = false")
		let openPredicate = NSPredicate(format: "project.closed = false")
		let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
		itemRequest.predicate = compoundPredicate
		itemRequest.sortDescriptors = [
			NSSortDescriptor(keyPath: \Item.priority, ascending: false)
		]
		itemRequest.fetchLimit = count
		return itemRequest
	}
}
