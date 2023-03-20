//
//  SharedProject.swift
//  ProjectManager
//
//  Created by Justin Hold on 1/10/23.
//

import Foundation

struct SharedProject: Identifiable {
	let id: String
	let title: String
	let detail: String
	let owner: String
	let closed: Bool
	static let example = SharedProject(id: "1", title: "Example", detail: "Detail", owner: "leftHandedApps", closed: false)
}
