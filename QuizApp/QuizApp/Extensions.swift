//
//  Extensions.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 15/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension Dictionary where Key == String {
    func convertToHTTPBody() -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        return Data()
    }
}

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}

extension ViewController {
    static func getApp() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.modalTransitionStyle = .crossDissolve
        tabBarController.modalPresentationStyle = .fullScreen
        
        let quizVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Quiz") as! QuizViewController
        let quizNC = UINavigationController(rootViewController: quizVC)
        quizNC.navigationBar.prefersLargeTitles = true
        //quizNC.navigationBar.tintColor = .white
        quizNC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        quizNC.tabBarItem.title = "Quiz"
        tabBarController.addChild(quizNC)
        
        return tabBarController
    }
}
