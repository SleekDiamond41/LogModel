//
//  FileDelegate.swift
//  
//
//  Created by Michael Arrington on 8/21/20.
//

import class Models.Entry

protocol FileDelegate {
	func write(_ entries: [Entry])
}
