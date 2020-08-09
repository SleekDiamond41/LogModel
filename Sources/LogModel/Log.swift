//
//  Log.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import Foundation
import Files


/// The entry point for logging events.
///
/// A `Log` has several instance methods that facilitate recording events. Calling any of these methods stores the appropriate information to a local database.
///
/// The `Log` can be configured to periodically send batches of new events to a server, for easier debugging and analytics;
/// the alternative being to instruct Users to send their logs manually, or attempt to produce reproduction steps for the bug they found.
///
/// - Note: The current iteration of `Log` is thread-safe. The relevant state--including a timestamp--is captured immediately, then a task is queued up to write the event to the log file on a background thread. It is theoretically possible that, in the event of a crash, information will not be written to the log.
///
public class Log: CustomStringConvertible {
	
	let db: LocalStorage
	let directory: URL
	let queue: DispatchQueue
	
	
	let bundleID: String
	let userID: UUID?
	let deviceID: UUID?
	
	
	public var description: String {
		return "Log - \(directory.path)"
	}
	
	
	/// - Parameters:
	///   - bundleID: the identifier of the program's Bundle
	///   - userID: an optional identifier that can be used to associate logged events to a specific user (i.e. for analytics)
	///   - deviceID: an optional identifier that can be used to to associate logged events to a specific device (i.e. for analytics)
	///   - dir: a custom directory in which to store the log file. The default value resolves to "../Application Support/$(`bundleID`)/Logs/". Note that periods (".") in the `bundleID` will be replaced with underscores to avoid naming issues within the File System("_").
	///   - name: a custom name for the file associated with this instance. The default value is "Common".
	public init(bundleID: String, userID: UUID?, deviceID: UUID?, dir: URL? = nil, name: String = "Common") {
		
		self.directory = dir ?? Directory.appSupport
			.appending(bundleID.replacingOccurrences(of: ".", with: "_"))
			.Logs
			.url
		
		self.queue = DispatchQueue(label: bundleID + ".Log.worker.\(UUID())", qos: .default, target: .global(qos: .default))
		self.bundleID = bundleID
		self.userID = userID
		self.deviceID = deviceID
		
		
		let db = Database(dir: self.directory, name: name)
		
		self.queue.async {
			db.connect()
		}
		
		self.db = db
	}
	
	
	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
	public func verbose(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		let date = Date()
		
		queue.async {
			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
							  date: date,
							  severity: .verbose,
							  message: message,
							  file: file,
							  function: function,
							  line: line,
							  customData: customData,
							  bundleID: self.bundleID,
							  userID: self.userID,
							  deviceID: self.deviceID))
		}
	}
	
	/// Debugging information. These messages should ideally describe exactly what happened that was incorrect, possible reasons this state may have been entered, and possible solutions to implement that might fix this failure.
	public func debug(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		let date = Date()
		
		queue.async {
			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
							  date: date,
							  severity: .debug,
							  message: message,
							  file: file,
							  function: function,
							  line: line,
							  customData: customData,
							  bundleID: self.bundleID,
							  userID: self.userID,
							  deviceID: self.deviceID))
		}
	}
	
	/// General information, such as user interactions
	public func info(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		let date = Date()
		
		queue.async {
			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
							  date: date,
							  severity: .info,
							  message: message,
							  file: file,
							  function: function,
							  line: line,
							  customData: customData,
							  bundleID: self.bundleID,
							  userID: self.userID,
							  deviceID: self.deviceID))
		}
	}
	
	/// Entered an unfortunate, but rercoverable state.
	public func warning(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		let date = Date()
		
		queue.async {
			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
							  date: date,
							  severity: .warning,
							  message: message,
							  file: file,
							  function: function,
							  line: line,
							  customData: customData,
							  bundleID: self.bundleID,
							  userID: self.userID,
							  deviceID: self.deviceID))
		}
	}
	
	/// Entered an unrecoverable state.
	public func error(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		let date = Date()
		
		queue.async {
			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
							  date: date,
							  severity: .error,
							  message: message,
							  file: file,
							  function: function,
							  line: line,
							  customData: customData,
							  bundleID: self.bundleID,
							  userID: self.userID,
							  deviceID: self.deviceID))
		}
	}
	
	/// The program entered a state that should not be possible.
	public func wtf(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		
		let date = Date()
		
		queue.async {
			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
							  date: date,
							  severity: .wtf,
							  message: message,
							  file: file,
							  function: function,
							  line: line,
							  customData: customData,
							  bundleID: self.bundleID,
							  userID: self.userID,
							  deviceID: self.deviceID))
		}
	}
}
