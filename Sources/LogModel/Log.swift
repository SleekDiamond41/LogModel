//
//  Log.swift
//  
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation


@available(OSX 10.12, iOS 10.0, *)
public struct Log {
	
	let bundleID: String
	let category: Category
	let backer: LogBacker
	
	init(bundleID: String, category: Category, backer: LogBacker) {
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
		let serverURL: URL
		let userID: UUID?
		let deviceID: UUID?
		
		public init(bundleID: String, userID: UUID?, deviceID: UUID?, serverURL: URL) {
			self.bundleID = bundleID
			self.userID = userID
			self.deviceID = deviceID
			self.serverURL = serverURL
		}
	}
	
	public static func configureCommon(_ config: Config) {
		guard self.config == nil else {
			preconditionFailure("this method may be called exactly once")
		}
		
		self.config = config
	}
	
	private static var config: Config!
	
	public private(set) static var common: Log! = {
		
		let backer: LogBacker
		
		// FIXME: create a robust way to use different Backers based on needs and availability
		// including SocketBacker... which can feasibly work!
		
		if #available(macOS 10.15, iOS 13.0, *) {
			let storage = SocketBacker()
			
			backer = LogBacker(bundleID: config.bundleID,
								   userID: config.userID,
								   deviceID: config.deviceID,
								   storage: storage)
		} else {
			backer = LogBacker(bundleID: config.bundleID,
								   userID: config.userID,
								   deviceID: config.deviceID,
								   serverURL: config.serverURL)
		}
		
		
		return Log(bundleID: config.bundleID,
				   category: .common,
				   backer: backer)
	}()
	
	
	/// Produces a `Log` instance that can be used to records and syncs data twice: once for
	/// the creator of the module, once for the consuming application. The application always gets
	/// log data, but the module creator can still get meaningful analytics and debugging data.
	/// - Parameter bundleID: the identifier of the module bundle, i.e. "com.my-company.helpful-module"
	/// - Returns: a `Log` instance that reports events to the module creator, and also to the common `Log`.
	public static func forFramework(bundleID: String, syncingTo url: URL) -> Log {
		
		return Log(bundleID: bundleID,
				   category: .common,
				   backer: FrameworkLog(bundleID: bundleID,
										common: Log.common?.backer,
										serverURL: url))
	}
}


// MARK: - Public Logging Methods
@available(OSX 10.12, iOS 10.0, *)
extension Log {
	
	
	/// Extra information that might be useful to have, such as entering or exiting low-level functions.
	public func verbose(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		backer.log(.verbose,
				   message,
				   category: category.name,
				   bundleID: bundleID,
				   customData: customData,
				   file: file,
				   function: function,
				   line: line)
	}
	
	
	/// Debugging information. These messages should ideally describe exactly what happened that was incorrect, possible reasons this state may have been entered, and possible solutions to implement that might fix this failure.
	public func debug(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		backer.log(.debug,
				   message,
				   category: category.name,
				   bundleID: bundleID,
				   customData: customData,
				   file: file,
				   function: function,
				   line: line)
	}
	
	/// General information, such as user interactions
	public func info(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		backer.log(.info,
				   message,
				   category: category.name,
				   bundleID: bundleID,
				   customData: customData,
				   file: file,
				   function: function,
				   line: line)
	}
	
	/// Entered an unfortunate, but recoverable state.
	public func warning(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		backer.log(.warning,
				   message,
				   category: category.name,
				   bundleID: bundleID,
				   customData: customData,
				   file: file,
				   function: function,
				   line: line)
	}
	
	/// Entered an unrecoverable state.
	public func error(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		backer.log(.error,
				   message,
				   category: category.name,
				   bundleID: bundleID,
				   customData: customData,
				   file: file,
				   function: function,
				   line: line)
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
	public func wtf(_ message: Message, customData: String? = nil, file: String = #file, function: String = #function, line: UInt32 = #line) {
		backer.log(.wtf,
				   message,
				   category: category.name,
				   bundleID: bundleID,
				   customData: customData,
				   file: file,
				   function: function,
				   line: line)
	}
}
