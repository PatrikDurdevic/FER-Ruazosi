//
//  QuizTaskViewController.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class QuizTaskViewController: UIViewController {

    var quiz: Quiz!
    @IBOutlet weak var quizTitleLabel: UILabel!
    @IBOutlet weak var bgImage: UIImageView!
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        quizTitleLabel.text = quiz.title
        URLSession.shared.rx
            .response(request: URLRequest(url: URL(string: quiz.image)!))
            .observeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] response, data in
                guard let self = self else { return }
                UIView.transition(with: self.bgImage,
                duration: 0.5,
                options: .transitionCrossDissolve,
                animations: { self.bgImage.image = UIImage(data: data) },
                completion: nil)
        }).disposed(by: disposeBag)

        addMotionToBackground(backgroundImage: bgImage)
    }

    @IBAction func startQuiz(_ sender: Any) {
        let questionsView: QuestionsView = .fromNib()
        questionsView.frame = view.bounds
        
        questionsView.setQuestions(questions: quiz.questions, quiz: quiz)
        
        let currentWindow: UIWindow? = UIApplication.shared.keyWindow
        currentWindow?.addSubview(questionsView)
    }
    
    @IBAction func showLeaderboard(_ sender: Any) {
        let leaderboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LeaderboardVC") as! LeaderboardViewController
        leaderboardVC.quiz = quiz
        self.navigationController!.pushViewController(leaderboardVC, animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
