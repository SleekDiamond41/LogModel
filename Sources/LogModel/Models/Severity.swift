//
//  Severity.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

/// The severity of a message.
public enum Severity: UInt8, Codable {
	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
	case verbose = 0
	
	/// Debugging information. These messages should ideally describe exactly what happened that was incorrect, possible reasons this state may have been entered, and possible solutions to implement that might fix this failure.
	case debug = 1
	
	/// General information, such as user interactions
	case info = 2
	
	/// Entered a rercoverable state.
	case warning = 3
	
	/// Entered an unrecoverable state.
	case error = 4
	
	/// The program entered a state that should not be possible.
	case wtf = 5
}
