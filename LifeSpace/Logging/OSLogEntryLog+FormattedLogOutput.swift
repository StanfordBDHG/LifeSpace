//
//  OSLogEntryLog+FormattedLogOutput.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 11/9/24.
//

import OSLog


extension Array where Element == OSLogEntryLog {
    func formattedLogOutput() -> String {
        self.map { entry in
            let timestamp = entry.date.formatted()
            let level = entry.level.rawValue
            let category = entry.category
            let message = entry.composedMessage
            
            return "[\(timestamp)] [\(category)] [\(level)]: \(message)"
        }
        .joined(separator: "\n")
    }
}
