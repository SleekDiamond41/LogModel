//
//  FrameworkLogger.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation
//import LogModel
import Models

//@available(macOS 10.12, iOS 10, *)
//typealias AppLog = LogModel.Log


@available(macOS 10.12, iOS 10, *)
public struct Log {
	
	let frameworkID: String
	let category: String
	
	
	init(system: String, category: String) {
		self.frameworkID = system
		self.category = category
	}
	
	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
	public func verbose(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
//		let bundleID = frameworkID
//		let bundleID = Config.common?.appID ?? frameworkID
		
		
//		log(.verbose,
//			message,
//			category: category,
//			bundleID: bundleID,
//			customData: customData,
//			file: file,
//			function: function,
//			line: line)
	}
}
