//
//  MyServer.swift
//
//
//  Created by Michael Arrington on 8/22/20.
//

import Foundation
#if !targetEnvironment(simulator)
import OSLog
#endif

class DebugReporter {
	#if !targetEnvironment(simulator)
	private lazy var logger = OSLog(subsystem: "com.duct-ape-productions.LogModel", category: category)
	#endif
	
	let category: String
	
	init(category: String) {
		self.category = category
	}
	
	
	func log(_ message: StaticString, _ args: CVarArg...) {
		#if targetEnvironment(simulator)
		
		print(category, String(format: message, args))
		
		#else
		
		os_log(message,
			   log: self.logger,
			   type: .fault,
			   args)
		
		#endif
	}
}

@available(OSX 10.12, iOS 10.0, *)
class MyServer: Server {
	private let url: URL
	private let session: URLSession
	
	private let logger = DebugReporter(category: "MyServer")
	
	init(url: URL, session: URLSession) {
		self.url = url
		self.session = session
	}
}


// MARK: - Server Conformance
@available(OSX 10.12, iOS 10.0, *)
extension MyServer {
	
	private enum ResponseError: Error {
		case invalidData
	}
	
	func accept(_ file: URL, onComplete: @escaping (Bool) -> Void) {
		
		var request = URLRequest(url: url)
		
		do {
			request.httpBody = try Data(contentsOf: file)
			
			session.dataTask(with: request) { (data, response, error) in
				
				do {
					guard error == nil else {
						throw error!
					}
					
					guard let _ = data, let _ = response else {
						throw ResponseError.invalidData
					}
					
					// TODO: decide what a good response looks like, vs a bad one
					onComplete(true)
					
				} catch {
					self.logger.log("failed to sync file at URL '%s' to server at '%s' with error '%s'", file.absoluteString, self.url.absoluteString, error.localizedDescription)
					
					onComplete(false)
				}
				
			}.resume()
			
		} catch {
			logger.log("failed to get data from file at URL '%s' with error '%s'", file.absoluteString, error.localizedDescription)
		}
	}
}
