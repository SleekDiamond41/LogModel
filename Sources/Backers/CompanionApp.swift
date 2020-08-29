//
//  CompanionApp.swift
//  
//
//  Created by Michael Arrington on 8/28/20.
//

import Foundation
import Models
import Protocols
import Sockets


@available(OSX 10.15, iOS 13.0, *)
public class CompanionApp: Backer {
	
	let socket: Socket
	
	public init(url: URL) {
		self.socket = Socket(url: url)
	}
	
	public func log(_ data: EntryData) {
		socket.log(data)
	}
}
