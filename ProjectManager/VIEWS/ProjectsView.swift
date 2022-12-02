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
	
	var body: some View {
		
		NavigationView {
			Group {
				if projects.wrappedValue.isEmpty {
					Text("Move along, nothing to see here.")
						.foregroundColor(.secondary)
				} else {
					List {
						
						// MARK: OUTER FOREACH
						ForEach(projects.wrappedValue) { project in
							Section(header: ProjectHeaderView(project: project)) {
								
								// MARK: INNER FOREACH
								ForEach(project.projectItems(using: sortOrder)) { item in
									ItemRowView(project: project, item: item)
								}
								.onDelete { offsets in
									let allItems = project.projectItems(using: sortOrder)
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
				}
			}
			.navigationTitle(showClosedProjects ? "Closed Projects" : "Open Projects")
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
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
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						showingSortOrder.toggle()
					} label: {
						Label("Sort", systemImage: "arrow.up.arrow.down")
					}
				}
			}
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
}



struct ProjectsView_Previews: PreviewProvider {

	static var dataController = DataController.preview
    static var previews: some View {

		ProjectsView(showClosedProjects: false)
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
    }
}
