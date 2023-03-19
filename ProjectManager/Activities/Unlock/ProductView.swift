//
//  ProductView.swift
//  ProjectManager
//
//  Created by Justin Hold on 3/19/23.
//

import SwiftUI
import StoreKit

struct ProductView: View {
	@EnvironmentObject var unlockManager: UnlockManager
	let product: SKProduct
    var body: some View {
		ScrollView {
			VStack(spacing: 20) {
				Text("Get Unlimited Projects")
					.font(.headline)
					.padding(.top, 10)
				Text("You can add three projects for free, or pay \(product.localizedPrice) to add unlimited projects.")
				Text("If you already bought the unlock on another device, press Restore Purchases.")
				Button("Buy: \(product.localizedPrice)", action: unlock)
					.buttonStyle(PurchaseButton())
				Button("Restore Purchases", action: unlockManager.restore)
					.buttonStyle(PurchaseButton())
			}
		}
    }
	func unlock() {
		unlockManager.buy(product: product)
	}
}
