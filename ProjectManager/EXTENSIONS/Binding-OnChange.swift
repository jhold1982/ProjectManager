//
//  Binding-OnChange.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/29/22.
//

import SwiftUI

extension Binding {
	
	
	func onChange(_ handler: @escaping () -> Void) -> Binding<Value> {
		Binding(
			get: { self.wrappedValue },
			set: { newValue in
				self.wrappedValue = newValue
				handler()
			}
		)
	}
}
