//
//  Delegate.swift
//  
//
//  Created by Michael Arrington on 8/9/20.
//

protocol Delegate {
	
	@inlinable
	func log(_ severity: Severity, _ message: StaticString)
}
