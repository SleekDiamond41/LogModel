//
//  SQLReader.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import struct Foundation.URL
import SQLite3

class SQLReader: SQLConnection, Reader {
	
	private var statement: OpaquePointer!
	
	
	override func connect() {
		super.connect()

		assert(statement == nil)

		prepareStatement()
	}
	
	override func disconnect() {
		finalize()

		super.disconnect()
	}
	
	private func prepareStatement() {
		assert(self.connection != nil)
		
		let status = sqlite3_prepare_v2(self.connection, Statement.select, -1, &statement, nil)
		
		if status != SQLITE_OK {
			print(status)
		}
	}
	
	private func finalize() {
		assert(statement != nil)
		
		sqlite3_finalize(statement)
	}
}

// MARK: - Reader Conformance
extension SQLReader {
	
	func get(firstID: Int64, max: UInt32) -> [Entry] {
		
		defer {
			sqlite3_reset(statement)
			sqlite3_clear_bindings(statement)
		}
		
//		Statement.bind(firstID, to: statement, at: 1)
//		Statement.bind(Int64(max), to: statement, at: 1)
		
		var status = sqlite3_step(statement)
		
		var results = [Entry]()
		
		while status == SQLITE_ROW {
			results.append(Statement.unbind(from: statement))
			
			status = sqlite3_step(statement)
		}
		
		return results
	}
}
