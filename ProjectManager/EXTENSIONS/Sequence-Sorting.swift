//
//  Sequence-Sorting.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/1/22.
//

import Foundation

extension Sequence {
	func sorted<Value>(by keyPath: KeyPath<Element, Value>, using areInIncreasingOrder: (Value, Value) throws -> Bool) rethrows -> [Element] {
		try self.sorted {
			try areInIncreasingOrder($0[keyPath: keyPath], $1[keyPath: keyPath])
		}
	}

	func sorted<Value: Comparable>(by keyPath: KeyPath<Element, Value>) -> [Element] {
		self.sorted(by: keyPath, using: <)
	}
}
