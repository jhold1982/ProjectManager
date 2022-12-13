//
//  ProjectsViewModel.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/13/22.
//

import CoreData
import Foundation
import SwiftUI

extension ProjectsView {
	class ViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
		let dataController: DataController
		let showClosedProjects: Bool
		private let projectsController: NSFetchedResultsController<Project>
		@Published var projects = [Project]()
		var sortOrder = Item.SortOrder.optimized
		init(dataController: DataController, showClosedProjects: Bool) {
			self.dataController = dataController
			self.showClosedProjects = showClosedProjects
			let request: NSFetchRequest<Project> = Project.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)]
			request.predicate = NSPredicate(format: "closed = %d", showClosedProjects)
			projectsController = NSFetchedResultsController(
				fetchRequest: request,
				managedObjectContext: dataController.container.viewContext,
				sectionNameKeyPath: nil,
				cacheName: nil
			)
			super.init()
			projectsController.delegate = self
			do {
				try projectsController.performFetch()
				projects = projectsController.fetchedObjects ?? []
			} catch {
				print("Failed to fetch our projects.")
			}
		}
		func addProject() {
			let project = Project(context: dataController.container.viewContext)
			project.closed = false
			project.creationDate = Date()
			dataController.save()
		}
		func addItem(to project: Project) {
			let item = Item(context: dataController.container.viewContext)
			item.project = project
			item.creationDate = Date()
			dataController.save()
		}
		func delete(_ offsets: IndexSet, from project: Project) {
			let allItems = project.projectItems(using: sortOrder)
			for offset in offsets {
				let item = allItems[offset]
				dataController.delete(item)
			}
			dataController.save()
		}
		func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
			if let newProjects = controller.fetchedObjects as? [Project] {
				projects = newProjects
			}
		}
	}
}
