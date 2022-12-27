//
//  AppDelegate.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/25/22.
//

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
	func application(
		_ application: UIApplication,
		configurationForConnecting connectingSceneSession: UISceneSession,
		options: UIScene.ConnectionOptions) -> UISceneConfiguration {
		let sceneConfiguration = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
		sceneConfiguration.delegateClass = SceneDelegate.self
		return sceneConfiguration
	}
}
