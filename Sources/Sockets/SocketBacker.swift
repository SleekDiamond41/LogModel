//
//  SocketBacker.swift
//  
//
//  Created by Michael Arrington on 8/24/20.
//

import Foundation
import Combine
import Starscream
import Models
import Protocols


@available(OSX 10.15, iOS 13.0, *)
public class Socket {
	
	let connection: WebSocket
	
	public enum State {
		case connected
		case notConnected
		case connecting
	}
	
	
	/// Serial queue, avoid race conditions
	let queue: DispatchQueue
	
	private let subject = PassthroughSubject<EntryData, Never>()
	
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
	private var pendingEntries = [EntryData]()
	
	deinit {
		print("deinit")
	}
	
	public init(url: URL) {
		var request = URLRequest(url: url)
		request.timeoutInterval = 15
		request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		self.connection = WebSocket(request: request)
		self.connection.connect()
		
		queue = DispatchQueue(label: "com.duct-ape-productions.SwiftLog.SocketBacker.workerQueue", qos: .userInitiated, target: .global(qos: .background))
		
		connection.onEvent = { event in
			switch event {
			case .connected(_):
				self.state = .connected
			case .disconnected(_, _):
				self.state = .notConnected
			default:
				print(event)
				return
			}
		}
		
		let coder = EntryCoder(version: (0, 0, 0))
		
		subject
			.receive(on: queue)
			.map { $0.makeEntry() }
			.collect(.byTime(DispatchQueue.global(qos: .background), 0.1))
			.map { coder.encode($0) }
			.sink(receiveCompletion: { (completion) in
				switch completion {
				case .failure(let error):
					assertionFailure(String(describing: error))
				case .finished:
					print("done")
				}
			}, receiveValue: { [connection] (data) in
				connection.write(data: data)
			})
			.store(in: &tokens)
	}
	
	
	public func log(_ data: EntryData) {
		
		switch state {
		case .connected:
			subject.send(data)
			
		case .notConnected:
			state = .connecting
			connection.connect()
			fallthrough
			
		case .connecting:
			// stack up entries until we're connected
			pendingEntries.append(data)
		}
	}
	
	func sendSimple(_ s: String) {
		connection.write(string: s)
	}
}
