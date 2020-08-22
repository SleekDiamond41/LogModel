//
//  FileSyncList.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation
import OSLog

@available(OSX 10.12, iOS 10.0, *)
class FileSyncList {
	
	var count: Int {
		return models.count
	}
	
	let maxBatchSize = 5
	
	private let file: URL
	private let logger = OSLog(subsystem: "com.duct-ape-productions.LogModel", category: "FileSyncList")
	
	private var models = [Model]()
	
	
	private struct Model: Codable {
		let url: URL
	}
	
	init(file: URL) {
		self.file = file
		
		reload()
	}
	
	private func save() {
		let encoder = JSONEncoder()
		
		do {
			let data = try encoder.encode(models)
			
			do {
				try data.write(to: file, options: .atomicWrite)
			} catch {
				os_log("failed to write Data to URL '%s' with error '%s'",
					   log: logger,
					   type: .error,
					   file.absoluteString, error.localizedDescription)
			}
		} catch {
			
			os_log("failed to encode '%s' to Data with error '%s'",
				   log: logger,
				   type: .fault,
				   models.description, error.localizedDescription)
		}
	}
	
	private func reload() {
		
		do {
			let data = try Data(contentsOf: file)
			
			do {
				let decoder = JSONDecoder()
				models = try decoder.decode([Model].self, from: data)
			} catch {
				let dataString = String(data: data, encoding: .utf8) ?? ""
				
				os_log("failed to decode data '%s' to [Model] with error '%s'",
					   log: logger,
					   type: .fault,
					   dataString, error.localizedDescription)
			}
		} catch let error as NSError {
			models = []
			
			if error.code == NSFileReadNoSuchFileError {
				// nothing wrong here, the file just doesn't exist yet
				return
			}
			
			os_log("failed to get data from URL '%s' with error '%s'",
				   log: logger,
				   type: .error,
				   file.absoluteString, error.localizedDescription)
		}
	}
	
	func add(_ file: URL) {
		
		models.append(Model(url: file))
		save()
	}
	
	func next() -> [URL] {
		return models
			.prefix(maxBatchSize)
			.map { $0.url }
	}
	
	func remove(_ file: URL) {
		do {
			try FileManager.local.removeItem(at: file)
		} catch {
			os_log("failed to remove file at URL '%s' with error '%s'",
				   log: logger,
				   type: .error,
				   file.absoluteString, error.localizedDescription)
		}
		
		models.removeAll { $0.url == file }
		save()
	}
}
