//
//  ViewController.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 10/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backgroundImage: UIImageView!
    var backgrounds: NSDictionary?
    var bgTimer: Timer?
    
    @IBOutlet weak var usernameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var imageInfoLabel: UILabel!
    
    private var firstTime = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMotionToBackground(backgroundImage: backgroundImage)
        loadBackgrounds()
        bgTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(changeBackgroundImage), userInfo: nil, repeats: true)
        let tapRecognizer = TapGestureRecognizer {
            self.view.endEditing(true)
        }
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        buttonView.alpha = 0
        usernameField.alpha = 0
        passwordField.alpha = 0
        
        usernameField.text = ""
        passwordField.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if firstTime {
            initTextFieldDesign()
            firstTime = false
        }
        
        if let _ = UserDefaults.standard.object(forKey: "token") {
            self.presentQuiz()
        }
        
        
        /*
         Moglo se i sa constraintima, bilo bi ljepše i stabilnije
         */
        buttonView.frame.origin.x -= 200
        usernameField.frame.origin.x -= 200
        passwordField.frame.origin.x -= 200
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.usernameField.alpha = 1
            self.usernameField.frame.origin.x += 200
        })
        UIView.animate(withDuration: 1, delay: 0.25, options: .curveEaseInOut, animations: {
            self.passwordField.alpha = 1
            self.passwordField.frame.origin.x += 200
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut, animations: {
            self.buttonView.alpha = 1
            self.buttonView.frame.origin.x += 200
        }, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        bgTimer?.invalidate()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.usernameTopConstraint.constant = 20
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.usernameTopConstraint.constant = 80
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        attemptSignIn()
        return true
    }
    
    @IBAction func signIn(_ sender: Any) {
        attemptSignIn()
    }
    
    func attemptSignIn() {
        view.endEditing(true)
        UIView.animate(withDuration: 0.5, animations: {
            self.buttonView.alpha = 0
        })
        
        let url = URL(string: "https://iosquiz.herokuapp.com/api/session")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let parameters: [String: String] = [
            "username": usernameField.text!,
            "password": passwordField.text!
        ]
        request.httpBody = parameters.percentEncoded()
        UserDefaults.standard.set(usernameField.text!, forKey: "username")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else {
                print("Wrong credentials")
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Login unsuccessful", message: "The username or password you entered is invalid!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    UIView.animate(withDuration: 0.5, animations: {
                        self.buttonView.alpha = 1
                    })
                }
                return
            }

            if let responseString = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.loginSuccess(token: responseString.convertToDictionary(), tokenString: responseString)
                }
            }
        }

        task.resume()
    }
    
    func loginSuccess(token: [String: Any]?, tokenString: String) {
        UserDefaults.standard.set(token, forKey: "token")
        presentQuiz()
    }
    
    func presentQuiz() {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.usernameField.alpha = 0
            self.usernameField.frame.origin.x += 200
        })
        UIView.animate(withDuration: 1, delay: 0.25, options: .curveEaseInOut, animations: {
            self.passwordField.alpha = 0
            self.passwordField.frame.origin.x += 200
        }, completion: nil)
        UIView.animate(withDuration: 1, delay: 0.5, options: .curveEaseInOut, animations: {
            self.buttonView.alpha = 0
            self.buttonView.frame.origin.x += 200
        }, completion: { (value) in
            self.present(AppViewController(), animated: true, completion: { () in
                self.usernameField.frame.origin.x -= 200
                self.passwordField.frame.origin.x -= 200
                self.buttonView.frame.origin.x -= 200
            })
        })
    }
    
    @IBAction func seePassword(_ sender: Any) {
        passwordField.isSecureTextEntry = false
    }
    
    @IBAction func unseePassword(_ sender: Any) {
        passwordField.isSecureTextEntry = true
    }
    
    func initTextFieldDesign() {
        initTextField(field: usernameField)
        initTextField(field: passwordField)
        passwordField.isSecureTextEntry = true
    }
    
    func initTextField(field: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0.0, y: field.frame.height - 1, width: field.frame.width, height: 1.0)
        bottomLine.backgroundColor = UIColor.white.cgColor
        field.borderStyle = UITextField.BorderStyle.none
        field.layer.addSublayer(bottomLine)
        field.delegate = self
    }
    
    func loadBackgrounds() {
        if let path = Bundle.main.path(forResource: "Backgrounds", ofType: "plist") {
            backgrounds = NSDictionary(contentsOfFile: path)
        }
    }
    
    @objc func changeBackgroundImage() {
        if let bgs = backgrounds {
            let index = Int.random(in: 0..<bgs.allKeys.count)
            let bg = bgs[bgs.allKeys[index]] as! NSDictionary
            UIView.transition(with: backgroundImage,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.backgroundImage.image = UIImage(named: bgs.allKeys[index] as! String) },
                              completion: nil)
            UIView.transition(with: imageInfoLabel,
                              duration: 0.5,
                              options: .transitionCrossDissolve,
                              animations: { self.imageInfoLabel.text = (bg["name"] as! String) + " by " + (bg["author"] as! String) },
                              completion: nil)
        }
    }
    
}

final class TapGestureRecognizer: UITapGestureRecognizer {
    private var action: () -> Void

    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }

    @objc private func execute() {
        action()
    }
}
