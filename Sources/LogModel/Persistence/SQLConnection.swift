//
//  File.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import Foundation
import SQLite3


class SQLConnection {
	let dir: URL
	let name: String
	
	private(set) var connection: OpaquePointer!
	
	deinit {
		guard connection != nil else {
			return
		}

		disconnect()
	}
	
	init(dir: URL, name: String) {
		self.dir = dir
		self.name = name
		
		prepareDirectory()
		connect()
	}
	
	private func prepareDirectory() {
		
		let manager = FileManager()
		
		let dirExists = manager.fileExists(atPath: dir.absoluteString)
		
		guard !dirExists else {
			return
		}
		
		try! manager.createDirectory(at: dir, withIntermediateDirectories: true)
	}
	
	private func prepareConnection() {
		assert(self.connection == nil)
		
		let fileURL = dir.appendingPathComponent(name)
		
		guard sqlite3_open(fileURL.path, &connection) == SQLITE_OK else {
			preconditionFailure()
		}
		
		guard connection != nil else {
			preconditionFailure()
		}
	}
	
	func connect() {
		assert(connection == nil)
		
		prepareConnection()
	}
	
	func disconnect() {
		assert(connection != nil)
		
		guard sqlite3_close(connection) == SQLITE_OK else {
			preconditionFailure()
		}
	}
	
	func getErrorMessage() -> String {
		return String(cString: sqlite3_errmsg(connection))
	}
}
