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
        startDate: Date,
        endDate: Date? = nil,
        logLevel: OSLogEntryLog.Level? = nil
    ) throws -> [OSLogEntryLog] {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let position = store.position(date: startDate)
        
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
            return []
        }
        
        let predicate = NSPredicate(format: "subsystem == %@", bundleIdentifier)
        
        let logs = try store.getEntries(at: position, matching: predicate)
            .reversed()
            .compactMap { $0 as? OSLogEntryLog }
        
        return logs
            .filter { logEntry in
                /// Filter by log type if specified
                if let logLevel, logEntry.level != logLevel {
                    return false
                }
                
                /// Filter by end date if specified
                if let endDate, logEntry.date > endDate {
                    return false
                }
                
                return true
            }
    }
}
