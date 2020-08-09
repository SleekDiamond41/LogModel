//
//  Writer.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

protocol Writer {
	func write(_ entry: Entry)
	func setMostRecentlySyncedID(_ data: SyncData)
	func getMostRecentlySync() -> SyncData?
}
