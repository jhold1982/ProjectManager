//
//  ContentView.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/27/22.
//

import CoreSpotlight
import SwiftUI

struct ContentView: View {
	@SceneStorage("selectedView") var selectedView: String?
	@EnvironmentObject var dataController: DataController
	private let newProjectActivity = "com.lefthandedapps.projectmanager.newProject"
	var body: some View {
		TabView(selection: $selectedView) {
			HomeView(dataController: dataController)
				.tag(HomeView.tag)
				.tabItem {
					Label("Home", systemImage: "house")
				}
			ProjectsView(dataController: dataController, showClosedProjects: false)
				.tag(ProjectsView.openTag)
				.tabItem {
					Label("Open", systemImage: "list.bullet")
				}
			ProjectsView(dataController: dataController, showClosedProjects: true)
				.tag(ProjectsView.closedTag)
				.tabItem {
					Label("Closed", systemImage: "checkmark")
				}
			AwardsView()
				.tag(AwardsView.tag)
				.tabItem {
					Label("Awards", systemImage: "rosette")
				}
			SharedProjectsView()
				.tag(SharedProjectsView.tag)
				.tabItem {
					Label("Community", systemImage: "person.3")
				}
		}
		.onContinueUserActivity(CSSearchableItemActionType, perform: moveToHome)
		.onContinueUserActivity(newProjectActivity, perform: createProject)
		.userActivity(newProjectActivity) { activity in
			activity.title = "New Project"
			activity.isEligibleForPrediction = true
		}
		.onOpenURL(perform: openURL)
	}
	func moveToHome(_ input: Any) {
		selectedView = HomeView.tag
	}
	func openURL(_ url: URL) {
		selectedView = ProjectsView.openTag
		dataController.addProject()
	}
	func createProject(_ userActivity: NSUserActivity) {
		selectedView = ProjectsView.openTag
		dataController.addProject()
	}
}

struct ContentView_Previews: PreviewProvider {
	static var dataController = DataController.preview
	static var previews: some View {
		ContentView()
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
	}
}
