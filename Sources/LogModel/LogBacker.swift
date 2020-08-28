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

protocol DirectoryProviding {
	var dir: URL { get }
}

class UserDefaultsStoredDirectoryProviding: DirectoryProviding {
	
	/// A randomly selected key that indicates
	let dirNameKey = "8729871087983720834"
	
	let root: URL
	
	init(root: URL) {
		self.root = root
	}
	
	lazy var dir: URL = {
		let name: String
		
		if let dir = UserDefaults.standard.string(forKey: dirNameKey) {
			name = dir
		} else {
			name = UUID().uuidString
			UserDefaults.standard.set(name, forKey: dirNameKey)
		}
		
		return root.appendingPathComponent(name)
	}()
}


/// The entry point for logging events.
///
/// A `Log` has several instance methods that facilitate recording events. Calling any of these methods stores the appropriate information to a local database.
///
/// The `Log` can be configured to periodically send batches of new events to a server, for easier debugging and analytics;
/// the alternative being to instruct Users to send their logs manually, or attempt to produce reproduction steps for the bug they found.
///
/// - Note: The current iteration of `Log` is thread-safe. The relevant state--including a timestamp--is captured immediately, then a task is dispatched to write to the Log.
@available(OSX 10.12, iOS 10.0, *)
class LogBacker: CustomStringConvertible {
	
	let storage: Backer
	let directory: URL
	let queue: DispatchQueue
	
	
	let bundleID: String
	let userID: UUID?
	let deviceID: UUID?
	
	
	public var description: String {
		return "Log - \(directory.path)"
	}
	
	init(bundleID: String, userID: UUID?, deviceID: UUID?, storage: Backer) {
		self.bundleID = bundleID
		self.userID = userID
		self.deviceID = deviceID
		self.storage = storage
		self.queue = DispatchQueue(label: bundleID + ".Log.worker.\(UUID())", qos: .userInteractive)
		self.directory = FileManager.local.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
	}
	
	/// - Parameters:
	///   - bundleID: the identifier of the program's Bundle
	///   - userID: an optional identifier that can be used to associate logged events to a specific user (i.e. for analytics)
	///   - deviceID: an optional identifier that can be used to to associate logged events to a specific device (i.e. for analytics)
	///   - serverURL: a URL to which log entries should be synced
	init(bundleID: String, userID: UUID?, deviceID: UUID?, serverURL: URL?, dir: URL? = nil) {
		
		self.directory = dir ?? FileManager.local.urls(for: .applicationSupportDirectory, in: .userDomainMask)
			.first!	// there darn well better be at least one App Support directory
			.appendingPathComponent("Logs")
			.appendingPathComponent(bundleID)
		
		self.queue = DispatchQueue(label: bundleID + ".Log.worker.\(UUID())", qos: .userInteractive)
		
		self.bundleID = bundleID
		self.userID = userID
		self.deviceID = deviceID
		
		do {
			debugPrint(directory)
			
			let metadataDir = directory.appendingPathComponent("Meta-Data")
			let lowPriority = directory.appendingPathComponent("Standard")
			let highPriority = directory.appendingPathComponent("HighPriority")
			
			for dir in [metadataDir, lowPriority, highPriority] {
				try FileManager.local.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
			}
			
			let syncList = FileSyncList(file: metadataDir.appendingPathComponent("pendingSyncs").appendingPathExtension("json"))
			
			let cleaner: FileCleaner
			
			if let url = serverURL {
				
				let config = URLSessionConfiguration()
				
				// be a good citizen
				config.allowsCellularAccess = false
				
				if #available(OSX 10.15, iOS 13, *) {
					config.allowsConstrainedNetworkAccess = false
					config.allowsExpensiveNetworkAccess = false
				}
				
				// background execution actually preferred
				config.shouldUseExtendedBackgroundIdleMode = true
				
				let session = URLSession(configuration: config)
				let server = MyServer(url: url, session: session)
				
				cleaner = FileSynchronizer(syncList: syncList, server: server)
				
			} else {
				
				cleaner = NoSyncCleaner(syncList: syncList)
			}
			
			let standardFileProvider = IntegerFilenameProviding(dir: self.directory.appendingPathComponent("Standard"), manager: .local, cleaner: cleaner)
			let highPriorityFileProvider = IntegerFilenameProviding(dir: self.directory.appendingPathComponent("HighPriority"), manager: .local, cleaner: cleaner)
			let standardFile = MyFileDelegate(filename: standardFileProvider)
			let highPriorityFile = MyFileDelegate(filename: highPriorityFileProvider)
			
			self.storage = StandardLocalStorarge(standardFile, highPriorityFile: highPriorityFile)
			
		} catch {
			preconditionFailure(String(describing: error))
		}
	}
	
	
	func log(_ severity: Severity, _ message: Message, category: String, bundleID: String, customData: String?, file: String, function: String, line: UInt32) {
		let date = Date()
		
		queue.sync {
			
			let (directory, filename): (String, String)
			
			do {
				(directory, filename) = try self.directoryFile(from: file)
			} catch is ConversionError {
				(directory, filename) = ("N/A", file)
			} catch {
				preconditionFailure("unknown error type")
			}
			
			let entry = Entry(id: nil,	// id will be set by the Backer
							  date: date,
							  severity: severity,
							  message: message,//.string(for: severity <= .debug ? .low : .high),
							  category: category,
							  directory: directory,
							  file: filename,
							  function: function,
							  line: line,
							  customData: customData ?? "",
							  bundleID: self.bundleID,
							  userID: self.userID,
							  deviceID: self.deviceID)
			
			self.storage.log(entry)
		}
	}
}


// MARK: - Utility Methods
@available(OSX 10.12, iOS 10.0, *)
extension LogBacker {
	
	/// Returns the last path component from a URL path
	/// - Parameter string: the URL path
	/// - Returns: the file name, or directory if no file is included
	@inlinable
	final func lastComponent<S>(from s: S) -> String where S: StringProtocol {
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
	final func directoryFile(from string: String) throws -> (String, String) {
		
		guard string.contains("/") else {
			throw ConversionError()
		}
		
		let file = lastComponent(from: string)
		
		let cutoff = string.index(string.endIndex, offsetBy: -(file.count + 1))
		let dir = lastComponent(from: string[..<cutoff])
		
		return (dir, file)
	}
}
