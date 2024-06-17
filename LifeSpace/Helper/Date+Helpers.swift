//
//  Date+Helpers.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/2/24.

import Foundation

extension Date {
    /// Returns the start of the day for the Date
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}
