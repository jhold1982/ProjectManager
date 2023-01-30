//
//  CloudError.swift
//  ProjectManager
//
//  Created by Justin Hold on 1/24/23.
//

import SwiftUI

struct CloudError: Identifiable, ExpressibleByStringInterpolation {
	var id: String { message }
	var message: String
	var localizedMessage: LocalizedStringKey {
		LocalizedStringKey(message)
	}
	init(stringLiteral value: String) {
		self.message = value
	}
}
