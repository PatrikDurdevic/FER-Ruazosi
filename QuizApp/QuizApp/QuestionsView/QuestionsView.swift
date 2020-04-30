//
//  QuestionsView.swift
//  QuizApp
//
//  Created by Tea Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class QuestionsView: UIView, UIScrollViewDelegate {

    @IBOutlet weak var totalQuestionsLabel: UILabel!
    @IBOutlet weak var currentQuestionLabel: UILabel!
    var scrollView: UIScrollView!

    private var questions: [Question]!
    
    func setQuestions(questions: [Question]) {
        self.questions = questions
        
        self.totalQuestionsLabel.text = String(questions.count)
        
        //scrollView = UIScrollView(frame: CGRect(x: 0, y: 200, width: 320, height: frame.height - 200))
        scrollView = UIScrollView(frame: CGRect(x: 0, y: 200, width: 320, height: frame.height - 200))
        print(frame.width)
        
        var index: Int = 0
        for question in questions {
            let questionView: QuestionView = .fromNib()
            questionView.frame.size = scrollView.frame.size
            questionView.setQuestion(question: question)
            
            let offset = scrollView.frame.width * CGFloat(index)
            questionView.frame.origin.x += 320 * CGFloat(index)
            
            scrollView.addSubview(questionView)
            index += 1
        }
        scrollView.isUserInteractionEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.delegate = self
        addSubview(scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
