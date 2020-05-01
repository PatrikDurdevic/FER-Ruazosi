//
//  ViewController.swift
//  QuizApp
//
//  Created by Patrik Durdevic on 10/04/2020.
//  Copyright © 2020 Patrik Đurđević. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backgroundImage: UIImageView!
    var backgrounds: NSDictionary?
    var bgTimer: Timer?
    
    @IBOutlet weak var usernameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var buttonView: UIView!
    
    @IBOutlet weak var imageInfoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMotionToBackground()
        loadBackgrounds()
        bgTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(changeBackgroundImage), userInfo: nil, repeats: true)
        let tapRecognizer = TapGestureRecognizer {
            self.view.endEditing(true)
        }
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        initTextFieldDesign()
        
        if let _ = UserDefaults.standard.object(forKey: "token") {
            self.presentQuiz()
        }
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
        present(ViewController.getApp(), animated: true, completion: nil)
    }
    
    @IBAction func seePassword(_ sender: Any) {
        passwordField.isSecureTextEntry = false
    }
    
    @IBAction func unseePassword(_ sender: Any) {
        passwordField.isSecureTextEntry = true
    }
    
    func initTextFieldDesign() {
        let usernameBottomLine = CALayer()
        usernameBottomLine.frame = CGRect(x: 0.0, y: usernameField.frame.height - 1, width: usernameField.frame.width, height: 1.0)
        usernameBottomLine.backgroundColor = UIColor.white.cgColor
        usernameField.borderStyle = UITextField.BorderStyle.none
        usernameField.layer.addSublayer(usernameBottomLine)
        usernameField.delegate = self
        
        let passwordBottomline = CALayer()
        passwordBottomline.frame = CGRect(x: 0.0, y: passwordField.frame.height - 1, width: passwordField.frame.width, height: 1.0)
        passwordBottomline.backgroundColor = UIColor.white.cgColor
        passwordField.borderStyle = UITextField.BorderStyle.none
        passwordField.layer.addSublayer(passwordBottomline)
        passwordField.isSecureTextEntry = true
        passwordField.delegate = self
    }
    
    func addMotionToBackground() {
        let min = CGFloat(-30)
        let max = CGFloat(30)
              
        let xMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        xMotion.minimumRelativeValue = min
        xMotion.maximumRelativeValue = max
              
        let yMotion = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        yMotion.minimumRelativeValue = min
        yMotion.maximumRelativeValue = max
              
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [xMotion,yMotion]

        backgroundImage.addMotionEffect(motionEffectGroup)
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
