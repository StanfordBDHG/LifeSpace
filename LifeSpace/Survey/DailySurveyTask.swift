//
//  DailySurveyTask.swift
//  LifeSpace
//
//  Created by Vishnu Ravi on 4/5/24.
//

import Foundation
import ResearchKit

// swiftlint:disable function_body_length
class DailySurveyTask: ORKOrderedTask {
    convenience init(identifier: String) {
        // Initialize the array to hold the steps of the survey
        var steps = [ORKStep]()
        
        // Question 1: Close friends or family seen today
        // swiftlint:disable legacy_objc_type
        let answerFormat1 = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [
            ORKTextChoice(text: "0", value: 0 as NSNumber),
            ORKTextChoice(text: "1-4", value: 1 as NSNumber),
            ORKTextChoice(text: "5-10", value: 2 as NSNumber),
            ORKTextChoice(text: "10 or more", value: 3 as NSNumber)
        ])
        let question1Step = ORKQuestionStep(
            identifier: "SocialInteractionQuestion",
            title: "Social Interaction",
            question: "How many people did you engage with face to face today?",
            answer: answerFormat1
        )
        steps.append(question1Step)
        
        // Question 2: Time outside house
        let answerFormat2 = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [
            ORKTextChoice(text: "None", value: 0 as NSNumber),
            ORKTextChoice(text: "Less than 1 hour", value: 1 as NSNumber),
            ORKTextChoice(text: "1-4 hours", value: 2 as NSNumber),
            ORKTextChoice(text: "4 or more hours", value: 3 as NSNumber)
        ])
        
        let question2Step = ORKQuestionStep(
            identifier: "LeavingTheHouseQuestion",
            title: "Leaving the House",
            question: "How many hours did you spend out of your house and meaningfully engaged with others?",
            answer: answerFormat2
        )
        steps.append(question2Step)
        
        // Question 3: Happiness
        let answerFormat3 = ORKAnswerFormat.booleanAnswerFormat()
        let question3Step = ORKQuestionStep(
            identifier: "EmotionalWellBeingQuestion",
            title: "Emotional Well-being",
            question: "Consider your day today and evaluate your agreement with the following statement:\n\nI was happy.",
            answer: answerFormat3
        )
        steps.append(question3Step)
        
        // Question 4: Fatigue
        let answerFormat4 = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [
            ORKTextChoice(text: "Not at all", value: 0 as NSNumber),
            ORKTextChoice(text: "A little bit", value: 1 as NSNumber),
            ORKTextChoice(text: "Somewhat", value: 2 as NSNumber),
            ORKTextChoice(text: "Quite a bit", value: 3 as NSNumber),
            ORKTextChoice(text: "Very much", value: 4 as NSNumber)
        ])
        let question4Step = ORKQuestionStep(
            identifier: "PhysicalWellBeingQuestion",
            title: "Physical Well-being",
            question: "Consider your day today and evaluate your agreement with the following statement:\n\nI felt fatigued.",
            answer: answerFormat4
        )
        steps.append(question4Step)
        
        let reviewStep = ORKReviewStep(identifier: "DailySurveyTaskReviewStep")
        reviewStep.title = "Review Answers"
        reviewStep.text = "Tap on a question to change your answer if you need to."
        reviewStep.excludeInstructionSteps = true
        steps.append(reviewStep)
        
        let completionStep = ORKCompletionStep(identifier: "DailySurveyTaskCompletionStep")
        completionStep.title = "Thank you!"
        completionStep.text = "Tap done below to save your survey. Remember to take your survey daily!"
        steps.append(completionStep)
        
        // Initialize the ORKOrderedTask with the steps array
        self.init(identifier: identifier, steps: steps)
    }
}
