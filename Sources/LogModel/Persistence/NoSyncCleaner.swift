//
//  NoSyncCleaner.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation

@available(OSX 10.12, iOS 10.0, *)
class NoSyncCleaner: FileCleaner {
	
	let maxFileCount = 10
	
	let syncList: FileSyncList
	
	init(syncList: FileSyncList) {
		self.syncList = syncList
	}
	
	func queueCleanup(at url: URL) {
		// add the item to the list
		syncList.add(url)
		
		if syncList.count > maxFileCount,
		   let next = syncList.next().first {
			// we have too many files, time to remove stuff
			syncList.remove(next)
		}
	}
}
