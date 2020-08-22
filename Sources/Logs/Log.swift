//
//  Log.swift
//  
//
//  Created by Michael Arrington on 8/9/20.
//


@available(iOS 10.0, OSX 10.12, *)
public struct Log {
	
	let delegate: Delegate
	
	public init(subsystem: String, category: String) {
		
		if #available(iOS 14, OSX 11.0, *) {
			self.delegate = NewDelegate(subsystem: subsystem, category: category)
		} else {
			self.delegate = OldDelegate(subsystem: subsystem, category: category)
		}
	}
	
	
	public func debug(_ message: StaticString) {
		delegate.log(.debug, message)
	}
	
	public func info(_ message: StaticString) {
		delegate.log(.info, message)
	}
	
	public func notice(_ message: StaticString) {
		delegate.log(.notice, message)
	}
	
	public func error(_ message: StaticString) {
		delegate.log(.error, message)
	}
	
	public func fault(_ message: StaticString) {
		delegate.log(.fault, message)
	}
}
