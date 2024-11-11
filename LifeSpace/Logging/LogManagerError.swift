//
//  LogManagerError.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 11/11/24.
//


enum LogManagerError: Error {
    /// Throw when the log store is invalid
    case invalidLogStore
    /// Throw when the bundle identifier is invalid
    case invalidBundleIdentifier
}

extension LogManagerError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .invalidLogStore:
            return "The OSLogStore is invalid."
        case .invalidBundleIdentifier:
            return "The bundle identifier is invalid."
        }
    }
}
