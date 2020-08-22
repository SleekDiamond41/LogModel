//
//  FileSynchronizer.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation

@available(OSX 10.12, iOS 10.0, *)
class FileSynchronizer: FileCleaner {
	
	let syncList: FileSyncList
	let server: Server
	
	private var pendingFiles = Set<URL>()
	private let queue: DispatchQueue
	
	init(syncList: FileSyncList, server: Server) {
		self.syncList = syncList
		self.server	= server
		
		self.queue = DispatchQueue(label: "com.duct-ape-productions.LogModel.FileSynchronizer.BackgroundUpdateQueue", qos: .background, target: .global(qos: .background))
	}
	
	private func send(file: URL) {
		
		guard !pendingFiles.contains(file) else {
			// don't to send the same file multiple times concurrently
			return
		}
		
		server.accept(file) { [weak self] (successful) in
			// weak self shouldn't really be necessary,
			// but it's a good practice to be in
			guard let self = self else { return }
			
			self.pendingFiles.remove(file)
			
			if successful {
				self.syncList.remove(file)
			}
		}
	}
}

// MARK: - FileCleaner Conformance
@available(OSX 10.12, iOS 10.0, *)
extension FileSynchronizer {
	
	func queueCleanup(at url: URL) {
		self.queue.async {
			self.syncList.add(url)
			
			for file in self.syncList.next() {
				self.send(file: file)
			}
		}
	}
}
