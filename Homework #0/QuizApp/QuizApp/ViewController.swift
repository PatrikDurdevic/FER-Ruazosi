//
//  ViewController.swift
//  QuizApp
//
//  Created by Tea Durdevic on 10/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func clearAll(_ sender: Any) {
        print("\((sender as AnyObject).currentTitle ?? " ") button tap!")
        usernameField.text = ""
        passwordField.text = ""
    }
    
}

