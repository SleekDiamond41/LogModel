//
//  SyncData+Statement.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//


extension SyncData {
	
	func bind(_ statement: Statement) {
		statement.bind(id, at: 1)
		statement.bind(date, at: 2)
	}
	
	init(from statement: Statement) {
		self.init(id: statement.unbind(at: 1),
				  date: statement.unbind(at: 2))
	}
	
	
	static func createTable(in db: OpaquePointer) {
		let query = """
		CREATE TABLE IF NOT EXISTS synced_data (
			id INTEGER PRIMARY KEY NOT NULL,
			date text
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
		DROP TABLE IF EXISTS synced_data;
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
