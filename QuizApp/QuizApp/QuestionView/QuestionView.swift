//
//  QuestionView.swift
//  QuizApp
//
//  Created by Tea Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class QuestionView: UIView {


    @IBOutlet var answerButtons: [UIButton]!
    @IBOutlet weak var questionLabel: UILabel!
    private var question: Question!
    
    func setQuestion(question: Question) {
        self.question = question
        
        questionLabel.text = question.question
        for button in answerButtons {
            button.setTitle(question.answers[button.tag], for: .normal)
        }
    }
    
    @IBAction func submitAnswer(_ sender: Any) {
        let button = sender as! UIButton
        if button.tag == question.correct_answer {
            button.backgroundColor = .green
        } else {
            button.backgroundColor = .red
        }
    }
    
}
