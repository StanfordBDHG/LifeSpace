//
//  LogShareView.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 11/8/24.
//

import OSLog
import Spezi
import SwiftUI

/// A SwiftUI view that displays logs retrieved from `LogManager`.
/// Allows users to filter logs by date range and log level, view them in a list, and share the output.
struct LogViewer: View {
    private let manager = LogManager()
    
    @State private var startDate: Date = Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    @State private var endDate = Date()
    @State private var selectedLogLevel: LogLevel = .all
    @State private var logs: [OSLogEntryLog] = []
    @State private var isLoading = false
    @State private var queryTask: Task<Void, Never>?
    @State private var showingAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack {
            VStack {
                DatePicker("FROM", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("TO", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                HStack {
                    Text("LOG_TYPE")
                    Spacer()
                    Picker("LOG_TYPE", selection: $selectedLogLevel) {
                        ForEach(LogLevel.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
            }
            .padding()
            
            if isLoading {
                Spacer()
                ProgressView("LOADING_LOGS").padding()
                Spacer()
            } else {
                LogsListView(logs: logs)
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
        .onChange(of: selectedLogLevel) {
            queryLogs()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: queryLogs) {
                    Image(systemName: "arrow.clockwise") // swiftlint:disable:this accessibility_label_for_image
                }
                if !logs.isEmpty {
                    ShareLink(
                        item: logs.formattedLogOutput(),
                        preview: SharePreview(
                            "LOGS_SHARE_PREVIEW_TITLE",
                            image: Image(systemName: "doc.text") // swiftlint:disable:this accessibility_label_for_image
                        )
                    ) {
                        Image(systemName: "square.and.arrow.up") // swiftlint:disable:this accessibility_label_for_image
                    }
                }
            }
        }
        .alert(errorMessage, isPresented: $showingAlert) {
                   Button("OK", role: .cancel) { }
        }
    }
    
    private func queryLogs() {
        /// Cancel any existing query task
        queryTask?.cancel()
        
        /// Set loading state
        isLoading = true
        
        /// Create a new query task and store it
        queryTask = Task(priority: .userInitiated) { [manager, startDate, endDate, selectedLogLevel] in
            do {
                /// Run the query
                let result = try manager.query(
                    startDate: startDate,
                    endDate: endDate,
                    logLevel: selectedLogLevel.osLogLevel
                )
                
                /// Check to make sure the task isn't cancelled before updating UI
                guard !Task.isCancelled else {
                    return
                }
                
                /// Update the UI
                await MainActor.run {
                    logs = result
                    isLoading = false
                }
            } catch {
                displayError(message: error.localizedDescription)
            }
        }
    }
    
    /// Displays an error message in an alert if a query fails.
    ///
    /// - Parameter message: The error message to display.
    private func displayError(message: String) {
        errorMessage = message
        showingAlert = true
    }
}
