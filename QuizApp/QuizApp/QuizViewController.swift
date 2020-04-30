//
//  QuizViewController.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 15/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class QuizViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var gradientLayer = CAGradientLayer()
    private var disposeBag = DisposeBag()
    private var quizzes: [Quiz] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "PopQuiz"
        
        loadQuizzes()
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
    
    func loadQuizzes() {
        let req = URLRequest(url: URL(string: "https://iosquiz.herokuapp.com/api/quizzes")!)
        let responseJSON = URLSession.shared.rx.json(request: req)
        responseJSON.subscribe(onNext: { json in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: (json as! NSDictionary)["quizzes"]!)
                let quizzes = try JSONDecoder().decode([Quiz].self, from: jsonData)
                self.quizzes = quizzes
                DispatchQueue.main.async {
                    self.initTableView()
                }
            } catch {
                print(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
    
    func initTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<QuizSection>(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as! QuizTableViewCell
            cell.configureWithQuiz(quiz: item)
            return cell
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }
        
        var uniqueCategories:[String] = []
        for quiz in quizzes {
            if !uniqueCategories.contains(quiz.category) {
                uniqueCategories.append(quiz.category)
            }
        }
        
        var sections:[QuizSection] = []
        for category in uniqueCategories {
            sections.append(QuizSection(header: category, items: quizzes.filter({ $0.category == category })))
        }

        Observable.just(sections)
          .bind(to: tableView.rx.items(dataSource: dataSource))
          .disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Quiz.self).subscribe(onNext: { quiz in
            print(quiz.title)
        }).disposed(by: disposeBag)
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
