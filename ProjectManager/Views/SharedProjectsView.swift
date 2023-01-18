//
//  SharedProjectsView.swift
//  ProjectManager
//
//  Created by Justin Hold on 1/10/23.
//

import CloudKit
import SwiftUI

struct SharedProjectsView: View {
	static let tag: String? = "Community"
	@State private var projects = [SharedProject]()
	@State private var loadState = LoadState.inactive
    var body: some View {
		NavigationView {
			Group {
				switch loadState {
				case .inactive, .loading:
					ProgressView()
				case .noResults:
					Text("No Results")
				case .success:
					List(projects) { project in
						NavigationLink(destination: SharedItemsView(project: project)) {
							VStack(alignment: .leading) {
								Text(project.title)
									.font(.headline)
								Text(project.owner)
							}
						}
					}
					.listStyle(InsetGroupedListStyle())
				}
			}
			.navigationTitle("Shared Projects")
		}
		.onAppear(perform: fetchSharedProjects)
    }
	func fetchSharedProjects() {
		guard loadState == .inactive else { return }
		loadState = .loading
		let pred = NSPredicate(value: true)
		let sort = NSSortDescriptor(key: "creationDate", ascending: false)
		let query = CKQuery(recordType: "Project", predicate: pred)
		query.sortDescriptors = [sort]
		let operation = CKQueryOperation(query: query)
		operation.desiredKeys = ["title", "detail", "owner", "closed"]
		operation.resultsLimit = 50
		operation.recordFetchedBlock = { record in
			let id = record.recordID.recordName
			let title = record["title"] as? String ?? "No Title"
			let detail = record["detail"] as? String ?? ""
			let owner = record["owner"] as? String ?? "No Owner"
			let closed = record["closed"] as? Bool ?? false
			let sharedProject = SharedProject(id: id, title: title, detail: detail, owner: owner, closed: closed)
			projects.append(sharedProject)
			loadState = .success
		}
		operation.queryResultBlock = { _ in
			if projects.isEmpty {
				loadState = .noResults
			}
		}
		CKContainer.default().publicCloudDatabase.add(operation)
	}
}

struct SharedProjectsView_Previews: PreviewProvider {
    static var previews: some View {
        SharedProjectsView()
    }
}
