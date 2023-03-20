//
//  Error-CloudKitMessages.swift
//  ProjectManager
//
//  Created by Justin Hold on 1/24/23.
//

import CloudKit
import Foundation

extension Error {
	func getCloudKitError() -> String {
		guard let error = self as? CKError else {
			return "An unknown error occurred: \(self.localizedDescription)"
		}
		switch error.code {
		case .badContainer, .badDatabase, .invalidArguments:
			return "A fatal error occurred: \(error.localizedDescription)"
		case .networkFailure, .networkUnavailable, .serverResponseLost, .serviceUnavailable:
			return "There was a problem communicating with iCloud; please check your network."
		case .notAuthenticated:
			return "There was a problem with your iCloud account; Please log in."
		case .requestRateLimited:
			return "You've hit iCloud's rate limit; please wait and try again."
		case .quotaExceeded:
			return "You've exceeded your iCloud quota; please clear some space and try again."
		default:
			return "An unknown error occurred: \(error.localizedDescription)"
		}
	}
}
