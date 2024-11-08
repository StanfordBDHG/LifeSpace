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
            Task {
                await queryLogs()
            }
        }
        .onChange(of: startDate) {
            Task {
                await queryLogs()
            }
        }
        .onChange(of: endDate) {
            Task {
                await queryLogs()
            }
        }
        .onChange(of: selectedLogType) {
            Task {
                await queryLogs()
            }
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
    
    @MainActor
    private func queryLogs() async {
        isLoading = true
        
        /// This is very slow, so run as a detached task with high priority
        logs = await Task.detached(priority: .userInitiated) { [manager, startDate, endDate, selectedLogType] in
            await manager.query(startDate: startDate, endDate: endDate, logType: selectedLogType.osLogLevel)
        }.value
        
        isLoading = false
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