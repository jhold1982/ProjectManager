//
//  HomeView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 11/27/22.
//
import CoreData
import SwiftUI

struct HomeView: View {
	static let tag: String? = "Home"
	@EnvironmentObject var dataController: DataController
	@FetchRequest(
		entity: Project.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Project.title, ascending: true)],
		predicate: NSPredicate(format: "closed = false"))
	var projects: FetchedResults<Project>
	let items: FetchRequest<Item>
	var projectRows: [GridItem] {
		[GridItem(.fixed(100))]
	}
	// MARK: FETCH REQUEST INITIALIZER - COMPOUND PREDICATE
	// This is to ensure "Completed Projects" don't show on the "Home" Tab
	init() {
		// Construct a fetch request showing the 10 highest-priority,
		// incomplete items from an open project.
		let request: NSFetchRequest<Item> = Item.fetchRequest()
		let completedPredicate = NSPredicate(format: "completed = false")
		let openPredicate = NSPredicate(format: "project.closed = false")
		let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [completedPredicate, openPredicate])
		request.predicate = compoundPredicate
		request.sortDescriptors = [
			NSSortDescriptor(keyPath: \Item.priority, ascending: false)
		]
		request.fetchLimit = 10
		items = FetchRequest(fetchRequest: request)
	}
    var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading) {
					ScrollView(.horizontal, showsIndicators: false) {
						LazyHGrid(rows: projectRows) {
							ForEach(projects, content: ProjectSummaryView.init)
						}
						.padding([.horizontal, .top])
						.fixedSize(horizontal: false, vertical: true)
					}
					VStack(alignment: .leading) {
						ItemListView(title: "Up Next", items: items.wrappedValue.prefix(3))
						ItemListView(title: "More To Explore", items: items.wrappedValue.dropFirst(3))
					}
					.padding(.horizontal)
				}
			}
			// MARK: BUTTON FOR TESTING ADDING DATA
			.toolbar {
				Button("Add Data") {
				   dataController.deleteAll()
				   try? dataController.createSampleData()
				}
			}
			.background(Color.systemGroupedBackground.ignoresSafeArea())
			.navigationTitle("Home")
		}
    }
}

struct HomeView_Previews: PreviewProvider {
	static var dataController = DataController.preview
    static var previews: some View {
		HomeView()
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
    }
}
