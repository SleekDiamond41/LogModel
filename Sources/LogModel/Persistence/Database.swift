//
//  Database.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import SQLite3
import Foundation

class Database: LocalStorage {
	
	private let writer: SQLWriter
	
	
	init(dir: URL, name: String) {
		self.writer = SQLWriter(dir: dir, name: name + ".sqlite")
	}
	
	func disconnect() {
		writer.disconnect()
	}
	
	func get(max: UInt32 = .max) -> [Entry] {
		let reader = SQLReader(dir: writer.dir, name: writer.name)
		
		return reader.get(firstID: 0, max: max)
	}
}

// MARK: - LocalStorage Conformance
extension Database {
	
	func record(_ entry: Entry) {
		writer.write(entry)
	}
}
