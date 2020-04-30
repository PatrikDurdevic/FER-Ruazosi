//
//  QuizTaskViewController.swift
//  QuizApp
//
//  Created by Tea Durdevic on 30/04/2020.
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
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { response, data in
            DispatchQueue.main.async {
                self.bgImage.image = UIImage(data: data)
            }
        }).disposed(by: disposeBag)
        addMotionToBackground()
    }
    
    func addMotionToBackground() {
        let min = CGFloat(-30)
        let max = CGFloat(30)
              
        let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = min
        xMotion.maximumRelativeValue = max
              
        let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = min
        yMotion.maximumRelativeValue = max
              
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [xMotion,yMotion]

        bgImage.addMotionEffect(motionEffectGroup)
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
