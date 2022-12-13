//
//  EditProjectView.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/30/22.
//

import SwiftUI

struct EditProjectView: View {
	let project: Project
	@EnvironmentObject var dataController: DataController
	@Environment(\.presentationMode) var presentationMode
	@State private var title: String
	@State private var detail: String
	@State private var color: String
	@State private var showingDeleteConfirm = false
	let colorColumns = [
		GridItem(.adaptive(minimum: 44))
	]
	init(project: Project) {
		self.project = project
		_title = State(wrappedValue: project.projectTitle)
		_detail = State(wrappedValue: project.projectDetail)
		_color = State(wrappedValue: project.projectColor)
	}
    var body: some View {
		Form {
			Section("Basic Settings") {
				TextField("Project Name", text: $title.onChange(update))
				TextField("Project Description", text: $detail.onChange(update))
			}
			Section("Custom Project Color") {
				LazyVGrid(columns: colorColumns) {
					ForEach(Project.colors, id: \.self, content: colorButton)
				}
				.padding(.vertical)
			}
			Section(footer: Text("Closing a project moves it from open to closed status; Deleting it removes it entirely.")) {
				Button(project.closed ? "Reopen Project" : "Close Project") {
					project.closed.toggle()
					update()
				}
				Button("Delete Project") {
					showingDeleteConfirm.toggle()
				}
				.accentColor(.red)
			}
		}
		.navigationTitle("Edit Project")
		.onDisappear(perform: dataController.save)
		.alert(isPresented: $showingDeleteConfirm) {
			Alert(
				title: Text("Delete Project?"),
				message: Text("Are you sure you want to delete? This will delete all items in project."),
				primaryButton: .default(Text("Delete"), action: delete),
				secondaryButton: .cancel()
			)
		}
    }
	// MARK: FUNCTIONS
	func update() {
		project.title = title
		project.detail = detail
		project.color = color
	}
	func delete() {
		dataController.delete(project)
		presentationMode.wrappedValue.dismiss()
	}
	func colorButton(for item: String) -> some View {
		ZStack {
			Color(item)
				.aspectRatio(1, contentMode: .fit)
				.cornerRadius(6)
			if item == color {
				Image(systemName: "checkmark.circle")
					.foregroundColor(.white)
					.font(.largeTitle)
			}
		}
		.onTapGesture {
			color = item
			update()
		}
		.accessibilityElement(children: .ignore)
		.accessibilityAddTraits(
			item == color
				? [.isButton, .isSelected]
				: .isButton
		)
		.accessibilityLabel(LocalizedStringKey(item))
	}
}

struct EditProjectView_Previews: PreviewProvider {
	static var dataController = DataController.preview
    static var previews: some View {
		EditProjectView(project: Project.example)
			.environment(\.managedObjectContext, dataController.container.viewContext)
			.environmentObject(dataController)
    }
}
