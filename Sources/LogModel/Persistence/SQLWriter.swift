//
//  SQLWriter.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import Foundation
import SQLite3


class SQLWriter: SQLConnection, Writer {
	private var writeStatement: OpaquePointer!
	
	
	private func createTable() {
		
		var s: OpaquePointer!
		
		var status = sqlite3_prepare_v2(connection, Statement.createTable, -1, &s, nil)
		
		defer {
			sqlite3_finalize(s)
		}
		
		assert(status == SQLITE_OK)
		
		status = sqlite3_step(s)
		
		assert(status == SQLITE_DONE)
	}
		
	private func prepareStatement() {
		assert(self.connection != nil)
		
		let status = sqlite3_prepare_v2(self.connection, Statement.insert, -1, &writeStatement, nil)
		
		if status != SQLITE_OK {
			print(getErrorMessage())
		}
	}
	
	private func finalize() {
		assert(writeStatement != nil)
		
		let value = sqlite3_finalize(writeStatement)
		
		guard value == SQLITE_OK else {
			preconditionFailure()
		}
	}
	
	override func connect() {
		super.connect()
		
		assert(writeStatement == nil)
		
		createTable()
		prepareStatement()
	}
	
	override func disconnect() {
		finalize()

		super.disconnect()
	}
}

// MARK: - Writer Conformance
extension SQLWriter {
	
	func write(_ entry: Entry) {
		
		defer {
			sqlite3_reset(writeStatement)
			sqlite3_clear_bindings(writeStatement)
		}
		
		Statement.bind(entry, into: writeStatement)
		
		let status = sqlite3_step(writeStatement)
		
		guard status == SQLITE_DONE else {
			preconditionFailure()
		}
	}
}
