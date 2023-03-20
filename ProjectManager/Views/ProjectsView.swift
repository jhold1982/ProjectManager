//
//  ProjectsView.swift
//  UltimatePortfolio
//
//  Created by Justin Hold on 11/27/22.
//

import SwiftUI

struct ProjectsView: View {
	static let openTag: String? = "Open"
	static let closedTag: String? = "Closed"
	@StateObject var viewModel: ViewModel
	@State private var showingSortOrder = false
	// MARK: PROJECTS LIST FOR GROUP IF ELSE VIEW
	var projectsList: some View {
		List {
			ForEach(viewModel.projects) { project in
				Section(header: ProjectHeaderView(project: project)) {
					ForEach(project.projectItems(using: viewModel.sortOrder)) { item in
						ItemRowView(project: project, item: item)
					}
					.onDelete { offsets in
						viewModel.delete(offsets, from: project)
					}
					if viewModel.showClosedProjects == false {
						Button {
							withAnimation {
								viewModel.addItem(to: project)
							}
						} label: {
							Label("Add New Item", systemImage: "plus")
						}
					}
				}
			}
		}
		.listStyle(InsetGroupedListStyle())
	}
	// MARK: ADD PROJECT BUTTON
	var addProjectToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarTrailing) {
			if viewModel.showClosedProjects == false {
				Button {
					withAnimation {
						viewModel.addProject()
					}
				} label: {
					// In iOS 14.3 VoiceOver has a glitch that reads the label
					// "Add Project" as "Add" no matter what accessibility label
					// we give this button when using a label. As a result, when
					// VoiceOver is running we use a text view for the button instead,
					// forcing a correct reading without losing the original layout.
					if UIAccessibility.isVoiceOverRunning {
						Text("Add Project")
					} else {
						Label("Add Project", systemImage: "plus")
					}
				}
			}
		}
	}
	// MARK: SORT ORDER BUTTON
	var sortOrderToolbarItem: some ToolbarContent {
		ToolbarItem(placement: .navigationBarLeading) {
			Button {
				showingSortOrder.toggle()
			} label: {
				Label("Sort", systemImage: "arrow.up.arrow.down")
			}
		}
	}
	var body: some View {
		NavigationView {
			Group {
				if viewModel.projects.isEmpty {
					Text("Move along, nothing to see here.")
						.foregroundColor(.secondary)
				} else {
					projectsList
				}
			}
			.navigationTitle(viewModel.showClosedProjects ? "Closed Projects" : "Open Projects")
			.toolbar {
				addProjectToolbarItem
				sortOrderToolbarItem
			}
			// MARK: ACTION SHEET FOR SORT ORDER
			.actionSheet(isPresented: $showingSortOrder) {
				ActionSheet(title: Text("Sort Items"), message: nil, buttons: [
					.default(Text("Optimized")) { viewModel.sortOrder = .optimized },
					.default(Text("Creation Date")) { viewModel.sortOrder = .creationDate },
					.default(Text("Title")) { viewModel.sortOrder = .title }
				])
			}
			SelectSomethingView()
		}
		.sheet(isPresented: $viewModel.showingUnlockView) {
			UnlockView()
		}
	}
	init(dataController: DataController, showClosedProjects: Bool) {
		let viewModel = ViewModel(dataController: dataController, showClosedProjects: showClosedProjects)
		_viewModel = StateObject(wrappedValue: viewModel)
	}
}
struct ProjectsView_Previews: PreviewProvider {
    static var previews: some View {
		ProjectsView(dataController: DataController.preview, showClosedProjects: false)
    }
}
