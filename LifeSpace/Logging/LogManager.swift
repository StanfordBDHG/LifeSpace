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

class LogManager {
    private let store: OSLogStore?
    
    init() {
        self.store = try? OSLogStore(scope: .currentProcessIdentifier)
    }
    
    func query(
        startDate: Date,
        endDate: Date? = nil,
        logLevel: OSLogEntryLog.Level? = nil
    ) throws -> [OSLogEntryLog] {
        guard let store else {
            return []
        }
        
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
