//
//  SocketBacker.swift
//  
//
//  Created by Michael Arrington on 8/24/20.
//

import Foundation
import Combine
import Starscream


@available(OSX 10.15, iOS 13.0, *)
class SocketBacker: Backer {
	
	let connection: WebSocket
	
	private enum State {
		case connected
		case notConnected
		case connecting
	}
	
	
	/// Serial queue, avoid race conditions
	let queue: DispatchQueue
	
	private let subject = PassthroughSubject<Entry, Never>()
	
	private var tokens = Set<AnyCancellable>()
	private var state = State.notConnected {
		didSet {
			guard state == .connected else {
				return
			}
			
			pendingEntries.forEach {
				subject.send($0)
			}
			pendingEntries = []
		}
	}
	private var pendingEntries = [Entry]()
	
	deinit {
		print("deninit")
	}
	
	init() {
		let url = URL(string: "ws://65.130.69.120:443")!
		var request = URLRequest(url: url)
		request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		self.connection = WebSocket(request: request)
		
		queue = DispatchQueue(label: "com.duct-ape-productions.LogModel.SocketBacker.workerQueue", qos: .userInitiated, target: .global(qos: .background))
		
		connection.onEvent = { event in
			print("Received event:", event)
			switch event {
			case .connected(_):
				self.state = .connected
			case .disconnected(_, _):
				self.state = .notConnected
			default:
				return
			}
		}
		
		let encoder = JSONEncoder()
		
		subject
			.collect(.byTime(DispatchQueue.global(qos: .background), 0.1))
			.encode(encoder: encoder)
			.sink { (completion) in
				switch completion {
				case .failure(let error):
					assertionFailure(String(describing: error))
				case .finished:
					print("done")
				}
			} receiveValue: { [connection] (data) in
				connection.write(data: data)
			}
			.store(in: &tokens)
	}
	
	
	func log(_ entry: Entry) {
		print("logging entry")
		
		switch state {
		case .connected:
			subject.send(entry)
			
		case .notConnected:
			state = .connecting
			connection.connect()
			fallthrough
			
		case .connecting:
			// stack up entries until we're connected
			pendingEntries.append(entry)
		}
	}
}
