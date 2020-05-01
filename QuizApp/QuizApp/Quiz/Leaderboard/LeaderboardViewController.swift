//
//  LeaderboardViewController.swift
//  QuizApp
//
//  Created by Tea Durdevic on 01/05/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class LeaderboardViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var quiz: Quiz!
    private var disposeBag = DisposeBag()
    private var scores: BehaviorRelay<[Score]> = BehaviorRelay(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Leaderboard"
        
        loadLeaderboard()
    }
    

    func loadLeaderboard() {
        var request = URLRequest(url: URL(string: "https://iosquiz.herokuapp.com/api/score?quiz_id="+String(quiz.id))!)
        
        let token = UserDefaults.standard.value(forKey: "token") as! [String : Any]
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token["token"] as! String, forHTTPHeaderField: "Authorization")
        
        print(request)
        
        let responseJSON = URLSession.shared.rx.json(request: request)
        responseJSON.subscribe(onNext: { json in
            do {
                print(json)
                let jsonData = try JSONSerialization.data(withJSONObject: json)
                let scores = try JSONDecoder().decode([Score].self, from: jsonData)
                self.scores.accept(scores)
                DispatchQueue.main.async {
                    self.initTableView()
                }
            } catch {
                print(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
    
    func initTableView() {
        scores.bind(to: tableView.rx.items(cellIdentifier: "PlayerCell",
                                           cellType: LeaderboardTableViewCell.self)) { row, score, cell in
                                            cell.configureForScore(score: score)
        }.disposed(by: disposeBag)
    }

}
