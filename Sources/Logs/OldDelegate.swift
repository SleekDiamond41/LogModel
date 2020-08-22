//
//  OldImplementation.swift
//  
//
//  Created by Michael Arrington on 8/9/20.
//

import Foundation
import OSLog


@available(iOS 10.0, OSX 10.12, *)
struct OldDelegate: Delegate {
	
	let logger: OSLog
	
	@inlinable
	init(subsystem: String, category: String) {
		self.logger = OSLog(subsystem: subsystem, category: category)
	}
	
	
	@inlinable
	func level(for severity: Severity) -> OSLogType {
		switch severity {
		case .debug: return .debug
		case .info: return .info
		case .notice: return .default
		case .error: return .error
		case .fault: return .fault
		}
	}
	
	@inlinable
	func log(_ severity: Severity, _ message: StaticString) {
		os_log(message, log: logger, type: level(for: severity))
	}
}
