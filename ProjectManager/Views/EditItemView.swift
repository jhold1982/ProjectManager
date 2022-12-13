//
//  EditItemView.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/29/22.
//

import SwiftUI

struct EditItemView: View {
	let item: Item
	init(item: Item) {
		self.item = item
		_title = State(wrappedValue: item.itemTitle)
		_detail = State(wrappedValue: item.itemDetail)
		_priority = State(wrappedValue: Int(item.priority))
		_completed = State(wrappedValue: item.completed)
	}
	@EnvironmentObject var dataController: DataController
	@State private var title: String
	@State private var detail: String
	@State private var priority: Int
	@State private var completed: Bool
    var body: some View {
		Form {
			Section(header: Text("Basic Settings")) {
				TextField("Item Name", text: $title.onChange(update))
				TextField("Description", text: $detail.onChange(update))
			}
			Section(header: Text("Priority")) {
				Picker("Priority", selection: $priority.onChange(update)) {
					Text("Low").tag(1)
					Text("Medium").tag(2)
					Text("High").tag(3)
				}
				.pickerStyle(SegmentedPickerStyle())
			}
			Section {
				Toggle("Mark Completed", isOn: $completed.onChange(update))
			}
		}
		// MARK: FORM MODIFIERS
		.navigationTitle("Edit Item")
		.onDisappear(perform: update)
    }
	func update() {
		item.project?.objectWillChange.send()
		item.title = title
		item.detail = detail
		item.priority = Int16(priority)
		item.completed = completed
	}
}

struct EditItemView_Previews: PreviewProvider {
    static var previews: some View {
		EditItemView(item: Item.example)
    }
}
