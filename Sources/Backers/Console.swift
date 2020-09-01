//
//  Console.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation
import Models
import Protocols


public class Console: Backer {
	
	public init() { }
	
	public func log(_ data: EntryData) {
		let formatter = DateFormatter()
		formatter.dateFormat = "MM-dd-yyyy hh:mm:ss.SSS"
		let dateString = formatter.string(from: data.date)
		
		print(dateString, data.appID, data.category, data.makeEntry().message)
	}
}
