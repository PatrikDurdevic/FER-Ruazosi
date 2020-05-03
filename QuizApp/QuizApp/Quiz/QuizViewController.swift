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
    private var quizzes: Quizzes = Quizzes(value: [])
    private var sections: BehaviorRelay<[QuizSection]> = BehaviorRelay(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "PopQuiz"
        
        loadQuizzes()
        initTableView()
        quizzes.value.subscribe(onNext: {
            self.updateQuizzes(quizzes: $0)
        }).disposed(by: disposeBag)
    }
    
    override func viewDidLayoutSubviews() {
        //initBG()
    }
    
    func initBG() {
        if gradientLayer.superlayer != nil {
            gradientLayer.removeFromSuperlayer()
        }

        gradientLayer.setColor(userInterfaceStyle: self.traitCollection.userInterfaceStyle)
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
                DispatchQueue.main.async {
                    self.quizzes.value.accept(quizzes)
                }
            } catch {
                print(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
    
    func updateQuizzes(quizzes: [Quiz]) {
        var uniqueCategories:[String] = []
        for quiz in quizzes {
            if !uniqueCategories.contains(quiz.category) {
                uniqueCategories.append(quiz.category)
            }
        }
        
        var tmpSections: [QuizSection] = []
        for category in uniqueCategories {
            tmpSections.append(QuizSection(header: category, items: quizzes.filter({ $0.category == category })))
        }
        sections.accept(tmpSections)
    }
    
    func initTableView() {
        let dataSource = RxTableViewSectionedReloadDataSource<QuizSection>(
          configureCell: { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as! QuizTableViewCell
            cell.configureWithQuiz(quiz: item)
            cell.selectionStyle = .none
            return cell
        })
        
        dataSource.titleForHeaderInSection = { dataSource, index in
            return dataSource.sectionModels[index].header
        }

        sections
        .bind(to: tableView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        Observable
        .zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Quiz.self))
        .bind { [unowned self] indexPath, quiz in
            self.tableView.deselectRow(at: indexPath, animated: true)
            let quizVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "QuizTask") as! QuizTaskViewController
            quizVC.quiz = quiz
            self.navigationController!.pushViewController(quizVC, animated: true)
        }
        .disposed(by: disposeBag)
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
