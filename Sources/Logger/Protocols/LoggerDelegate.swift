//
//  LoggerDelegate.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import Foundation

protocol LoggerDelegate {
	func log(_ entry: Entry)
}

protocol Writer {
	func write(_ entries: [Entry])
}

class StandardLoggerDelegate: LoggerDelegate {
	
	var entries = [Entry]()
	let maxEntries = 1000
	
	func log(_ entry: Entry) {
		
	}
}
