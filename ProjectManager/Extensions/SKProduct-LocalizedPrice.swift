//
//  SKProduct-LocalizedPrice.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/22/22.
//

import StoreKit

extension SKProduct {
	var localizedPrice: String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = priceLocale
		return formatter.string(from: price)!
	}
}
