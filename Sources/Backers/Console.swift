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
	
	let id = UUID()
	let formatter: DateFormatter
	let queue: DispatchQueue
	
	public init() {
		formatter = DateFormatter()
		formatter.dateFormat = "MM-dd-yyyy hh:mm:ss.SSS"
		
		self.queue = DispatchQueue(label: "com.duct-ape-productions.LogModel.Backers.Console.\(id)", qos: .userInitiated, target: .global(qos: .userInitiated))
	}
	
	func formattedString(for entry: Entry) -> String {
		let dateString = formatter.string(from: entry.date)
		
		return """
		\(dateString)
		\(entry.file)
		\(entry.category)
		\(entry.severity)
		\(entry.message)
		
		"""
	}
	
	public func log(_ data: EntryData) {
		queue.async {
			let entry = data.makeEntry()
			let message = self.formattedString(for: entry)
			
			print(message)
		}
	}
}
