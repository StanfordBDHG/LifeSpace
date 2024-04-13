//
// This source file is part of the StrokeCog based on the Stanford Spezi Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziScheduler


/// A `Scheduler` using the ``StrokeCogTaskContext`` to schedule and manage tasks and events in the
/// StrokeCog.
typealias StrokeCogScheduler = Scheduler<StrokeCogTaskContext>


extension StrokeCogScheduler {
    static var socialSupportTask: SpeziScheduler.Task<StrokeCogTaskContext> {
        let dateComponents: DateComponents
        if FeatureFlags.testSchedule {
            // Adds a task at the current time for UI testing if the `--testSchedule` feature flag is set
            dateComponents = DateComponents(
                hour: Calendar.current.component(.hour, from: .now),
                minute: Calendar.current.component(.minute, from: .now)
            )
        } else {
            dateComponents = DateComponents(hour: 19, minute: 0)
        }

        return Task(
            title: String(localized: "TASK_DAILY_SURVEY_TITLE"),
            description: String(localized: "TASK_DAILY_SURVEY_DESCRIPTION"),
            schedule: Schedule(
                start: Calendar.current.startOfDay(for: Date()),
                repetition: .matching(dateComponents),
                end: .numberOfEvents(365)
            ),
            notifications: true,
            context: StrokeCogTaskContext.test("TASK_DAILY_SURVEY_TITLE")
        )
    }

    /// Creates a default instance of the ``StrokeCogScheduler`` by scheduling the tasks listed below.
    convenience init() {
        self.init(tasks: [Self.socialSupportTask])
    }
}
