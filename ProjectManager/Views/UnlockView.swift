//
//  UnlockView.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/22/22.
//

import StoreKit
import SwiftUI

struct UnlockView: View {
	@Environment(\.presentationMode) var presentationMode
	@EnvironmentObject var unlockManager: UnlockManager
    var body: some View {
		VStack {
			switch unlockManager.requestState {
			case .loaded(let product):
				ProductView(product: product)
			case .failed:
				Text("Sorry, there was an error.")
			case .loading:
				ProgressView("Loading...")
			case .purchased:
				Text("Thank you!")
			case .deferred:
				Text("Thank you! Your request is pending approval. You can continue using the app in the meantime.")
			}
			Button("Dismiss", action: dismiss)
		}
		.padding()
		.onReceive(unlockManager.$requestState) { value in
			if case .purchased = value {
				dismiss()
			}
		}
    }
	func dismiss() {
		presentationMode.wrappedValue.dismiss()
	}
}
