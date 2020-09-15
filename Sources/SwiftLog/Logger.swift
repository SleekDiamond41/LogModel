//
//  Logger.swift
//  
//
//  Created by Michael Arrington on 9/10/20.
//

import Foundation
import Models

public typealias Severity = Models.Severity

public protocol Logger {
	func log(_ severity: Severity, _ message: Message, file: String, function: String, line: UInt32)
}


extension Logger {
	
	/// Logs an error and raises an assertion failure if `condition` resolves to false; otherwise has no effect.
	///
	/// This method may be used in place of `Swift.assert(_:)` and `Swift.assert(_:,_:)`.
	/// Note that the standard `assert` methods have no effect in a production application,
	/// but this method will log failures regardless of the target environment (at virtually no performance cost).
	///
	/// - Parameters:
	///   - condition: a condition which must be met in order for the program to operate correctly
	///   - message: an error message to display in the event of an unmet `condition`
	public func assert(_ condition: @autoclosure () -> Bool, _ message: Message, file: StaticString = #file, function: String = #function, line: UInt = #line) {
		
		let didPass = condition()
		
		if didPass {
			// nothing negative to report
			return
		}
		
		error(message, file: file.description, function: function, line: UInt32(line))
		
		Swift.assertionFailure(message.description, file: file, line: line)
	}
	
	
	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
	public func verbose(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		log(.verbose, message, file: file, function: function, line: line)
	}
	
	
	/// Debugging information. These messages should ideally describe exactly what happened that was incorrect, possible reasons this state may have been entered, and possible solutions to implement that might fix this failure.
	public func debug(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		log(.debug, message, file: file, function: function, line: line)
	}
	
	/// General information, such as user interactions
	public func info(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		log(.info, message, file: file, function: function, line: line)
	}
	
	/// Entered an unfortunate, but recoverable state.
	public func warning(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		log(.warning, message, file: file, function: function, line: line)
	}
	
	/// Entered an unrecoverable state.
	public func error(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		log(.error, message, file: file, function: function, line: line)
	}
	
	/// The program entered a state that should not be possible.
	///
	/// On the order of:
	///
	///     var a: Int? = 0
	///     guard a != nil else {
	///         log.wtf("we _just_ set `a` to 0, but it was nil during the next instruction")
	///         preconditionFailure()
	///     }
	public func wtf(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		log(.wtf, message, file: file, function: function, line: line)
	}
}
