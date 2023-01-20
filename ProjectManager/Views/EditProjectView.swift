//
//  EditProjectView.swift
//  ProjectManager
//
//  Created by Justin Hold on 11/30/22.
//

import CloudKit
import CoreHaptics
import SwiftUI

struct EditProjectView: View {
	// Changed "let" to "@ObservableObject var" to check close/reopen bug
	let project: Project
//	@ObservedObject var project: Project
	@EnvironmentObject var dataController: DataController
	@Environment(\.presentationMode) var presentationMode
	@State private var title: String
	@State private var detail: String
	@State private var color: String
	@State private var showingDeleteConfirm = false
	@State private var engine = try? CHHapticEngine()
	@State private var remindMe: Bool
	@State private var reminderTime: Date
	@State private var showingNotificationsError = false
	@AppStorage("username") var username: String?
	@State private var showingSignIn = false
	let colorColumns = [
		GridItem(.adaptive(minimum: 44))
	]
	init(project: Project) {
		self.project = project
		_title = State(wrappedValue: project.projectTitle)
		_detail = State(wrappedValue: project.projectDetail)
		_color = State(wrappedValue: project.projectColor)
		if let projectReminderTime = project.reminderTime {
			_reminderTime = State(wrappedValue: projectReminderTime)
			_remindMe = State(wrappedValue: true)
		} else {
			_reminderTime = State(wrappedValue: Date())
			_remindMe = State(wrappedValue: false)
		}
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
			Section("Project Reminders") {
				Toggle("Show Reminders", isOn: $remindMe.animation().onChange(update))
					.alert(isPresented: $showingNotificationsError) {
						Alert(
							title: Text("Oops!"),
							message: Text("There was a problem."),
							primaryButton: .default(Text("Check settings"),
							action: showAppSettings),
							secondaryButton: .cancel()
						)
					}
				if remindMe {
					DatePicker(
						"Reminder Time",
						selection: $reminderTime.onChange(update),
						displayedComponents: .hourAndMinute
					)
				}
			}
			Section(footer: Text("Closing a project moves it from open to closed status; Deleting it removes it entirely.")) {
				Button(project.closed ? "Reopen Project" : "Close Project", action: toggleClosed)
				Button("Delete Project") {
					showingDeleteConfirm.toggle()
				}
				.accentColor(.red)
			}
		}
		.navigationTitle("Edit Project")
		.toolbar {
			Button(action: uploadToCloud) {
				Label("Upload to iCloud", systemImage: "icloud.and.arrow.up")
			}
		}
		.onDisappear(perform: dataController.save)
		.alert(isPresented: $showingDeleteConfirm) {
			Alert(
				title: Text("Delete Project?"),
				message: Text("Are you sure you want to delete? This will delete all items in project."),
				primaryButton: .default(Text("Delete"), action: delete),
				secondaryButton: .cancel()
			)
		}
		.sheet(isPresented: $showingSignIn, content: SignInView.init)
    }
	func update() {
		project.title = title
		project.detail = detail
		project.color = color
		if remindMe {
			project.reminderTime = reminderTime
			dataController.addReminders(for: project) { success in
				if success == false {
					project.reminderTime = nil
					remindMe = false
					showingNotificationsError = true
				}
			}
		} else {
			project.reminderTime = nil
			dataController.removeReminders(for: project)
		}
	}
	func delete() {
		dataController.delete(project)
		presentationMode.wrappedValue.dismiss()
	}
	func toggleClosed() {
		project.closed.toggle()
			if project.closed {
//				basicHaptic()
				customHaptic()
			}
	}
	func basicHaptic() {
		UINotificationFeedbackGenerator().notificationOccurred(.success)
	}
	func customHaptic() {
		// add do block inside "if project.closed" closure in "func toggleClosed"
		do {
			try engine?.start()
			let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0)
			let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
			let start = CHHapticParameterCurve.ControlPoint(relativeTime: 0, value: 1)
			let end = CHHapticParameterCurve.ControlPoint(relativeTime: 1, value: 0)
			let parameter = CHHapticParameterCurve(
				parameterID: .hapticIntensityControl,
				controlPoints: [start, end],
				relativeTime: 0
			)
			let event1 = CHHapticEvent(
				eventType: .hapticTransient,
				parameters: [intensity, sharpness],
				relativeTime: 0
			)
			let event2 = CHHapticEvent(
				eventType: .hapticContinuous,
				parameters: [sharpness, intensity],
				relativeTime: 0.125,
				duration: 1
			)
			let pattern = try CHHapticPattern(
				events: [event1, event2],
				parameterCurves: [parameter]
			)
			let player = try engine?.makePlayer(with: pattern)
			try player?.start(atTime: 0)
		} catch {
			// haptics didn't work, that's okay
		}
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
	func showAppSettings() {
		guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
			return
		}
		if UIApplication.shared.canOpenURL(settingsURL) {
			UIApplication.shared.open(settingsURL)
		}
	}
	func uploadToCloud() {
		if let username = username {
			let records = project.prepareCloudRecords(owner: username)
			let operation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
			operation.savePolicy = .allKeys
			operation.modifyRecordsResultBlock = { result in
				switch result {
				case .success:
					print("Success!")
				case .failure:
					print("\(result)")
				}
			}
			CKContainer.default().publicCloudDatabase.add(operation)
		} else {
			showingSignIn = true
		}
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
