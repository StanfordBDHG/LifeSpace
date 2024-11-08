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
    @State private var logs = ""
    @State private var isLoading = false
    @State private var queryTask: Task<Void, Never>?
    
    var body: some View {
        VStack {
            /// Date range selection
            VStack {
                DatePicker("FROM", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                DatePicker("TO", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
            }
            .padding()
            
            /// Log type selection
            Picker("LOG_TYPE", selection: $selectedLogType) {
                ForEach(LogType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                if isLoading {
                    ProgressView("LOADING_LOGS")
                        .padding()
                } else {
                    Text(logs)
                        .padding()
                }
            }
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
            if !logs.isEmpty, let fileURL = saveLogsToTextFile(logs) {
                ShareLink(
                    item: fileURL,
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
    
    private func saveLogsToTextFile(_ logs: String) -> URL? {
        let fileName = "Logs.txt"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try logs.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving logs to file: \(error)")
            return nil
        }
    }
}
