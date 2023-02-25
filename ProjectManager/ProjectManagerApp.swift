//
//  ProjectManagerApp.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/27/22.
//

import SwiftUI

@main
struct ProjectManagerApp: App {
	@StateObject var dataController: DataController
	init() {
		let dataController = DataController()
		_dataController = StateObject(wrappedValue: dataController)
	}
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, dataController.container.viewContext)
				.environmentObject(dataController)
				.onReceive(
					// Auto save when we detect that we are no longer
					// the foreground app. Use this rather than the
					// scene phase API so we can port to macOS, where
					// scene phase the app losing focus as of macOS 11.1.
					NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
					perform: save
				)
        }
    }
	func save(_ note: Notification) {
		dataController.save()
	}
}
