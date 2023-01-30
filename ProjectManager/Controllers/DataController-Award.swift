//
//  DataController-Award.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/27/22.
//

import CoreData
import Foundation

extension DataController {
	func hasEarned(award: Award) -> Bool {
		switch award.criterion {
		case "items":
			// returns true if user added a certain number of items.
			let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value
		case "complete":
			// returns true if user completed a certain number of items.
			let fetchRequest: NSFetchRequest<Item> = NSFetchRequest(entityName: "Item")
			fetchRequest.predicate = NSPredicate(format: "completed = true")
			let awardCount = count(for: fetchRequest)
			return awardCount >= award.value
		case "chat":
			// returns true if posted X number of chat messages
			return UserDefaults.standard.integer(forKey: "chatCount") >= award.value
		default:
			// an unknown award criterion; this should never be allowed.
//			fatalError("Unknown award criterion: \(award.criterion)")
			return false
		}
	}
}
