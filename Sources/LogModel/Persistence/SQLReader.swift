//
//  SQLReader.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import struct Foundation.URL
import SQLite3


final class SQLReader: SQLConnection, Reader {
	
}

// MARK: - Reader Conformance
extension SQLReader {
	
	func get(firstID: Int64, max: UInt32) -> [Entry] {
		
		var results = [Entry]()
		
		let query = """
		SELECT *
		FROM entries
		WHERE id >= ?
		LIMIT ?;
		"""
		
		let statement = Statement(in: connection, query: query)
		
		defer {
			statement.finalize()
		}
		
		statement.bind(firstID, at: 1)
		statement.bind(max, at: 2)
		
		var status = statement.step()
		
		while status == SQLITE_ROW {
			results.append(.init(statement))
			
			status = statement.step()
		}
		
		return results
	}
}
