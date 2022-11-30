//
//  ContentView.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/27/22.
//

import SwiftUI

struct ContentView: View {
	
	@SceneStorage("selectedView") var selectedView: String? 
	
	var body: some View {
		TabView(selection: $selectedView) {
			HomeView()
				.tag(HomeView.tag)
				.tabItem {
					Image(systemName: "house")
					Text("Home")
				}
			ProjectsView(showClosedProjects: false)
				.tag(ProjectsView.openTag)
				.tabItem {
					Image(systemName: "list.bullet")
					Text("Open Projects")
				}
			ProjectsView(showClosedProjects: true)
				.tag(ProjectsView.closedTag)
				.tabItem {
					Image(systemName: "checkmark")
					Text("Closed Projects")
				}
		}
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
