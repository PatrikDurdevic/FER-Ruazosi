//
//  QuizService.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 08/06/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources
import CoreData

class QuizService {
    static var shared = QuizService()
    private var disposeBag = DisposeBag()
    
    init() {
        
    }
    
    func loadQuizzes(toSave: BehaviorRelay<[Quiz]>) {
        let req = URLRequest(url: URL(string: "https://iosquiz.herokuapp.com/api/quizzes")!)
        let responseJSON = URLSession.shared.rx.json(request: req)
        responseJSON.subscribe(onNext: { json in
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: (json as! NSDictionary)["quizzes"]!)
                let quizzes = try JSONDecoder().decode([Quiz].self, from: jsonData)
                DispatchQueue.main.async {
                    toSave.accept(quizzes)
                }
            } catch {
                print(error.localizedDescription)
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
    
    func load(saveTo: BehaviorRelay<[Quiz]>) {
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
            saveTo.accept(tmpValue)
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
