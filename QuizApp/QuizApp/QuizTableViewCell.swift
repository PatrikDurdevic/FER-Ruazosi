//
//  QuizTableViewCell.swift
//  QuizApp
//
//  Created by Tea Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit
import RxSwift

class QuizTableViewCell: UITableViewCell {

    @IBOutlet weak var quizImageView: UIImageView!
    @IBOutlet weak var quizTitleLabel: UILabel!
    @IBOutlet weak var difficultyBar: UIProgressView!
    @IBOutlet weak var quizDescriptionLabel: UILabel!
    private var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureWithQuiz(quiz: Quiz) {
        quizTitleLabel.text = quiz.title
        quizDescriptionLabel.text = quiz.description
        difficultyBar.progress = ((Float(quiz.level) - 1) / 2) * 0.8 + 0.1
        
        URLSession.shared.rx
            .response(request: URLRequest(url: URL(string: quiz.image)!))
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { response, data in
            DispatchQueue.main.async {
                self.quizImageView.image = UIImage(data: data)
            }
        }).disposed(by: disposeBag)
    }

}
