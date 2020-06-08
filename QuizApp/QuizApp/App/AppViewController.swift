//
//  AppViewController.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 08/06/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class AppViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .fullScreen
        
        let quizVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Quiz") as! QuizViewController
        let quizNC = UINavigationController(rootViewController: quizVC)
        quizNC.navigationBar.prefersLargeTitles = true
        quizNC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        quizNC.tabBarItem.title = "Quiz"
        addChild(quizNC)
        
        let searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "Search") as! SearchViewController
        let searchNC = UINavigationController(rootViewController: searchVC)
        searchNC.navigationBar.prefersLargeTitles = true
        searchNC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        searchNC.tabBarItem.title = "Search"
        addChild(searchNC)
        
        let settingsVC = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
        settingsVC.tabBarItem = UITabBarItem(tabBarSystemItem: .more, tag: 2)
        settingsVC.tabBarItem.title = "Settings"
        addChild(settingsVC)
    }

}
