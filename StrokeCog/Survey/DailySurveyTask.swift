//
//  DailySurveyTask.swift
//  StrokeCog
//
//  Created by Vishnu Ravi on 4/5/24.
//

import Foundation
import ResearchKit

class DailySurveyTask: ORKOrderedTask {
    convenience init(identifier: String) {
        // Initialize the array to hold the steps of the survey
        var steps = [ORKStep]()
        
        // Question 1: Close friends or family seen today
        let answerFormat1 = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: [
            ORKTextChoice(text: "0", value: 0 as NSNumber),
            ORKTextChoice(text: "1-4", value: 1 as NSNumber),
            ORKTextChoice(text: "5-10", value: 2 as NSNumber),
            ORKTextChoice(text: "10 or more", value: 3 as NSNumber)
        ])
        let question1Step = ORKQuestionStep(
            identifier: "Question1",
            title: "Social Interaction",
            question: "How many close friends or family did you see today face to face?",
            answer: answerFormat1
        )
        steps.append(question1Step)
        
        // Question 2: Times left house
        let answerFormat2 = ORKAnswerFormat.integerAnswerFormat(withUnit: nil)
        answerFormat2.minimum = 0
        let question2Step = ORKQuestionStep(
            identifier: "Question2",
            title: "Leaving the House",
            question: "How many times today did you leave your house and engage meaningfully with others?",
            answer: answerFormat2
        )
        steps.append(question2Step)
        
        // Question 3: Happiness
        let answerFormat3 = ORKAnswerFormat.booleanAnswerFormat()
        let question3Step = ORKQuestionStep(
            identifier: "Question3",
            title: "Emotional Well-being",
            question: "I was happy",
            answer: answerFormat3
        )
        steps.append(question3Step)
        
        // Question 4: Fatigue
        let answerFormat4 = ORKAnswerFormat.scale(
            withMaximumValue: 4,
            minimumValue: 0,
            defaultValue: 0,
            step: 1,
            vertical: false,
            maximumValueDescription: "Very much",
            minimumValueDescription: "Not at all"
        )
        let question4Step = ORKQuestionStep(
            identifier: "Question4",
            title: "Physical Well-being",
            question: "I feel fatigued",
            answer: answerFormat4
        )
        steps.append(question4Step)
        
        // Initialize the ORKOrderedTask with the steps array
        self.init(identifier: identifier, steps: steps)
    }
}
