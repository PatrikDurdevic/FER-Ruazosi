//
//  QuizViewController.swift
//  QuizApp
//
//  Created by Tea Durdevic on 15/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var gradientLayer = CAGradientLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "PopQuiz"
    }
    
    override func viewDidLayoutSubviews() {
        initBG()
    }
    
    func initBG() {
        if gradientLayer.superlayer != nil {
            gradientLayer.removeFromSuperlayer()
        }

        if self.traitCollection.userInterfaceStyle == .dark {
            gradientLayer.colors = [UIColor(rgb: 0x65799B).cgColor, UIColor(rgb: 0x5E2563).cgColor]
        } else {
            gradientLayer.colors = [UIColor(rgb: 0xF54EA2).cgColor, UIColor(rgb: 0xFF7676).cgColor]
        }
        gradientLayer.frame = view.bounds
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)
        tableView.backgroundView = backgroundView
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
