//
//  IntegerFilenameProviding.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation


@available(OSX 10.12, iOS 10.0, *)
final class IntegerFilenameProviding: FilenameProviding {
	
	let logger = DebugReporter(category: "Persistence")
	let dir: URL
	let archiver: Archiver
	let maxFiles: UInt16 = 1_000
	
	private var fileIndex: UInt16 = 0
	
	private var file: URL!
	
	init(dir: URL, manager: FileManager, cleaner: Archiver) {
		self.dir = dir
		self.archiver = cleaner
		
		do {
			try manager.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
		} catch {
			logger.log("failed to create directory at '%s' with error '%s'", dir.absoluteString, error.localizedDescription)
			preconditionFailure()
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
			logger.log("failed to read contents of directory '%s' with error '%s'", dir.absoluteString, error.localizedDescription)
			
			self.fileIndex = 0
		}
		
		self.file = getFile()
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
		guard let oldFile = file else {
			logger.log("programmer error: property `file` should never be nil after initialization")
			preconditionFailure("")
		}
		
		defer {
			archiver.archive(oldFile)
		}
		
		// increment count
		fileIndex += 1
		
		// if count is too high, loop back around
		if fileIndex >= maxFiles {
			fileIndex = 0
		}
		
		// update the state
		file = getFile()
	}
}
