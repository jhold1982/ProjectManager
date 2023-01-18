//
//  SharedItemsView.swift
//  ProjectManager
//
//  Created by Justin Hold on 1/16/23.
//

import CloudKit
import SwiftUI

struct SharedItemsView: View {
	let project: SharedProject
	@State private var items = [SharedItem]()
	@State private var itemsLoadState = LoadState.inactive
    var body: some View {
		List {
			Section {
				switch itemsLoadState {
				case .inactive, .loading:
					ProgressView()
				case .noResults:
					Text("No Results")
				case .success:
					ForEach(items) { item in
						VStack(alignment: .leading) {
							Text(item.title)
								.font(.headline)
							if item.detail.isEmpty == false {
								Text(item.detail)
							}
						}
					}
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
		.navigationTitle(project.title)
		.onAppear {
			fetchSharedItems()
		}
    }
	func fetchSharedItems() {
		guard itemsLoadState == .inactive else { return }
		itemsLoadState = .loading
		let recordID = CKRecord.ID(recordName: project.id)
		let reference = CKRecord.Reference(recordID: recordID, action: .none)
		let pred = NSPredicate(format: "project == %@", reference)
		let sort = NSSortDescriptor(key: "title", ascending: true)
		let query = CKQuery(recordType: "Item", predicate: pred)
		query.sortDescriptors = [sort]
		let operation = CKQueryOperation(query: query)
		operation.desiredKeys = ["title", "detail", "completed"]
		operation.resultsLimit = 50
		operation.recordFetchedBlock = { record in
			let id = record.recordID.recordName
			let title = record["title"] as? String ?? "No Title"
			let detail = record["detail"] as? String ?? ""
			let completed = record["completed"] as? Bool ?? false
			let sharedItem = SharedItem(id: id, title: title, detail: detail, completed: completed)
			items.append(sharedItem)
			itemsLoadState = .success
		}
		operation.queryCompletionBlock = { _, _ in
			if items.isEmpty {
				itemsLoadState = .noResults
			}
		}
		CKContainer.default().publicCloudDatabase.add(operation)
	}
}

struct SharedItemsView_Previews: PreviewProvider {
    static var previews: some View {
		SharedItemsView(project: SharedProject.example)
    }
}
