//
//  FilenameProviding.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import Foundation
import OSLog

protocol FilenameProviding {
	func currentFile() -> URL
	func advance()
}


@available(OSX 10.12, iOS 10.0, *)
final class IntegerFilenameProviding: FilenameProviding {
	
	let dir: URL
	let cleaner: FileCleaner
	let maxFiles: UInt16 = 1_000
	
	private var fileIndex: UInt16 = 0
	
	private lazy var file = getFile()
	
	init(dir: URL, manager: FileManager, cleaner: FileCleaner) {
		self.dir = dir
		self.cleaner = cleaner
		
		let logger = OSLog(subsystem: "com.duct-ape-productions.LogModel", category: "PrepareDirectory")
		
		do {
			try manager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
		} catch {
			os_log("failed to create directory at '%s' with error '%s'", log: logger, type: .fault, dir.absoluteString, error.localizedDescription)
		}
		
		do {
			let mostRecent = try manager.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)
				.compactMap { UInt16($0.lastPathComponent) }
				.max()
			
			let index = mostRecent.map { $0 + 1 } ?? 0
			
			if index < maxFiles {
				// next number
				self.fileIndex = index
			} else {
				// loop back around
				self.fileIndex = 0
			}
		} catch {
			os_log("failed to read contents of directory '%s' with error '%s'", log: logger, type: .fault, dir.absoluteString, error.localizedDescription)
			
			self.fileIndex = 0
		}
	}
	
	fileprivate func getFile() -> URL {
		return dir.appendingPathComponent("\(fileIndex)")
	}
	
}

// MARK: - FilenameProviding Conformance
@available(OSX 10.12, iOS 10.0, *)
extension IntegerFilenameProviding {
	
	func currentFile() -> URL {
		return file
	}
	
	func advance() {
		// get the URL while it's still valid
		let oldFile = file
		
		// increment count
		fileIndex += 1
		
		// if count is too high, loop back around
		if fileIndex >= maxFiles {
			fileIndex = 0
		}
		
		// update the state
		file = getFile()
		
		// register file for cleanup
		cleaner.queueCleanup(at: oldFile)
	}
}
