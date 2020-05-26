//
//  QuizTableViewCell.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit
import RxSwift

class QuizTableViewCell: UITableViewCell {

    @IBOutlet weak var quizImageView: UIImageView!
    @IBOutlet weak var quizTitleLabel: UILabel!
    
    @IBOutlet var starsImageView: [UIImageView]!
    
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
        for star in starsImageView {
            if star.tag <= quiz.level {
                star.isHidden = false
            } else {
                star.isHidden = true
            }
        }
        
        URLSession.shared.rx
            .response(request: URLRequest(url: URL(string: quiz.image)!))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] response, data in
            guard let self = self else { return }
            self.quizImageView.image = UIImage(data: data)
        }).disposed(by: disposeBag)
    }

}
