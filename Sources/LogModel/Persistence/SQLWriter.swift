//
//  SQLWriter.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//


final class SQLWriter: SQLConnection {
	private var statement: Statement!
	
	override func connect() {
		super.connect()
		
		Entry.createTable(in: connection)
		SyncData.createTable(in: connection)
		
		let query = """
		INSERT INTO entries (date, severity, message, file, function, line, bundle_id, user_id, device_id, custom_data)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
		"""
		
		statement = Statement(in: connection, query: query)
	}
	
	override func disconnect() {
		
		statement?.finalize()
		statement = nil
		
		super.disconnect()
	}
}


extension SQLWriter {
	
	func write(_ entry: Entry) {
		
		defer {
			statement.reset()
		}
		
		entry.bind(statement)
		
		let status = statement.step()
		
		guard status == .done else {
			preconditionFailure()
		}
	}
	
	
	func setMostRecentlySyncedID(_ data: SyncData) {
		
		let query = """
		INSERT INTO synced_data (id, date)
		VALUES (?, ?);
		"""
		
		let statement = Statement(in: connection, query: query)
		
		defer { statement.finalize() }
		
		data.bind(statement)
		
		let status = statement.step()
		
		guard status == .ok else {
			preconditionFailure()
		}
	}
	
	func getMostRecentlySync() -> SyncData? {
		
		let query = """
		SELECT *
		FROM synced_data;
		"""
		
		let statement = Statement(in: connection, query: query)
		
		defer { statement.finalize() }
		
		let status = statement.step()
		
		guard status == .row else {
			return nil
		}
		
		return .init(from: statement)
	}
}
