//
//  Item-CoreDataHelpers.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/28/22.
//

import Foundation


extension Item {
	
	enum SortOrder {
		case optimized, title, creationDate
	}
	
	var itemTitle: String {
		title ?? ""
	}
	
	var itemDetail: String {
		detail ?? ""
	}
	
	var itemCreationDate: Date {
		creationDate ?? Date()
	}
	
	static var example: Item {
		
		let controller = DataController(inMemory: true)
		let viewContext = controller.container.viewContext
		
		let item = Item(context: viewContext)
		item.title = "Example Item"
		item.detail = "This is an example item"
		item.priority = 3
		item.creationDate = Date()
		
		return item
	}
}
