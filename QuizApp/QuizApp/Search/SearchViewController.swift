//
//  SearchViewController.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 03/05/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class SearchViewController: UIViewController, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    private var searchBar: UISearchBar!
    private var disposeBag = DisposeBag()
    
    private var sections: BehaviorRelay<[QuizSection]> = BehaviorRelay(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "PopQuiz"

        searchBar = UISearchBar()
        searchBar.showsCancelButton = true
        searchBar.rx.cancelButtonClicked.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.searchBar.text = ""
            self.searchBar.endEditing(true)
        }).disposed(by: disposeBag)
        searchBar.rx.searchButtonClicked.subscribe(onNext: { [weak self] in
            guard let self = self else { return }
            self.searchBar.endEditing(true)
        }).disposed(by: disposeBag)
        searchBar.placeholder = "Search quizzes..."
        searchBar.rx.text.orEmpty.throttle(0.5, scheduler: MainScheduler.instance).distinctUntilChanged().subscribe(onNext: {
            self.updateQuizzes(quizzess: Quizzes.shared.value.value, search: $0)
        }).disposed(by: disposeBag)
        self.navigationItem.titleView = searchBar
        
        initTableView()
        Quizzes.shared.value.subscribe(onNext: { [weak self] in
        guard let self = self else { return }
            self.updateQuizzes(quizzess: $0, search: "")
        }).disposed(by: disposeBag)
    }
    
    func updateQuizzes(quizzess: [Quiz], search: String) {
        var quizzes = quizzess
        if search.count > 0 {
            quizzes = quizzes.filter { $0.title.contains(search) }
        }
        
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

}
