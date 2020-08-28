//
//  MessageTests.swift
//  
//
//  Created by Michael Arrington on 8/26/20.
//

import XCTest
@testable import LogModel

class MessageTests: XCTestCase {
	
	func testBasic() {
		let message: Message = "Hello, World"
		
		XCTAssertEqual(message.string(for: .low),	"Hello, World")
		XCTAssertEqual(message.string(for: .high),	"Hello, World")
	}
	
	func testString() {
		let person = "Bob"
		let message: Message = "Hello, \(person)"
		
		XCTAssertEqual(message.string(for: .low),	"Hello, 'Bob'")
		XCTAssertEqual(message.string(for: .high),	"Hello, '***'")
		
		let hashedMessage: Message = "Hello, \(person, privacy: .hashed)"
		
		XCTAssertEqual(hashedMessage.string(for: .low),		"Hello, 'Bob'")
		XCTAssertEqual(hashedMessage.string(for: .high),	"Hello, 'cd9fb1e148ccd8442e5aa74904cc73bf6fb54d1d54d333bd596aa9bb4bb4e961'")
		
		let publicMessage: Message = "Hello, \(person, privacy: .public)"
		
		XCTAssertEqual(publicMessage.string(for: .low),		"Hello, 'Bob'")
		XCTAssertEqual(publicMessage.string(for: .high),	"Hello, 'Bob'")
	}
	
	func testInteger() {
		let num = 235790
		let message: Message = "received value \(num)"
		
		XCTAssertEqual(message.string(for: .low),	"received value '235790'")
		XCTAssertEqual(message.string(for: .high),	"received value '******'")
		
		
		let hashedMessage: Message = "received value \(num, privacy: .hashed)"
		
		XCTAssertEqual(hashedMessage.string(for: .low),		"received value '235790'")
		XCTAssertEqual(hashedMessage.string(for: .high),	"received value 'b0910f926f1d6f407726e00e15ef206276a0066a10bc4d6aac4629bfda8e6815'")
		
		
		let publicMessage: Message = "received value \(num, privacy: .public)"
		
		XCTAssertEqual(publicMessage.string(for: .low),		"received value '235790'")
		XCTAssertEqual(publicMessage.string(for: .high),	"received value '235790'")
	}
	
	func testDouble() {
		let num: Double = 237821.5328
		let message: Message = "received value \(num)"
		
		XCTAssertEqual(message.string(for: .low),	"received value '237821.533'")
		XCTAssertEqual(message.string(for: .high),	"received value '******.***'")
		
		
		let hashedMessage: Message = "received value \(num, decimals: 2, privacy: .hashed)"
		
		XCTAssertEqual(hashedMessage.string(for: .low),		"received value '237821.53'")
		XCTAssertEqual(hashedMessage.string(for: .high),	"received value '539f513371927b595c5d84070b1709bd3a37caa5dbdf05f1d9c192d23bf9d5ac'")
		
		
		let publicMessage: Message = "received value \(num, decimals: 6, privacy: .public)"
		
		XCTAssertEqual(publicMessage.string(for: .low),		"received value '237821.532800'")
		XCTAssertEqual(publicMessage.string(for: .high),	"received value '237821.532800'")
	}
	
	func testUUID() {
		let id = UUID(uuidString: "8A12DCEB-C502-4525-AACE-5A48EBB5C699")!
		let message: Message = "Fetching updates for Object \(id)"
		
		XCTAssertEqual(message.string(for: .high),	"Fetching updates for Object '********-****-****-****-************'")
		XCTAssertEqual(message.string(for: .low),	"Fetching updates for Object '8A12DCEB-C502-4525-AACE-5A48EBB5C699'")
		
		
		let hashedMessage: Message = "Fetching updates for Object \(id, privacy: .hashed)"
		
		// yeah, I guess that's the hash value for this UUID
		XCTAssertEqual(hashedMessage.string(for: .high),	"Fetching updates for Object '457748517f2912683969bfd2db5cbbe5e61484c86f6fa301f1c1134f2ae14ad9'")
		XCTAssertEqual(hashedMessage.string(for: .low),		"Fetching updates for Object '8A12DCEB-C502-4525-AACE-5A48EBB5C699'")
		
		
		let publicMessage: Message = "Fetching updates for Object \(id, privacy: .public)"
		
		XCTAssertEqual(publicMessage.string(for: .high),	"Fetching updates for Object '8A12DCEB-C502-4525-AACE-5A48EBB5C699'")
		XCTAssertEqual(publicMessage.string(for: .low),		"Fetching updates for Object '8A12DCEB-C502-4525-AACE-5A48EBB5C699'")
	}
}
