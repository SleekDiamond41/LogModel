//
//  FrameworkLogger.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation
import Models
import Protocols


//@available(macOS 10.12, iOS 10, *)
//public struct Log {
//
//	let frameworkID: String
//	let category: String
//	let backer: Backer
//
//
//	init(system: String, category: String) {
//		self.frameworkID = system
//		self.category = category
//		preconditionFailure()
//	}
//
//	var `public`: PublicLogger {
//		PublicLogger(category: category, frameworkID: frameworkID, backer: backer)
//	}
//
//	var `internal`: InternalLogger {
//		InternalLogger(category: category, frameworkID: frameworkID, backer: backer)
//	}
//
//	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
//	public func verbose(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
//		let bundleID = "" //Config.common?.appID ?? frameworkID
//		let threadID = Thread.current.hashValue
//
//		backer.log(EntryData(date: Date(),
//							 severity: .verbose,
//							 message: message,
//							 category: category,
//							 appID: bundleID,
//							 threadID: threadID,
//							 filepath: file,
//							 function: function,
//							 line: line,
//							 frameworkID: frameworkID))
//	}
//}
