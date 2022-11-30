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
	
	let showClosedProjects: Bool
	
	let projects: FetchRequest<Project>
	
	init(showClosedProjects: Bool) {
		
		self.showClosedProjects = showClosedProjects
		
		projects = FetchRequest<Project>(entity: Project.entity(), sortDescriptors: [
			NSSortDescriptor(keyPath: \Project.creationDate, ascending: false)
		], predicate: NSPredicate(format: "closed = %d", showClosedProjects))
		
	}
	
	var body: some View {
		
		NavigationView {
			List {
				
				// MARK: OUTER FOREACH
				ForEach(projects.wrappedValue) { project in
					Section(header: ProjectHeaderView(project: project)) {
						
						// MARK: INNER FOREACH
						ForEach(project.projectItems) { item in
							ItemRowView(item: item)
						}
						.onDelete { offsets in
							let allItems = project.projectItems
							for offset in offsets {
								let item = allItems[offset]
								dataController.delete(item)
							}
							dataController.save()
						}
						if showClosedProjects == false {
							Button {
								withAnimation {
									let item = Item(context: managedObjectContext)
									item.project = project
									item.creationDate = Date()
									dataController.save()
								}
							} label: {
								Label("Add new item", systemImage: "plus")
							}
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
			.navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
			.toolbar {
				if showClosedProjects == false {
					Button {
						withAnimation {
							let project = Project(context: managedObjectContext)
							project.closed = false
							project.creationDate = Date()
							dataController.save()
						}
					} label: {
						Label("Add project", systemImage: "plus")
					}
				}
			}
		}
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
