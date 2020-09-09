//
//  Log.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation
import Backers
import Models
import Protocols
import Persistence
import Sockets


extension FileManager {
	static let local = FileManager()
}

public typealias Message = Models.Message
//typealias Entry = Models.Entry
//typealias Severity = Models.Severity
//typealias Backer = Protocols.Backer


@available(OSX 10.12, iOS 10.0, *)
public struct Log {
	
	let bundleID: String
	let category: Category
	let backer: Backer
	
	init(bundleID: String, category: Category, backer: Backer) {
		self.bundleID = bundleID
		self.category = category
		self.backer = backer
	}
	
	public subscript(_ category: Category) -> Log {
		return Log(bundleID: bundleID,
				   category: category,
				   backer: backer)
	}
	
	public struct Category: Equatable {
		let name: String
		
		public init(_ name: String) {
			self.name = name
		}
		
		public static let common = Category("Common")
	}
}


// MARK: - Static Methods
@available(OSX 10.12, iOS 10.0, *)
extension Log {
	
	public struct Config {
		let bundleID: String
		let serverURL: URL?
		let userID: UUID?
		let deviceID: UUID?
		
		public init(bundleID: String, userID: UUID?, deviceID: UUID?, serverURL: URL?) {
			self.bundleID = bundleID
			self.userID = userID
			self.deviceID = deviceID
			self.serverURL = serverURL
		}
	}
	
	public static func configureCommon(_ config: Config) {
		guard self.config == nil else {
//			preconditionFailure("this method may be called exactly once")
			return
		}
		
		self.config = config
	}
	
	private static var config: Config!
	
	internal static var shared: Log! = {
		
		let backer = Console()
		
		return Log(bundleID: config.bundleID,
				   category: Category("Common"),
				   backer: backer)
	}()
	
	public private(set) static var common: Log = {
		guard let source = shared else {
			preconditionFailure("please configure data with 'configureCommon(_:)' before logging any statements")
		}
		
		return source
		
//		let backer: LogBacker
//s
//		// FIXME: create a robust way to use different Backers based on needs and availability
//		// including SocketBacker... which can feasibly work!
//
//		if #available(macOS 10.15, iOS 13.0, *) {
//			let storage = SocketBacker()
//
//			backer = LogBacker(bundleID: config.bundleID,
//								   userID: config.userID,
//								   deviceID: config.deviceID,
//								   storage: storage)
//		} else {
//			backer = LogBacker(bundleID: config.bundleID,
//								   userID: config.userID,
//								   deviceID: config.deviceID,
//								   storage: StandardLocalStorage(forSyncingTo: config.serverURL, maxBufferSize: 10_000))
//		}
//
//
//		return Log(bundleID: config.bundleID,
//				   category: .common,
//				   backer: backer)
	}()
	
	
	/// Produces a `Log` instance that can be used to records and syncs data twice: once for
	/// the creator of the module, once for the consuming application. The application always gets
	/// log data, but the module creator can still get meaningful analytics and debugging data.
	/// - Parameter bundleID: the identifier of the module bundle, i.e. "com.my-company.helpful-module"
	/// - Returns: a `Log` instance that reports events to the module creator, and also to the common `Log`.
	public static func forFramework(bundleID: String, syncingTo url: URL) -> Log {
		preconditionFailure()
//		return Log(bundleID: bundleID,
//				   category: .common,
//				   backer: FrameworkLog(bundleID: bundleID,
//										common: Log.common?.backer,
//										storage: url))
	}
}


// MARK: - Public Logging Methods
@available(OSX 10.12, iOS 10.0, *)
extension Log {
	
	
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
		
		let threadID = Thread.current.hashValue
		
		let data = EntryData(date: Date(),
							 severity: .verbose,
							 message: message,
							 category: category.name,
							 appID: bundleID,
							 threadID: threadID,
							 filepath: file,
							 function: function,
							 line: line,
							 frameworkID: nil)
		
		backer.log(data)
	}
	
	
	/// Debugging information. These messages should ideally describe exactly what happened that was incorrect, possible reasons this state may have been entered, and possible solutions to implement that might fix this failure.
	public func debug(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		let threadID = Thread.current.hashValue
		
		let data = EntryData(date: Date(),
							 severity: .debug,
							 message: message,
							 category: category.name,
							 appID: bundleID,
							 threadID: threadID,
							 filepath: file,
							 function: function,
							 line: line,
							 frameworkID: nil)
		
		backer.log(data)
	}
	
	/// General information, such as user interactions
	public func info(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		let threadID = Thread.current.hashValue
		
		let data = EntryData(date: Date(),
							 severity: .info,
							 message: message,
							 category: category.name,
							 appID: bundleID,
							 threadID: threadID,
							 filepath: file,
							 function: function,
							 line: line,
							 frameworkID: nil)
		
		backer.log(data)
	}
	
	/// Entered an unfortunate, but recoverable state.
	public func warning(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		let threadID = Thread.current.hashValue
		
		let data = EntryData(date: Date(),
							 severity: .warning,
							 message: message,
							 category: category.name,
							 appID: bundleID,
							 threadID: threadID,
							 filepath: file,
							 function: function,
							 line: line,
							 frameworkID: nil)
		
		backer.log(data)
	}
	
	/// Entered an unrecoverable state.
	public func error(_ message: Message, file: String = #file, function: String = #function, line: UInt32 = #line) {
		let threadID = Thread.current.hashValue
		
		let data = EntryData(date: Date(),
							 severity: .error,
							 message: message,
							 category: category.name,
							 appID: bundleID,
							 threadID: threadID,
							 filepath: file,
							 function: function,
							 line: line,
							 frameworkID: nil)
		
		backer.log(data)
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
		let threadID = Thread.current.hashValue
		
		let data = EntryData(date: Date(),
							 severity: .wtf,
							 message: message,
							 category: category.name,
							 appID: bundleID,
							 threadID: threadID,
							 filepath: file,
							 function: function,
							 line: line,
							 frameworkID: nil)
		
		backer.log(data)
	}
}
