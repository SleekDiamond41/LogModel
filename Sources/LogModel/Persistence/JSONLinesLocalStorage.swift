//
//  JSONLinesLocalStorage.swift
//  
//
//  Created by Michael Arrington on 8/17/20.
//

import Foundation
import OSLog


final class Save: Hashable {
	let id = UUID()
	let entries: [Entry]
	
	init(_ entries: [Entry]) {
		self.entries = entries
	}
}

// MARK: - Equatable Conformance
extension Save {
	
	@inlinable
	static func ==(left: Save, right: Save) -> Bool {
		return left.id == right.id
	}
}

// MARK: - Hashable Conformance
extension Save {
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

final class JSONLinesLocalStorage: LocalStorage {
	
	let file: FileDelegate
	let highPriorityFile: FileDelegate
	let maxBufferSize: Int
	let queue: DispatchQueue
	
	private var buffer = [Entry]()
	
	private var pendingSaves = Set<Save>()
	
	
	init(_ file: FileDelegate, highPriorityFile: FileDelegate, maxBufferSize: Int = 100) {
		self.file = file
		self.highPriorityFile = highPriorityFile
		self.maxBufferSize = maxBufferSize
		
		// Background queue because logging isn't an immediate concern, so long as it gets done.
		// Target global(.background) to take advantage of existing threads
		// instead of creating a new one for this queue.
		self.queue = DispatchQueue(label: "com.duct-ape-productions.LogModel.JSONLinesLocalStorage.BackgroundUpdateQueue", qos: .background, target: .global(qos: .background))
		
		// make sure buffer is initialized with the property capacity
		clearBuffer()
	}
}


// MARK: - Local Methods
extension JSONLinesLocalStorage {
	
	@inlinable
	func clearBuffer() {
		buffer = []
		buffer.reserveCapacity(maxBufferSize)
	}
	
	private func writeImmediately(_ save: Save) {
		pendingSaves.insert(save)
		
		DispatchQueue.global(qos: .userInteractive).sync { [pendingSaves] in
			// we're saving all the pendingSaves, so capture them and make sure they don't change unexpectedly
			for save in pendingSaves {
				self.highPriorityFile.write(save.entries)
			}
			
			// we've written everything at least once,
			// no reason to leave pendingSaves open
			self.pendingSaves.removeAll()
		}
	}
	
	private func writeLater(_ save: Save) {
		
		pendingSaves.insert(save)
		
		queue.async {
			// capture the current buffer, so it doesn't change on us
			// unexpectedly
			self.file.write(save.entries)
			self.pendingSaves.remove(save)
		}
	}
}


// MARK: - LocalStorage Conformance
extension JSONLinesLocalStorage {
	
	func log(_ entry: Entry) {
		buffer.append(entry)
		
		if entry.severity > .warning {
			// something real bad happened, write all the entries
			// as fast as possible in case the program is about to crash
			let save = Save(buffer)
			clearBuffer()
			writeImmediately(save)
			
		} else if buffer.count > maxBufferSize {
			// we filled up on entries, write them lazily
			let save = Save(buffer)
			clearBuffer()
			writeLater(save)
		}
	}
}
