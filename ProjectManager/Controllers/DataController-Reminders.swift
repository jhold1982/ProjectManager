//
//  DataController-Reminders.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/27/22.
//

import Foundation
import UserNotifications

extension DataController {
	func addReminders(for project: Project, completion: @escaping (Bool) -> Void) {
		let center = UNUserNotificationCenter.current()
		center.getNotificationSettings { settings in
			switch settings.authorizationStatus {
			case .notDetermined:
				self.requestNotification { success in
					if success {
						self.placeReminders(for: project, completion: completion)
					} else {
						DispatchQueue.main.async {
							completion(false)
						}
					}
				}
			case .authorized:
				self.placeReminders(for: project, completion: completion)
			default:
				DispatchQueue.main.async {
					completion(false)
				}
			}
		}
	}
	func removeReminders(for project: Project) {
		let center = UNUserNotificationCenter.current()
		let id = project.objectID.uriRepresentation().absoluteString
		center.removePendingNotificationRequests(withIdentifiers: [id])
	}
	private func requestNotification(completion: @escaping (Bool) -> Void) {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
			completion(granted)
		}
	}
	private func placeReminders(for project: Project, completion: @escaping (Bool) -> Void) {
		let content = UNMutableNotificationContent()
		content.title = project.projectTitle
		content.sound = .default
		if let projectDetail = project.detail {
			content.subtitle = projectDetail
		}
		let components = Calendar.current.dateComponents(
			[.hour, .minute],
			from: project.reminderTime ?? Date()
		)
		let trigger = UNCalendarNotificationTrigger(
			dateMatching: components,
			repeats: true
		)
		let id = project.objectID.uriRepresentation().absoluteString
		let request = UNNotificationRequest(
			identifier: id,
			content: content,
			trigger: trigger
		)
		UNUserNotificationCenter.current().add(request) { error in
			DispatchQueue.main.async {
				if error == nil {
					completion(true)
				} else {
					completion(false)
				}
			}
		}
	}
}
