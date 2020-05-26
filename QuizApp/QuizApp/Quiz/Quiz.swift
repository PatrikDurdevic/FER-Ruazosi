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
    
    static func loadQuizzes() {
        let req = URLRequest(url: URL(string: "https://iosquiz.herokuapp.com/api/quizzes")!)
        let responseJSON = URLSession.shared.rx.json(request: req)
        responseJSON.subscribe(onNext: { json in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: (json as! NSDictionary)["quizzes"]!)
                let quizzes = try JSONDecoder().decode([Quiz].self, from: jsonData)
                DispatchQueue.main.async {
                    Quizzes.shared.value.accept(quizzes)
                }
            } catch {
                print(error.localizedDescription)
            }
        }).disposed(by: disposeBag)
    }
    
    var value: BehaviorRelay<[Quiz]>
    private var disposeBag = DisposeBag()
    
    init(value: [Quiz]) {
        self.value = BehaviorRelay(value: value)
        if value.count == 0 {
            self.load()
        }
        
        self.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { quizzes in
                // There is a better way than just deleting all of the data, but for the small amount of data it's the easiest to implement
                self.deleteAllData("QuizEntity")
                self.deleteAllData("QuestionEntity")
                for q in quizzes {
                    self.save(q: q)
                }
        }).disposed(by: disposeBag)
    }
    
    func deleteAllData(_ entity:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            for object in results {
                guard let objectData = object as? NSManagedObject else {continue}
                managedContext.delete(objectData)
            }
        } catch let error {
            print("Detele all data in \(entity) error :", error)
        }
    }
    
    func load() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<QuizEntity>(entityName: "QuizEntity")
        
        var tmpValue: [Quiz] = []
        do {
            let quizzes = try managedContext.fetch(fetchRequest)
            for quiz in quizzes {
                var questions: [Question] = []
                for question in quiz.questions!.allObjects as! [QuestionEntity] {
                    questions.append(Question(answers: question.answers!, correct_answer: Int(question.correct_answer), id: Int(question.id), question: question.question!))
                }
                let q = Quiz(category: quiz.category!, description: quiz.desc!, id: Int(quiz.id), image: quiz.image!, level: Int(quiz.level), questions: questions, title: quiz.title!)
                
                tmpValue.append(q)
            }
            self.value.accept(tmpValue)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func save(q: Quiz) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "QuizEntity", in: managedContext)!
        
        let quiz = QuizEntity(entity: entity, insertInto: managedContext)
        
        quiz.category = q.category
        quiz.desc = q.description
        quiz.id = Int32(q.id)
        quiz.image = q.image
        quiz.level = Int32(q.level)
        quiz.title = q.title
        
        var questions: [QuestionEntity] = []
        for question in q.questions {
            let qeEntity = NSEntityDescription.entity(forEntityName: "QuestionEntity", in: managedContext)!
            let qe = QuestionEntity(entity: qeEntity, insertInto: managedContext)
            qe.answers = question.answers
            qe.correct_answer = Int32(question.correct_answer)
            qe.id = Int32(question.id)
            qe.question = question.question
            qe.quiz = quiz
            
            questions.append(qe)
        }
        
        quiz.questions = NSSet(array: questions)
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
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
