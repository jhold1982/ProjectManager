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
							.frame(height: 44)
							.clipShape(Capsule())
							.padding(.horizontal, 80)
						Button("Cancel", action: {})
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
	}
	func completeSignIn(_ result: Result<ASAuthorization, Error>) {
	}
}

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
    }
}
