//
//  LogType.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 11/8/24.
//

import OSLog


enum LogType: String, CaseIterable, Identifiable {
    case all = "All"
    case info = "Info"
    case debug = "Debug"
    case error = "Error"
    case fault = "Fault"
    
    var id: String { self.rawValue }
    
    var osLogLevel: OSLogEntryLog.Level? {
        switch self {
        case .all:
            return nil
        case .info:
            return .info
        case .debug:
            return .debug
        case .error:
            return .error
        case .fault:
            return .fault
        }
    }
}
