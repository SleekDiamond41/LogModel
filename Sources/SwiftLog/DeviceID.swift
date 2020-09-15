//
//  DeviceID.swift
//  
//
//  Created by Michael Arrington on 9/10/20.
//

import Foundation


class DeviceID {
	private var _value: UUID?
	var value: UUID {
		if let value = _value {
			return value
		}
		
		return createNew()
	}
	
	let dir: URL
	var url: URL {
		dir
			.appendingPathComponent("DeviceID")
			.appendingPathExtension("uuid")
	}
	
	init(dir: URL) {
		self.dir = dir
	}
	
	private func createDirectory() {
		do {
			try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true, attributes: nil)
			
		} catch {
			print(error.localizedDescription)
		}
	}
	
	private func createNew() -> UUID {
		let value = UUID()
		
		createDirectory()
		
		guard let data = value.uuidString.data(using: .utf8) else {
			preconditionFailure("failed to encode a UUID using 'utf8' encoding")
		}
		
		do {
			try data.write(to: url, options: .atomic)
		} catch {
			preconditionFailure(error.localizedDescription)
		}
		
		return value
	}
	
	private func deleteData() {
		do {
			try FileManager.default.removeItem(at: url)
		} catch {
			print(error.localizedDescription)
		}
	}
}
