//
//  Log.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import Foundation

extension FileManager {
	static let local = FileManager()
}

/// The entry point for logging events.
///
/// A `Log` has several instance methods that facilitate recording events. Calling any of these methods stores the appropriate information to a local database.
///
/// The `Log` can be configured to periodically send batches of new events to a server, for easier debugging and analytics;
/// the alternative being to instruct Users to send their logs manually, or attempt to produce reproduction steps for the bug they found.
///
/// - Note: The current iteration of `Log` is thread-safe. The relevant state--including a timestamp--is captured immediately, then a task is dispatched to write to the Log.
///
@available(OSX 10.12, iOS 10.0, *)
public class Log: CustomStringConvertible {
	
	let db: LocalStorage
	let directory: URL
	let queue: DispatchQueue
	
	
	let bundleID: String
	let userID: UUID?
	let deviceID: UUID?
	
	private var entries = [Entry]()
	
	
	public var description: String {
		return "Log - \(directory.path)"
	}
	
	
	/// - Parameters:
	///   - bundleID: the identifier of the program's Bundle
	///   - userID: an optional identifier that can be used to associate logged events to a specific user (i.e. for analytics)
	///   - deviceID: an optional identifier that can be used to to associate logged events to a specific device (i.e. for analytics)
	///   - dir: a custom directory in which to store the log file. The default value resolves to "../Application Support/Logs/$(`bundleID`)/". Note that the default `dir` replaces periods (".") in the `bundleID` with two underscores ("__") to avoid naming issues within the File System.
	///   - process: a custom name for the file associated with this instance. The default value is "Common".
	public init(bundleID: String, userID: UUID?, deviceID: UUID?, dir: URL? = nil, process: String = "Common") {
		
		let directory = dir ?? FileManager.local.urls(for: .applicationSupportDirectory, in: .userDomainMask)
			.first!	// there darn well better be at least one App Support directory
			.appendingPathComponent("Logs")
			.appendingPathComponent(bundleID.replacingOccurrences(of: ".", with: "__"))
		
		self.directory = directory
		self.queue = DispatchQueue(label: bundleID + ".Log.worker.\(UUID())", qos: .userInteractive)
		self.bundleID = bundleID
		self.userID = userID
		self.deviceID = deviceID
		
		do {
			print(directory)
			
			let metadataDir = directory.appendingPathComponent("Meta-Data")
			let lowPriority = directory.appendingPathComponent("Standard")
			let highPriority = directory.appendingPathComponent("HighPriority")
			
			for dir in [metadataDir, lowPriority, highPriority] {
				try FileManager.local.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
			}
			
			let server = MyServer(url: URL(string: "https://localhost:8080/thingy")!, session: .shared)
			let syncList = FileSyncList(file: metadataDir.appendingPathComponent("pendingSyncs").appendingPathExtension("json"))
			let cleaner = FileSynchronizer(syncList: syncList, server: server)
			
			let standardFileProvider = IntegerFilenameProviding(dir: self.directory.appendingPathComponent("Standard"), manager: .local, cleaner: cleaner)
			let highPriorityFileProvider = IntegerFilenameProviding(dir: self.directory.appendingPathComponent("HighPriority"), manager: .local, cleaner: cleaner)
			let standardFile = MyFileDelegate(filename: standardFileProvider)
			let highPriorityFile = MyFileDelegate(filename: highPriorityFileProvider)
			
			self.db = JSONLinesLocalStorage(standardFile, highPriorityFile: highPriorityFile)
			
		} catch {
			preconditionFailure(String(describing: error))
		}
	}
	
	/// Returns the last path component from a URL path
	/// - Parameter string: the URL path
	/// - Returns: the file name, or directory if no file is included
	@inlinable
	func lastComponent<S>(from s: S) -> String where S: StringProtocol {
		assert(s.last != "/")
		
		guard let i = s.lastIndex(of: "/") else {
			return String(s)
		}
		return String(s[s.index(after: i)...])
	}
	
	@usableFromInline
	struct ConversionError: Error {
		@inlinable
		init() { }
	}
	
	/// Computes the directory and file names from a String path
	/// - Parameter string: a file path
	/// - Returns: a tuple of the directory and file name
	/// - Throws: `ConversionError` if `string` cannot be split into a directory and file pair
	@inlinable
	func directoryFile(from string: String) throws -> (String, String) {
		
		guard string.contains("/") else {
			throw ConversionError()
		}
		
		let file = lastComponent(from: string)
		
		let cutoff = string.index(string.endIndex, offsetBy: -(file.count + 1))
		let dir = lastComponent(from: string[..<cutoff])
		
		return (dir, file)
	}
	
	public func log(_ severity: Severity, _ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		let date = Date()
		
		let (directory, filename): (String, String)
		
		do {
			(directory, filename) = try directoryFile(from: file)
		} catch is ConversionError {
			(directory, filename) = ("N/A", file)
		} catch {
			preconditionFailure("unknown error type")
		}
		
		self.queue.sync {
			
			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
							  date: date,
							  severity: severity,
							  message: message,
							  directory: directory,
							  file: filename,
							  function: function,
							  line: line,
							  customData: customData,
							  bundleID: self.bundleID,
							  userID: self.userID,
							  deviceID: self.deviceID))
		}
	}
	
	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
	@inlinable
	public func verbose(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		log(.verbose,
			message,
			customData: customData,
			file: file,
			function: function,
			line: line)
	}
//
//	/// Debugging information. These messages should ideally describe exactly what happened that was incorrect, possible reasons this state may have been entered, and possible solutions to implement that might fix this failure.
//	public func debug(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
//
//		let date = Date()
//
//		queue.sync {
//			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
//							  date: date,
//							  severity: .debug,
//							  message: message,
//							  file: file,
//							  function: function,
//							  line: line,
//							  customData: customData,
//							  bundleID: self.bundleID,
//							  userID: self.userID,
//							  deviceID: self.deviceID))
//		}
//	}
//
//	/// General information, such as user interactions
//	public func info(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
//
//		let date = Date()
//
//		queue.sync {
//			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
//							  date: date,
//							  severity: .info,
//							  message: message,
//							  file: file,
//							  function: function,
//							  line: line,
//							  customData: customData,
//							  bundleID: self.bundleID,
//							  userID: self.userID,
//							  deviceID: self.deviceID))
//		}
//	}
//
//	/// Entered an unfortunate, but rercoverable state.
//	public func warning(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
//
//		let date = Date()
//
//		queue.sync {
//			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
//							  date: date,
//							  severity: .warning,
//							  message: message,
//							  file: file,
//							  function: function,
//							  line: line,
//							  customData: customData,
//							  bundleID: self.bundleID,
//							  userID: self.userID,
//							  deviceID: self.deviceID))
//		}
//	}
//
//	/// Entered an unrecoverable state.
//	public func error(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
//
//		let date = Date()
//
//		queue.sync {
//			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
//							  date: date,
//							  severity: .error,
//							  message: message,
//							  file: file,
//							  function: function,
//							  line: line,
//							  customData: customData,
//							  bundleID: self.bundleID,
//							  userID: self.userID,
//							  deviceID: self.deviceID))
//		}
//	}
//
//	/// The program entered a state that should not be possible.
//	public func wtf(_ message: String, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
//
//		let date = Date()
//
//		queue.sync {
//			self.db.log(Entry(id: nil,	// id will be set by the LocalStorage
//							  date: date,
//							  severity: .wtf,
//							  message: message,
//							  file: file,
//							  function: function,
//							  line: line,
//							  customData: customData,
//							  bundleID: self.bundleID,
//							  userID: self.userID,
//							  deviceID: self.deviceID))
//		}
//	}
}
