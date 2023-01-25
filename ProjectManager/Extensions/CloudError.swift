//
//  CloudError.swift
//  ProjectManager
//
//  Created by Justin Hold on 1/24/23.
//

import Foundation

struct CloudError: Identifiable, ExpressibleByStringInterpolation {
	var id: String { message }
	var message: String
	init(stringLiteral value: String) {
		self.message = value
	}
}
