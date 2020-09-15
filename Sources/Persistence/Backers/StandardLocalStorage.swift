//
//  StandardLocalStorage.swift
//  
//
//  Created by Michael Arrington on 8/17/20.
//

import Foundation
import Protocols
import Models

@available(OSX 10.12, iOS 10.0, *)
public final class StandardLocalStorage: Backer {
	
	let file: FileDelegate
	let highPriorityFile: FileDelegate
	let maxBufferSize: UInt32
	let queue: DispatchQueue
	
	private var buffer = [EntryData]()
	
	private var pendingSaves = Set<Save>()
	
	
	init(_ file: FileDelegate, highPriorityFile: FileDelegate, maxBufferSize: UInt32) {
		self.file = file
		self.highPriorityFile = highPriorityFile
		self.maxBufferSize = maxBufferSize
		
		// Background queue because logging isn't an immediate concern, so long as it gets done.
		// Target global(.background) to take advantage of existing threads
		// instead of creating a new one for this queue.
		self.queue = DispatchQueue(label: "com.duct-ape-productions.SwiftLog.StandardLocalStorage.BackgroundUpdateQueue", qos: .background, target: .global(qos: .background))
		
		// make sure buffer is initialized with the property capacity
		clearBuffer()
	}
	
	public convenience init(forSyncingTo server: Server, maxBufferSize: UInt32) {
		let directory = FileManager.default
			.urls(for: .applicationSupportDirectory, in: .userDomainMask)
			.first!
			.appendingPathComponent(StandardLocalStorage.getUniqueDirectoryName())
//			.appendingPathComponent("com.duct-ape-productions.SwiftLog")
			.appendingPathComponent("Logs")
		
		self.init(server: server, directory: directory, maxBufferSize: maxBufferSize)
	}
	
	convenience init(server: Server, directory: URL, maxBufferSize: UInt32) {
		
		let metadataDir = directory.appendingPathComponent("Meta-Data")
		let lowPriority = directory.appendingPathComponent("Standard")
		let highPriority = directory.appendingPathComponent("HighPriority")
		
		do {
			for dir in [metadataDir, lowPriority, highPriority] {
				try FileManager.local.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
			}
		} catch {
			preconditionFailure(error.localizedDescription)
		}
		
		let syncList = FileSyncList(file: metadataDir.appendingPathComponent("pendingSyncs").appendingPathExtension("json"))
		let cleaner = FileSynchronizer(syncList: syncList, server: server)
		
		let standardFileProvider = IntegerFilenameProviding(dir: directory.appendingPathComponent("Standard"), manager: .local, cleaner: cleaner)
		let highPriorityFileProvider = IntegerFilenameProviding(dir: directory.appendingPathComponent("HighPriority"), manager: .local, cleaner: cleaner)
		let standardFile = MyFileDelegate(filename: standardFileProvider)
		let highPriorityFile = MyFileDelegate(filename: highPriorityFileProvider)
		
		self.init(standardFile, highPriorityFile: highPriorityFile, maxBufferSize: maxBufferSize)
	}
	
	
	/// A randomly selected, consistent name for storing the name
	/// of the unique directory for the current application
	static let uniqueDirectoryNameKey = "e4baecb4-e975-11ea-adc1-0242ac120002"
	
	
	/// The Application Support directory in Macs is sharerd between applications, so just using that would
	/// cause conflicts as applications A and B would log data to the same directory.
	/// Therefore, we create a random name for each application, so data for each app can be kept
	/// separate from others that might use this framework.
	/// - Returns: the name of the unique directory for this application
	static func getUniqueDirectoryName() -> String {
		
		// TODO: use the Bundle.main.identifier if it exists
		// would that cause issues between runs?
		
		if let name = UserDefaults.standard.string(forKey: uniqueDirectoryNameKey) {
			// already have a special name, return that
			return name
		}
		
		// no special name yet, create one and save it
		let name = UUID().uuidString
		UserDefaults.standard.set(name, forKey: uniqueDirectoryNameKey)
		
		return name
	}
}


// MARK: - Local Methods
@available(OSX 10.12, iOS 10.0, *)
extension StandardLocalStorage {
	
	func clearBuffer() {
		buffer = []
		buffer.reserveCapacity(Int(maxBufferSize))
	}
	
	private func writeImmediately(_ save: Save) {
		
		let pending = pendingSaves
		pendingSaves.removeAll()
		
		DispatchQueue.global(qos: .userInteractive).sync {
			// capture the currently pending saves
			
			self.highPriorityFile.write(
				(pending.flatMap { $0.entries } + save.entries)
					.map { $0.makeEntry() }
			)
		}
	}
	
	private func writeLater(_ save: Save) {
		
		pendingSaves.insert(save)
		
		queue.async {
			// capture the current buffer, so it doesn't change on us
			// unexpectedly
			self.file.write(save.entries.map { $0.makeEntry() })
			self.pendingSaves.remove(save)
		}
	}
}


// MARK: - Backer Conformance
@available(OSX 10.12, iOS 10.0, *)
extension StandardLocalStorage {
	
	public func log(_ data: EntryData) {
		buffer.append(data)
		
		if data.severity > .warning {
			// something real bad happened, write all the entries
			// as fast as possible in case the program is about to crash
			let save = Save(buffer)
			clearBuffer()
			writeImmediately(save)
			
		} else if buffer.count >= maxBufferSize {
			// we filled up on entries, write them lazily
			let save = Save(buffer)
			clearBuffer()
			writeLater(save)
		}
	}
}
