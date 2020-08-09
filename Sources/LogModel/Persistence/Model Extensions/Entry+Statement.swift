//
//  Entry+Statement.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import struct Foundation.UUID


extension Entry {
	
	func bind(_ statement: Statement) {
		statement.bind(date, at: 1)
		statement.bind(severity, at: 2)
		statement.bind(message, at: 3)
		statement.bind(file, at: 4)
		statement.bind(function, at: 5)
		statement.bind(line, at: 6)
		statement.bind(bundleID, at: 7)
		statement.bind(userID?.uuidString ?? "", at: 8)
		statement.bind(deviceID?.uuidString ?? "", at: 9)
		statement.bind(customData ?? "", at: 10)
	}
	
	init(_ statement: Statement) {
		self.init(id: statement.unbind(at: 0),
				  date: statement.unbind(at: 1),
				  severity: statement.unbind(at: 2),
				  message: statement.unbind(at: 3),
				  file: statement.unbind(at: 4),
				  function: statement.unbind(at: 5),
				  line: statement.unbind(at: 6),
				  customData: statement.unbind(at: 7),
				  bundleID: statement.unbind(at: 8),
				  userID: UUID(uuidString: statement.unbind(at: 9)),
				  deviceID: UUID(uuidString: statement.unbind(at: 10)))
	}
	
	static func createTable(in db: OpaquePointer) {
		let query = """
		CREATE TABLE IF NOT EXISTS entries (
			id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			date TIMESTAMP(128) NOT NULL,
			severity INTEGER(8) NOT NULL,
			message TEXT NOT NULL,
			file TEXT NOT NULL,
			function TEXT NOT NULL,
			line INTEGER NOT NULL,
			custom_data TEXT NOT NULL,
			bundle_id TEXT NOT NULL,
			user_id TEXT NOT NULL,
			device_id TEXT NOT NULL
		);
		"""
		
		let statement = Statement(in: db, query: query)
		
		defer {
			statement.finalize()
		}
		
		let status = statement.step()
		
		guard status == .done else {
			return
		}
	}
	
	static func dropTable(in db: OpaquePointer) {
		let query = """
		DROP TABLE IF EXISTS entries;
		"""
		
		let statement = Statement(in: db, query: query)
		
		defer {
			statement.finalize()
		}
		
		let status = statement.step()
		
		guard status == .done else {
			return
		}
	}
}
