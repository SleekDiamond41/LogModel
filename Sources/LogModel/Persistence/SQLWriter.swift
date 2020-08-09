//
//  SQLWriter.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import Foundation
import SQLite3


final class SQLWriter: SQLConnection, Writer {
	private var statement: Statement!
	
	override init(dir: URL, name: String) {
		super.init(dir: dir, name: name)
	}
	
	override func connect() {
		super.connect()
		
		assert(statement == nil)
		
		Entry.createTable(in: connection)
		
		let query = """
		INSERT INTO entries (date, severity, message, bundle_id, user_id, device_id, custom_data)
		VALUES (?, ?, ?, ?, ?, ?, ?);
		"""
		
		statement = Statement(in: connection, query: query)
	}
	
	override func disconnect() {
		statement.finalize()
		statement = nil
		super.disconnect()
	}
}

// MARK: - Writer Conformance
extension SQLWriter {
	
	func write(_ entry: Entry) {
		
		defer {
			statement.reset()
		}
		
		entry.bind(statement)
		
		let status = statement.step()
		
		guard status == SQLITE_DONE else {
			preconditionFailure()
		}
	}
	
	
	func setMostRecentlySyncedID(_ data: SyncData) {
		
		// set the value
		let query = """
		INSERT INTO synced_data (id, date)
		VALUES (?, ?);
		"""
		
		let statement = Statement(in: connection, query: query)
		
		defer { statement.finalize() }
		
		data.bind(statement)
		
		let status = statement.step()
		
		guard status == SQLITE_OK else {
			preconditionFailure()
		}
	}
	
	func getMostRecentlySync() -> SyncData? {
		
		let query = """
		SELECT (MAX(id), date)
		FROM synced_data;
		"""
		
		let statement = Statement(in: connection, query: query)
		
		defer { statement.finalize() }
		
		let status = statement.step()
		
		guard status == SQLITE_OK else {
			preconditionFailure()
		}
		
		return .init(from: statement)
	}
}
