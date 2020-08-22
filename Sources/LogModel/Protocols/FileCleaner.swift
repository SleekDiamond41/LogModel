//
//  FileCleaner.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import struct Foundation.URL

protocol FileCleaner {
	func queueCleanup(at url: URL)
}
