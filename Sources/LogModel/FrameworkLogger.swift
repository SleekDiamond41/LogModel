//
//  FrameworkLogger.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation


@available(OSX 10.12, iOS 10.0, *)
final class FrameworkLog: LogBacker {
	
	let common: LogBacker?
	
	init(bundleID: String, common: LogBacker?, serverURL: URL) {
		self.common = common
		
		super.init(bundleID: bundleID,
				   userID: common?.userID,
				   deviceID: common?.deviceID,
				   serverURL: serverURL)
	}
	
	override func log(_ severity: Severity, _ message: String, category: String, bundleID: String, customData: String?, file: String, function: String, line: UInt32) {
		
		// record for consumer of framework
		common?.log(severity,
					message,
					category: category,
					bundleID: bundleID,
					customData: customData,
					file: file,
					function: function,
					line: line)
		
		// record for creator of framework
		super.log(severity,
				  message,
				  category: category,
				  bundleID: bundleID,
				  customData: customData,
				  file: file,
				  function: function,
				  line: line)
	}
}
