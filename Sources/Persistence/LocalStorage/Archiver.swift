//
//  Archiver.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import struct Foundation.URL

protocol Archiver {
	func archive(_ url: URL)
}
