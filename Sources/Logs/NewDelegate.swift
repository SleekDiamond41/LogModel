//
//  NewImplementation.swift
//  
//
//  Created by Michael Arrington on 8/9/20.
//

import Foundation
import os


@available(iOS 14.0, OSX 11.0, *)
struct NewDelegate: Delegate {
	
	let logger: os.Logger
	
	@inlinable
	init(subsystem: String, category: String) {
		self.logger = os.Logger(subsystem: subsystem, category: category)
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
		logger.log(level: level(for: severity), "\(message)")
	}
}
