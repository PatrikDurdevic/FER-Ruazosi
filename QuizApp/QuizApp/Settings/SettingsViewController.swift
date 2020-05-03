//
//  SettingsViewController.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 03/05/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameLabel.text = UserDefaults.standard.string(forKey: "username")
        addMotionToBackground(backgroundImage: backgroundImage)
    }

    @IBAction func logOut(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.synchronize()
        
        parent?.dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
