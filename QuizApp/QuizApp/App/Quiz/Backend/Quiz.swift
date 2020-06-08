//
//  Quiz.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import CoreData

struct QuizSection {
  var header: String
  var items: [Item]
}

extension QuizSection: SectionModelType {
  typealias Item = Quiz

   init(original: QuizSection, items: [Quiz]) {
    self = original
    self.items = items
  }
}

/*
 QuizService za fetchanje vraća observale [Quiz]
 Receive on umjesto DispatchQueue.main.async
*/

class Quizzes {
    static var shared = Quizzes(value: [])
    static var disposeBag = DisposeBag()
    
    var value: BehaviorRelay<[Quiz]>
    private var disposeBag = DisposeBag()
    private var quizService: QuizService!
    
    init(value: [Quiz]) {
        self.value = BehaviorRelay(value: value)
        self.quizService = QuizService()
        
        if value.count == 0 {
            quizService.load(saveTo: self.value)
        }
        
        self.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] quizzes in
                guard let self = self else { return }
                self.quizService.deleteAllData("QuizEntity")
                self.quizService.deleteAllData("QuestionEntity")
                for q in quizzes {
                    self.quizService.save(q: q)
                }
        }).disposed(by: disposeBag)
        
        self.quizService.loadQuizzes(toSave: self.value)
    }
}

struct Quiz: Codable {
    var category: String
    var description: String
    var id: Int
    var image: String
    var level: Int
    var questions: [Question]
    var title: String
    
    func reportScore(time: Double, numberCorrect: Int) {
        let token = UserDefaults.standard.value(forKey: "token") as! [String : Any]
        
        var request = URLRequest(url: URL(string: "https://iosquiz.herokuapp.com/api/result")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token["token"] as! String, forHTTPHeaderField: "Authorization")
        print(token["token"] as! String)
        let parameters: [String: Any] = [
            "quiz_id": id,
            "user_id": (token["user_id"] as! Int),
            "time": time,
            "no_of_correct": numberCorrect
        ]
        request.httpBody = parameters.convertToHTTPBody()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print(response.statusCode)
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                print("Score successfully reported: \(responseString)")
            }
        }

        task.resume()
    }
}

struct Question: Codable {
    var answers: [String]
    var correct_answer: Int
    var id: Int
    var question: String
}

struct Score: Codable {
    var score: String
    var username: String
}
