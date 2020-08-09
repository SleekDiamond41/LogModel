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
	
	var isConnected: Bool {
		return connection != nil
	}
	
	deinit {
		guard isConnected else {
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
	
	func connect() {
		assert(!isConnected)
		
		let fileURL = dir.appendingPathComponent(name)
		let status = Status(sqlite3_open(fileURL.path, &connection))
		
		guard status == .ok else {
			preconditionFailure()
		}
		guard isConnected else {
			preconditionFailure()
		}
	}
	
	func disconnect() {
		assert(isConnected)
		
		let status = Status(sqlite3_close(connection))
		
		guard status == .ok else {
			preconditionFailure()
		}
	}
	
	func getErrorMessage() -> String {
		return String(cString: sqlite3_errmsg(connection))
	}
}
