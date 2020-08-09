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
		statement.bind(bundleID, at: 4)
		statement.bind(userID?.uuidString ?? "", at: 5)
		statement.bind(deviceID?.uuidString ?? "", at: 6)
		statement.bind(customData ?? "", at: 7)
	}
	
	init(_ statement: Statement) {
		self.init(id: statement.unbind(at: 0),
				  date: statement.unbind(at: 1),
				  severity: statement.unbind(at: 2),
				  message: statement.unbind(at: 3),
				  customData: statement.unbind(at: 4),
				  bundleID: statement.unbind(at: 5),
				  userID: UUID(uuidString: statement.unbind(at: 6)),
				  deviceID: UUID(uuidString: statement.unbind(at: 7)))
	}
	
	static func createTable(in db: OpaquePointer) {
		let query = """
		CREATE TABLE IF NOT EXISTS entries (
			id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
			date timestamp(128) NOT NULL,
			severity int(8) NOT NULL,
			message text NOT NULL,
			custom_data text NOT NULL,
			bundle_id text NOT NULL,
			user_id char NOT NULL,
			device_id char NOT NULL
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
