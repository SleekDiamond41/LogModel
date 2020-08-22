//
//  Logger.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import Foundation

protocol Sender {
	func send(_ file: URL)
}


public struct Logger {
	
	let delegate: LoggerDelegate
	
	func log(_ message: String, file: String = #file, line: UInt32 = #line) {
		
	}
}
