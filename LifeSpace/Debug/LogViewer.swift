//
//  LogShareView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 11/8/24.
//

import OSLog
import Spezi
import SwiftUI


struct LogViewer: View {
    @Environment(LogManager.self) var manager
    
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var selectedLogType: LogType = .all
    @State private var logs: [OSLogEntryLog] = []
    @State private var isLoading = false
    @State private var queryTask: Task<Void, Never>?
    
    var body: some View {
        VStack {
            VStack {
                DatePicker("FROM", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("TO", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                HStack {
                    Text("LOG_TYPE")
                    Spacer()
                    Picker("LOG_TYPE", selection: $selectedLogType) {
                        ForEach(LogType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                }
            }
            .padding()
            
            if isLoading {
                Spacer()
                ProgressView("LOADING_LOGS")
                    .padding()
                Spacer()
            } else {
                if !logs.isEmpty {
                    List(logs, id: \.self) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.date.formatted())
                            Text("Category: \(entry.category)")
                            Text(entry.composedMessage)
                        }
                    }
                } else {
                    ContentUnavailableView("NO_LOGS_AVAILABLE", systemImage: "magnifyingglass")
                }
            }
            
            Spacer()
        }
        .navigationTitle("LOG_VIEWER")
        .onAppear {
            queryLogs()
        }
        .onChange(of: startDate) {
            queryLogs()
        }
        .onChange(of: endDate) {
            queryLogs()
        }
        .onChange(of: selectedLogType) {
            queryLogs()
        }
        .toolbar {
            if !logs.isEmpty {
                ShareLink(
                    item: logs.combinedLogString(),
                    preview: SharePreview(
                        "LOGS",
                        image: Image(systemName: "doc.text") // swiftlint:disable:this accessibility_label_for_image
                    )
                ) {
                    Image(systemName: "square.and.arrow.up") // swiftlint:disable:this accessibility_label_for_image
                }
            }
        }
    }
    
    private func queryLogs() {
        /// Cancel any existing query task
        queryTask?.cancel()
        
        /// Set loading state
        isLoading = true
        
        /// Create a new query task and store it
        queryTask = Task(priority: .userInitiated) { [manager, startDate, endDate, selectedLogType] in
            /// Run the query
            let result = await manager.query(startDate: startDate, endDate: endDate, logType: selectedLogType.osLogLevel)
            
            /// Check to make sure the task isn't cancelled before updating UI
            guard !Task.isCancelled else {
                return
            }
            
            /// Update the UI
            await MainActor.run {
                logs = result
                isLoading = false
            }
        }
    }
}

extension Array where Element == OSLogEntryLog {
    func combinedLogString() -> String {
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
