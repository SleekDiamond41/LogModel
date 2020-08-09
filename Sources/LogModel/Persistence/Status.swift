//
//  Status.swift
//  
//
//  Created by Michael Arrington on 8/8/20.
//

import SQLite3

enum Status {
	
	case ok
	case row
	case done
	case error
	
	init(_ rawValue: Int32) {
		switch rawValue {
		case SQLITE_OK:
			self = .ok
		case SQLITE_ROW:
			self = .row
		case SQLITE_DONE:
			self = .done
		case SQLITE_ERROR:
			self = .error
		default:
			preconditionFailure("unknown value")
		}
	}
}
