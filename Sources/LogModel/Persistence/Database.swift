//
//  Database.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import struct Foundation.Date
import struct Foundation.URL

class Database: LocalStorage {
	
	let dir: URL
	let name: String
	
	private var writer: SQLWriter!
	
	
	deinit {
		disconnect()
	}
	
	init(dir: URL, name: String) {
		self.dir = dir
		self.name = name
	}
	
	@discardableResult
	func connect() -> Database {
		if writer == nil {
			writer = SQLWriter(dir: dir, name: name + ".sqlite")
		}
		
		return self
	}
	
	func disconnect() {
		writer = nil
	}
}

// MARK: - LocalStorage Conformance
extension Database {
	
	func log(_ entry: Entry) {
		writer.write(entry)
	}
	
	func getSyncBatch(max: UInt32) -> [Entry] {
		let reader = SQLReader(dir: writer.dir, name: writer.name)
		let lastSync = writer.getMostRecentlySync()
		
		return reader.get(firstID: (lastSync?.id ?? 0) + 1, max: max)
	}
	
	func setLastSyncedID(_ id: Int64) {
		let data = SyncData(id: id, date: Date())
		writer.setMostRecentlySyncedID(data)
	}
}
