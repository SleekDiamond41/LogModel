//
//  FileSystem.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation
import Models
import Protocols

public class FileSystem: Backer {
	
	public func log(_ data: EntryData) {
		
	}
}


public class ApplicationServer: Backer {
	let url: URL
	
	public init(url: URL) {
		self.url = url
	}
	
	public func log(_ data: EntryData) {
		preconditionFailure("still need to implement this one")
	}
}
