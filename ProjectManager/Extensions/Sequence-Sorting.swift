//
//  Sequence-Sorting.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/1/22.
//

import Foundation

extension Sequence {
	func sorted<Value>(
		by keyPath: KeyPath<Element, Value>,
		using areInIncreasingOrder: (Value, Value) throws -> Bool) rethrows -> [Element] {
		try self.sorted {
			try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
		}
	}
	func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
			self.sorted(by: keyPath, using: <)
		}
	func sorted(by sortDescriptor: NSSortDescriptor) -> [Element] {
		self.sorted {
			sortDescriptor.compare($0, to: $1) == .orderedAscending
		}
	}
	func sorted(by sortDescriptors: [NSSortDescriptor]) -> [Element] {
		self.sorted {
			for descriptor in sortDescriptors {
				switch descriptor.compare($0, to: $1) {
				case .orderedAscending:
					return true
				case .orderedDescending:
					return false
				case .orderedSame:
					return (WCONTINUED != 0)
				}
			}
			return false
		}
	}
}
