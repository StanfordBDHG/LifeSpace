//
//  LogStore.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 11/8/24.
//

import Foundation
import OSLog
import Spezi
import SwiftUI

actor LogManager: Module, DefaultInitializable, EnvironmentAccessible {
    @Application(\.logger) private var logger
    
    func query(
        startDate: Date? = nil,
        endDate: Date? = nil,
        logType: OSLogEntryLog.Level? = nil
    ) -> String {
        do {
            let store = try OSLogStore(scope: .currentProcessIdentifier)
            let position: OSLogPosition
            if let startDate = startDate {
                position = store.position(date: startDate)
            } else {
                position = store.position(timeIntervalSinceLatestBoot: 1)
            }
            
            let logs = try store.getEntries(at: position).compactMap { $0 as? OSLogEntryLog }
            
            return logs
                .filter { logEntry in
                    /// Filter by subsystem
                    guard logEntry.subsystem == Bundle.main.bundleIdentifier else {
                        return false
                    }
                    
                    /// Filter by log type if specified
                    if let logType, logEntry.level != logType {
                        return false
                    }
                    
                    /// Filter by date range if specified
                    if let startDate, logEntry.date < startDate {
                        return false
                    }
                    
                    if let endDate, logEntry.date > endDate {
                        return false
                    }
                    
                    return true
                }
                .map { "[\($0.date.formatted())] [\($0.category)] \($0.composedMessage)" }
                .joined(separator: "\n")
        } catch {
            logger.warning("\(error.localizedDescription, privacy: .public)")
            return ""
        }
    }
}
