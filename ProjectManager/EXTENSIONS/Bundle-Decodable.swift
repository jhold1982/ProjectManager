//
//  Bundle-Decodable.swift
//  ProjectManager
//
//  Created by Justin Hold on 12/2/22.
//

import Foundation

extension Bundle {
	func decode<T: Decodable>(
		_ type: T.Type,
		from file: String,
		dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
		keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
		guard let url = self.url(forResource: file, withExtension: nil) else {
			fatalError("Failed to locate \(file) in bundle.")
		}
		guard let data = try? Data(contentsOf: url) else {
			fatalError("failed to load \(file) from bundle.")
		}
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = dateDecodingStrategy
		decoder.keyDecodingStrategy = keyDecodingStrategy
		do {
			return try decoder.decode(T.self, from: data)
		} catch DecodingError.keyNotFound(let key, let context) {
			fatalError("Failed to decode \(file) from bundle: missing key' \(key.stringValue)' - \(context.debugDescription)")
		} catch DecodingError.typeMismatch(_, let context) {
			fatalError("Failed to decode \(file) from bundle: file mismatch - \(context.debugDescription)")
		} catch DecodingError.valueNotFound(let type, let context) {
			fatalError("Failed to decode \(file) from bundle due to missing \(type) value - \(context.debugDescription)")
		} catch DecodingError.dataCorrupted(_) {
			fatalError("Failed to decode \(file) from bundle due to invalid JSON")
		} catch {
			fatalError("Failed to decode \(file) from bundle: \(error.localizedDescription)")
		}
	}
}
