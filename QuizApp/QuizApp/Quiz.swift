//
//  Quiz.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 30/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources

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

struct Quiz: Codable {
    var category: String
    var description: String
    var id: Int
    var image:String
    var level: Int
    var questions: [Question]
    var title: String
    
    func reportScore(time: Int, numberCorrect: Int) {
        let token = UserDefaults.standard.value(forKey: "token") as! [String : Any]
        let url = URL(string: "https://iosquiz.herokuapp.com/api/result")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: String] = [
            "quiz_id": String(id),
            "user_id": String(token["user_id"] as! Int),
            "time": String(time),
            "no_of_correct": String(numberCorrect)
        ]
        request.httpBody = parameters.percentEncoded()
        
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
                print("SUCCESS: \(responseString)")
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
