//
//  Save.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import struct Foundation.UUID
import struct Models.EntryData

final class Save: Hashable {
	let id = UUID()
	let entries: [EntryData]
	
	init(_ entries: [EntryData]) {
		self.entries = entries
	}
}


// MARK: - Equatable Conformance
extension Save {
	
	@inlinable
	static func ==(left: Save, right: Save) -> Bool {
		return left.id == right.id
	}
}


// MARK: - Hashable Conformance
extension Save {
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}
