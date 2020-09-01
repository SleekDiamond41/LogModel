//
//  InternalLogger.swift
//  
//
//  Created by Michael Arrington on 8/31/20.
//

import Foundation
import Models
import Protocols


//@available(OSX 10.12, iOS 10.0, *)
//public struct FrameworkLog {
//	let bundleID: String
//	let category: Log.Category
//	let publicBacker: Backer
//	let privateBacker: Backer
//
//	var `public`: PublicLogger {
//
//	}
//}

@available(OSX 10.12, iOS 10.0, *)
struct PublicLogger {
	let bundleID: String
	let category: Log.Category
	let backer: Backer
}


@available(OSX 10.12, iOS 10.0, *)
class PublicBacker: Backer {
	
	let privateBacker: Backer
	
	init(privateBacker: Backer) {
		self.privateBacker = privateBacker
	}
	
	func log(_ data: EntryData) {
		// send to the common thing
		Log.shared?[Log.Category(data.category)].backer.log(data)
		
		// send to the private thing
		privateBacker.log(data)
	}
}

@available(OSX 10.12, iOS 10.0, *)
struct InternalLogger {
	let category: String
	let frameworkID: String
	let backer: Backer
}

@available(OSX 10.12, iOS 10.0, *)
extension InternalLogger {
	
	func category(_ category: String) -> InternalLogger {
		return InternalLogger(category: category, frameworkID: frameworkID, backer: backer)
	}
	
	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
	public func verbose(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		let bundleID = Log.shared?.bundleID
		let threadID = Thread.current.hashValue
		
		backer.log(EntryData(date: Date(),
							 severity: .verbose,
							 message: message,
							 category: category,
							 appID: bundleID ?? "",
							 threadID: threadID,
							 filepath: file,
							 function: function,
							 line: line,
							 frameworkID: frameworkID))
	}
}
