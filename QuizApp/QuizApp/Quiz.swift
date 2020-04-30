//
//  Quiz.swift
//  QuizApp
//
//  Created by Tea Durdevic on 30/04/2020.
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
}

struct Question: Codable {
    var answers: [String]
    var correct_answer: Int
    var id: Int
    var question: String
}
