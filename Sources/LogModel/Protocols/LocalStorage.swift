//
//  LocalStorage.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

protocol LocalStorage {
	func log(_ : Entry)
	func getSyncBatch(max: UInt32) -> [Entry]
	func setLastSyncedID(_ id: Int64)
}
