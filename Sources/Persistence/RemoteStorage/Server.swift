//
//  Server.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import struct Foundation.URL

public protocol Server {
	func accept(_ file: URL, onComplete: @escaping (Bool) -> Void)
}
