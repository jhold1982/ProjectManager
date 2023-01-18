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
	@State var progress: CGFloat = 0
	@State var doneLoading: Bool = false
	var body: some View {
		ZStack {
			if doneLoading {
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
			} else {
				LoadingView(content: Image("LaunchIcon")
								.resizable()
								.scaledToFit()
								.padding(.horizontal),
							progress: $progress)
				// Added to simulate asynchronous data loading
				.onAppear {
					DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
						withAnimation {
							self.progress = 0
						}
						DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
							withAnimation {
								self.doneLoading = true
							}
						}
					}
				}
			}
		}
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
struct ScaledMaskModifier<Mask: View>: ViewModifier {
	var mask: Mask
	var progress: CGFloat
	func body(content: Content) -> some View {
		content
			.mask(GeometryReader(content: { geometry in
				self.mask.frame(width: self.calculateSize(geometry: geometry) * self.progress,
								height: self.calculateSize(geometry: geometry) * self.progress,
								alignment: .center)
			}))
	}
	// Calculate max size of Mask
	func calculateSize(geometry: GeometryProxy) -> CGFloat {
		if geometry.size.width > geometry.size.height {
			return geometry.size.width
		}
		return geometry.size.height
	}
}
struct LoadingView<Content: View>: View {
	var content: Content
	@Binding var progress: CGFloat
	@State var logoOffset: CGFloat = 0
	var body: some View {
		content
			.modifier(ScaledMaskModifier(mask: Circle(), progress: progress))
			.offset(x: 0, y: logoOffset)
			.onAppear {
				withAnimation(Animation.easeInOut(duration: 1)) {
					self.progress = 1.0
				}
				withAnimation(Animation.easeInOut(duration: 0.4).repeatForever(autoreverses: true)) {
					self.logoOffset = 10
				}
			}
	}
}
