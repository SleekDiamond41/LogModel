//
//  Severity.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

/// The severity of a message.
enum Severity: UInt8, Codable, Comparable {
	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
	case verbose = 10
	
	/// Debugging information. These messages should ideally describe exactly what happened that was incorrect, possible reasons this state may have been entered, and possible solutions to implement that might fix this failure.
	case debug = 20
	
	/// General information, such as user interactions
	case info = 30
	
	/// Entered an unfortunate, but rercoverable state.
	case warning = 40
	
	/// Entered an unrecoverable state.
	case error = 50
	
	/// The program entered a state that should not be possible.
	case wtf = 60
}

// MARK: - Comparable Conformance
extension Severity {
	
	static func <(left: Severity, right: Severity) -> Bool {
		return left.rawValue < right.rawValue
	}
}
