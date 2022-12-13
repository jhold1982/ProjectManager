//
//  ProjectsView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 11/27/22.
//

import SwiftUI

struct ProjectsView: View {
	static let openTag: String? = "Open"
	static let closedTag: String? = "Closed"
	@EnvironmentObject var dataController: DataController
	@Environment(\.managedObjectContext) var managedObjectContext
	@State private var showingSortOrder = false
	@State private var sortOrder = Item.SortOrder.optimized
	let showClosedProjects: Bool
	let projects: FetchRequest<Project>
	init(showClosedProjects: Bool) {
		self.showClosedProjects = showClosedProjects
		projects = FetchRequest<Project>(entity: Project.entity(), sortDescriptors: [
			NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)
		], predicate: NSPredicate(format: "closed = %d", showClosedProjects))
	}
	// MARK: PROJECTS LIST FOR GROUP IF ELSE VIEW
	var projectsList: some View {
		List {
			ForEach(projects.wrappedValue) { project in
				Section(header: ProjectHeaderView(project: project)) {
					ForEach(project.projectItems(using: sortOrder)) { item in
						ItemRowView(project: project, item: item)
					}
					.onDelete { offsets in
						delete(offsets, from: project)
					}
					if showClosedProjects == false {
						Button {
							addItem(to: project)
						} label: {
							Label("Add New Item", systemImage: "plus")
						}
					}
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
	}
	// MARK: ADD PROJECT BUTTON
	var addProjectToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarTrailing) {
			if showClosedProjects == false {
				Button(action: addProject) {
					// In iOS 14.3 VoiceOver has a glitch that reads the label
					// "Add Project" as "Add" no matter what accessibility label
					// we give this button when using a label. As a result, when
					// VoiceOver is running we use a text view for the button instead,
					// forcing a correct reading without losing the original layout.
					if UIAccessibility.isVoiceOverRunning {
						Text("Add Project")
					} else {
						Label("Add Project", systemImage: "plus")
					}
				}
			}
		}
	}
	// MARK: SORT ORDER BUTTON
	var sortOrderToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				showingSortOrder.toggle()
			} label: {
				Label("Sort", systemImage: "arrow.up.arrow.down")
			}
		}
	}
	var body: some View {
		NavigationView {
			Group {
				if projects.wrappedValue.isEmpty {
					Text("Move along, nothing to see here.")
						.foregroundColor(.secondary)
				} else {
					projectsList
				}
			}
			.navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
			.toolbar {
				addProjectToolbarItem
				sortOrderToolbarItem
			}
			// MARK: ACTION SHEET FOR SORT ORDER
			.actionSheet(isPresented: $showingSortOrder) {
				ActionSheet(title: Text("Sort Items"), message: nil, buttons: [
					.default(Text("Optimized")) { sortOrder = .optimized },
					.default(Text("Creation Date")) { sortOrder = .creationDate },
					.default(Text("Title")) { sortOrder = .title }
				])
			}
			SelectSomethingView()
		}
	}
	// MARK: FUNCTIONS
	func addProject() {
		withAnimation {
			let project = Project(context: managedObjectContext)
			project.closed = false
			project.creationDate = Date()
			dataController.save()
		}
	}
	func addItem(to project: Project) {
		withAnimation {
			let item = Item(context: managedObjectContext)
			item.project = project
			item.creationDate = Date()
			dataController.save()
		}
	}
	func delete(_ offsets: IndexSet, from project: Project) {
		let allItems = project.projectItems(using: sortOrder)
		for offset in offsets {
			let item = allItems[offset]
			dataController.delete(item)
		}
		dataController.save()
	}
}
struct ProjectsView_Previews: PreviewProvider {
	static var dataController = DataController.preview
    static var previews: some View {
		ProjectsView(showClosedProjects: false)
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
    }
}
