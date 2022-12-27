//
//  ProjectManagerApp.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/27/22.
//

import SwiftUI

@main
struct ProjectManagerApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@StateObject var dataController: DataController
	@StateObject var unlockManager: UnlockManager
	init() {
		let dataController = DataController()
		let unlockManager = UnlockManager(dataController: dataController)
		_dataController = StateObject(wrappedValue: dataController)
		_unlockManager = StateObject(wrappedValue: unlockManager)
	}
    var body: some Scene {
        WindowGroup {
            ContentView()
				.environment(\.managedObjectContext, dataController.container.viewContext)
				.environmentObject(dataController)
				.environmentObject(unlockManager)
				.onReceive(
					// Auto save when we detect that we are no longer
					// the foreground app. Use this rather than the
					// scene phase API so we can port to macOS, where
					// scene phase the app losing focus as of macOS 11.1.
					NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
					perform: save
				)
				.onAppear(perform: dataController.appLaunched)
        }
    }
	func save(_ note: Notification) {
		dataController.save()
	}
}
