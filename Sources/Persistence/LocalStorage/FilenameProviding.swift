//
//  FilenameProviding.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import struct Foundation.URL

public protocol FilenameProviding {
	func currentFile() -> URL
	mutating func advance()
}
