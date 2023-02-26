//
//  ExtensionTests.swift
//  ProjectManagerTests
//
//  Created by Justin Hold on 2/26/23.
//

import XCTest
import SwiftUI
@testable import ProjectManager

class ExtensionTests: XCTestCase {
	func testSequenceKeyPathSortingSelf() {
		let items = [1, 4, 3, 2, 5]
		let sortedItems = items.sorted(by: \.self)
		XCTAssertEqual(
			sortedItems,
			[1, 2, 3, 4, 5],
			"The sorted items must be ascending."
		)
	}
	func testSequenceKeyPathSortingCustom() {
		struct Example: Equatable {
			let value: String
		}
		let example1 = Example(value: "a")
		let example2 = Example(value: "b")
		let example3 = Example(value: "c")
		let example4 = Example(value: "d")
		let example5 = Example(value: "e")
		let example6 = Example(value: "f")
		let example7 = Example(value: "g")
		let array = [
			example1,
			example2,
			example3,
			example4,
			example5,
			example6,
			example7
		]
		let sortedItems = array.sorted(by: \.value) {
			$0 > $1
		}
		XCTAssertEqual(
			sortedItems, [
				example7,
				example6,
				example5,
				example4,
				example3,
				example2,
				example1
			],
			"Revered array should yield g, f, e, d, c, b, a"
		)
	}
	func testBundleDecodingAwards() {
		let awards = Bundle.main.decode([Award].self, from: "Awards.json")
		XCTAssertFalse(awards.isEmpty, "Awards.json should be a non-empty array.")
	}
	func testDecodingString() {
		let bundle = Bundle(for: ExtensionTests.self)
		let data = bundle.decode(String.self, from: "DecodableString.json")
		XCTAssertEqual(
			data,
			"The rain in Spain falls mainly on the Spaniards.",
			"The string must match the content of DecodableString.json."
		)
	}
	func testDecodableDictionary() {
		let bundle = Bundle(for: ExtensionTests.self)
		let data = bundle.decode([String: Int].self, from: "DecodableDictionary.json")
		XCTAssertEqual(data.count, 3, "There should be 3 items decoded from DecodableDictionary.json")
		XCTAssertEqual(data["One"], 1, "The dictionary should contain String to Int mappings.")
	}
	func testBindingOnChange() {
		// Given
		var onChangeFunctionRun = false
		func exampleFunctionToCall() {
			onChangeFunctionRun = true
		}
		var storedValue = ""
		let binding = Binding(
			get: { storedValue },
			set: { storedValue = $0 }
		)
		let changedBinding = binding.onChange(exampleFunctionToCall)
		// When
		changedBinding.wrappedValue = "Test"
		// Then
		XCTAssertTrue(
			onChangeFunctionRun,
			"The onChange() function must be run when the binding is changed."
		)
	}
}