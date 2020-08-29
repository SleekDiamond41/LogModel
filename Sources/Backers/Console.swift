//
//  Console.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation
import Models
import Protocols


public class Console: Backer {
	
	public init() { }
	
	public func log(_ data: EntryData) {
		print()
	}
}
