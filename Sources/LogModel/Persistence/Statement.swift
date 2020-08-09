//
//  SQLConversion.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import Foundation
import SQLite3

fileprivate protocol Bindable {
	init(_ : OpaquePointer, at: Int32)
	
	func bind(to s: OpaquePointer, at: Int32)
}

extension String: Bindable {
	func bind(to s: OpaquePointer, at index: Int32) {
		let status = sqlite3_bind_text(s, index, NSString(string: self).utf8String, -1, nil)
		
		guard status == SQLITE_OK else {
			preconditionFailure(String(reflecting: status))
		}
	}
	
	init(_ s: OpaquePointer, at index: Int32) {
		guard let p = sqlite3_column_text(s, index) else {
			assertionFailure()
			self = ""
			return
		}
		
		self.init(cString: p)
	}
}

extension Severity: Bindable {
	func bind(to s: OpaquePointer, at index: Int32) {
		let status = sqlite3_bind_int(s, index, Int32(rawValue))
		
		guard status == SQLITE_OK else {
			fatalError(String(reflecting: status))
		}
	}
	
	init(_ s: OpaquePointer, at index: Int32) {
		let value = UInt8(sqlite3_column_int(s, index))
		self = Severity(rawValue: value)!
	}
}

extension Int64: Bindable {
	func bind(to s: OpaquePointer, at index: Int32) {
		let status = sqlite3_bind_int64(s, index, self)
		
		guard status == SQLITE_OK else {
			fatalError(String(reflecting: status))
		}
	}
	
	init(_ s: OpaquePointer, at index: Int32) {
		self = sqlite3_column_int64(s, index)
	}
}

extension UInt32: Bindable {
	func bind(to s: OpaquePointer, at index: Int32) {
		Int64(self).bind(to: s, at: index)
	}
	
	init(_ s: OpaquePointer, at index: Int32) {
		self.init(Int64(s, at: index))
	}
}

extension Date: Bindable {
	
	private static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS Z"
		formatter.timeZone = TimeZone(abbreviation: "UTC")
		return formatter
	}()

	
	func bind(to s: OpaquePointer, at index: Int32) {
		let str = Date.dateFormatter.string(from: self)
		str.bind(to: s, at: index)
	}
	
	init(_ s: OpaquePointer, at index: Int32) {
		let str = String(s, at: index)
		self = Date.dateFormatter.date(from: str)!
	}
}


struct Statement {
	
	let pointer: OpaquePointer
	let query: String
	
	init(in db: OpaquePointer, query: String) {
		var p: OpaquePointer!
		
		let status = sqlite3_prepare_v2(db, query, -1, &p, nil)
		
		assert(status == SQLITE_OK)
		
		self.pointer = p
		self.query = query
	}
	
	func reset() {
		sqlite3_reset(pointer)
		sqlite3_clear_bindings(pointer)
	}
	
	func finalize() {
		sqlite3_finalize(pointer)
	}
	
	func step() -> Int32 {
		return sqlite3_step(pointer)
	}
	
	
	// MARK: - Binding
	
	func bind(_ value: String, at index: Int32) {
		value.bind(to: pointer, at: index)
	}
	
	func bind(_ value: Severity, at index: Int32) {
		value.bind(to: pointer, at: index)
	}
	
	func bind(_ value: Int64, at index: Int32) {
		value.bind(to: pointer, at: index)
	}
	
	func bind(_ value: Date, at index: Int32) {
		value.bind(to: pointer, at: index)
	}
	
	func bind(_ value: UInt32, at index: Int32) {
		value.bind(to: pointer, at: index)
	}
	
	
	// MARK: - Unbinding
	
	func unbind(at index: Int32) -> String {
		return .init(pointer, at: index)
	}
	
	func unbind(at index: Int32) -> Severity {
		return .init(pointer, at: index)
	}
	
	func unbind(at index: Int32) -> Int64 {
		return .init(pointer, at: index)
	}
	
	func unbind(at index: Int32) -> Date {
		return .init(pointer, at: index)
	}
	
	func unbind(at index: Int32) -> UInt32 {
		return .init(pointer, at: index)
	}
}
