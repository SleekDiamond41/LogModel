//
//  Reader.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

protocol Reader {
	func get(firstID: Int64, max: UInt32) -> [Entry]
}
