//
//  QuestionsView.swift
//  QuizApp
//
//  Created by Tea Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class QuestionsView: UIView {

    @IBOutlet weak var totalQuestionsLabel: UILabel!
    @IBOutlet weak var currentQuestionLabel: UILabel!
    var scrollView: UIScrollView!

    private var questions: [Question]!
    private var quiz: Quiz!
    
    var currentQuestion = 0
    var numberOfCorrect = 0
    var startTime: CFAbsoluteTime!
    
    func setQuestions(questions: [Question], quiz: Quiz) {
        self.questions = questions
        self.quiz = quiz
        
        self.totalQuestionsLabel.text = String(questions.count)
        
        startTime = CFAbsoluteTimeGetCurrent()
        
        //scrollView = UIScrollView(frame: CGRect(x: 0, y: 200, width: 320, height: frame.height - 200))
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 100, width: frame.width, height: frame.height - 100))
        //scrollView.translatesAutoresizingMaskIntoConstraints = true
        print(frame.width)
        
        var index: Int = 0
        for question in questions {
            let questionView: QuestionView = .fromNib()
            questionView.frame.size = scrollView.frame.size
            questionView.setQuestion(question: question)
            
            questionView.frame.origin.x += frame.width * CGFloat(index)
            
            scrollView.addSubview(questionView)
            index += 1
        }
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        scrollView.isScrollEnabled = false
        scrollView.contentSize = CGSize(width: CGFloat(frame.size.width * CGFloat(questions.count)), height: scrollView.frame.height)
        addSubview(scrollView)
    }
    
    func nextQuestion() {
        currentQuestion += 1
        
        if currentQuestion == questions.count {
            endQuiz()
        }
        
        var offset = scrollView.contentOffset
        offset.x += scrollView.frame.width
        scrollView.setContentOffset(offset, animated: true)
        
        DispatchQueue.main.async {
            UIView.transition(with: self.currentQuestionLabel,
            duration: 0.5,
            options: .transitionCrossDissolve,
            animations: { self.currentQuestionLabel.text = "\(self.currentQuestion + 1)" },
            completion: nil)
        }
    }
    
    func endQuiz() {
        quiz.reportScore(time: CFAbsoluteTimeGetCurrent() - startTime, numberCorrect: numberOfCorrect)
        self.removeFromSuperview()
    }
}
