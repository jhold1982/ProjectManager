//
//  SignInView.swift
//  ProjectManager
//
//  Created by Justin Hold on 1/19/23.
//

import AuthenticationServices
import SwiftUI

struct SignInView: View {
	enum SignInStatus {
		case unknown
		case authorized
		case failure(Error?)
	}
	@State private var status = SignInStatus.unknown
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.colorScheme) var colorScheme
    var body: some View {
		NavigationStack {
			Group {
				switch status {
				case .unknown:
					VStack(alignment: .leading) {
						ScrollView {
							Spacer()
							Spacer()
							Text("""
	In order to keep our community safe,
	we ask that you sign in before
	commenting on a project.

	We don't track your personal info;
	your name is used for display
	purposes only.

	Please note: we reserve the right to
	remove messages that are
	inappropriate or offensive.
""")
						}
						Spacer()
						SignInWithAppleButton(onRequest: configureSignIn, onCompletion: completeSignIn)
							.signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
							.frame(height: 44)
							.clipShape(Capsule())
							.padding(.horizontal, 80)
						Button("Cancel", action: closeWindow)
							.frame(maxWidth: .infinity)
							.padding()
							.foregroundColor(.red)
					}
				case .authorized:
					Text("You're all set!")
				case .failure(let error):
					if let error = error {
						Text("Sorry, there was an error: \(error.localizedDescription)")
					} else {
						Text("Sorry, there was an error.")
					}
				}
			}
		}
    }
	func configureSignIn(_ request: ASAuthorizationAppleIDRequest) {
		request.requestedScopes = [.fullName]
	}
	func completeSignIn(_ result: Result<ASAuthorization, Error>) {
		switch result {
		case .success(let auth):
			if let appleID = auth.credential as? ASAuthorizationAppleIDCredential {
				if let fullName = appleID.fullName {
					let formatter = PersonNameComponentsFormatter()
					var username = formatter.string(from: fullName).trimmingCharacters(in: .whitespacesAndNewlines)
					if username.isEmpty {
						// refuse to allow empty string
						username = "User-\(Int.random(in: 1001...9999))"
					}
					UserDefaults.standard.set(username, forKey: "username")
					NSUbiquitousKeyValueStore.default.set(username, forKey: "username")
					status = .authorized
					closeWindow()
					return
				}
			}
		case .failure(let error):
			if let error = error as? ASAuthorizationError {
				if error.errorCode == ASAuthorizationError.canceled.rawValue {
					status = .unknown
					return
				}
			}
			status = .failure(nil)
		}
	}
	func closeWindow() {
		presentationMode.wrappedValue.dismiss()
	}
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
