//
//  SQLConversion.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import Foundation
import SQLite3


struct Statement {
	
	private let pointer: OpaquePointer
	let string: String
	
	
	// MARK: - Binding
	
	static func bind(_ value: Int64, to s: OpaquePointer, at index: Int32) {
		let status = sqlite3_bind_int64(s, index, value)
		
		guard status == SQLITE_OK else {
			fatalError(String(reflecting: status))
		}
	}
	
	private static func bind(_ text: String, to s: OpaquePointer, at index: Int32) {
		
		let status = sqlite3_bind_text(s, index, NSString(string: text).utf8String, -1, nil)
		
		guard status == SQLITE_OK else {
			preconditionFailure(String(reflecting: status))
		}
	}
	
	private static func bind(_ value: Date, to s: OpaquePointer, at index: Int32) {
		let str = dateFormatter.string(from: value)
		
		bind(str, to: s, at: index)
	}
	
	private static func bind(_ value: Severity, to s: OpaquePointer, at index: Int32) {
		let status = sqlite3_bind_int(s, index, Int32(value.rawValue))
		
		guard status == SQLITE_OK else {
			fatalError(String(reflecting: status))
		}
	}
	
	static func bind(_ entry: Entry, into s: OpaquePointer) {
		
		bind(entry.date, to: s, at: 1)
		bind(entry.severity, to: s, at: 2)
		bind(entry.message, to: s, at: 3)
		bind(entry.bundleID, to: s, at: 4)
		bind(entry.userID?.uuidString ?? "", to: s, at: 5)
		bind(entry.deviceID?.uuidString ?? "", to: s, at: 6)
		bind(entry.customData ?? "", to: s, at: 7)
	}
	
	
	// MARK: - Unbinding
	
	private static func unbind(from s: OpaquePointer, at index: Int32) -> String {
		
		guard let p = sqlite3_column_text(s, index) else {
			print(String(cString: sqlite3_errmsg(s)))
			assertionFailure()
			return ""
		}
		
		return String(cString: p)
	}
	
	private static func unbind(from s: OpaquePointer, at index: Int32) -> Date {
		let str = unbind(from: s, at: index) as String
		return dateFormatter.date(from: str)!
	}
	
	private static func unbind(from s: OpaquePointer, at index: Int32) -> Int64 {
		return sqlite3_column_int64(s, index)
	}
	
	private static func unbind(from s: OpaquePointer, at index: Int32) -> Severity {
		let value = UInt8(sqlite3_column_int(s, index))
		return Severity(rawValue: value)!
	}
	
	static func unbind(from s: OpaquePointer) -> Entry {
		
		return Entry(id: unbind(from: s, at: 0),
					 bundleID: unbind(from: s, at: 5),
					 userID: UUID(uuidString: unbind(from: s, at: 6)),
					 deviceID: UUID(uuidString: unbind(from: s, at: 7)),
					 date: unbind(from: s, at: 1),
					 severity: unbind(from: s, at: 2),
					 message: unbind(from: s, at: 3),
					 customData: unbind(from: s, at: 4))
	}
	
	static let dateFormatter: DateFormatter = {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"
			formatter.timeZone = TimeZone(abbreviation: "UTC")
			return formatter
		}()
	
	// MARK: - Constants
	
	static let select = """
	SELECT * FROM entries
	"""
	
	static let insert = """
	INSERT INTO entries (date, severity, message, bundle_id, user_id, device_id, custom_data)
	VALUES (?, ?, ?, ?, ?, ?, ?);
	"""
//		INSERT INTO entries (date, severity, message, bundle_id, user_id, device_id, custom_data)
//		VALUES (SELECT strftime('\(dateTimeFormat)', "\(offset)", "unixepoch"), ?, ?, ?, ?, ?, ?);
	
	
	static let createTable = """
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
	
	static let dropTable = """
	DROP TABLE IF EXISTS entries;
	"""
}
