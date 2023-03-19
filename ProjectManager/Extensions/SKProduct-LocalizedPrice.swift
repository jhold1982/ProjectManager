//
//  SKProduct-LocalizedPrice.swift
//  ProjectManager
//
//  Created by Justin Hold on 3/19/23.
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
