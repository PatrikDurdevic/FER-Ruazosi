//
//  QuestionView.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class QuestionView: UIView {

    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var questionLabel: UILabel!
    private var question: Question!
    private var submitted = false
    
    func setQuestion(question: Question) {
        self.question = question
        
        questionLabel.text = question.question
        for button in answerButtons {
            button.setTitle(question.answers[button.tag], for: .normal)
        }
    }
    
    @IBAction func submitAnswer(_ sender: Any) {
        if submitted {
            return
        }
        submitted = true
        
        let button = sender as! UIButton
        UIView.transition(with: button,
        duration: 0.5,
        options: .transitionCrossDissolve,
        animations: {
            if button.tag == self.question.correct_answer {
                button.backgroundColor = .green
            } else {
                button.backgroundColor = .red
            }
        },
        completion: { value in
            (self.superview?.superview as? QuestionsView)?.nextQuestion()
            (self.superview?.superview as? QuestionsView)?.numberOfCorrect += 1
        })
    }
    
}
