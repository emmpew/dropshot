//
//  SignUpVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class SignUpVC: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, RedirectsToMainScreen {
    
    @IBOutlet weak var labelStatement: UILabel!
    @IBOutlet weak var textFieldInfo: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var api = SignUpAPI()
    var emailText: String!
    var usernameText: String!
    var displayNameText: String!
    var passwordText: String!
    var counter = 0
    var correctInput = false
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !UIApplication.shared.isRegisteredForRemoteNotifications {
            UIApplication.shared.registerForRemoteNotifications()
        }
        
        errorMessageLabel.isHidden = true
        enterEmail()
        textFieldInfo.delegate = self
        textFieldInfo.autocapitalizationType = .none
        textFieldInfo.autocorrectionType = .no
        
        self.textFieldInfo.addTarget(self, action: #selector(SignUpVC.checkWhenUserTypesAgain(_:)), for: UIControlEvents.editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createContinueButtonTabBar()
        textFieldInfo.becomeFirstResponder()
    }
    
    func enterEmail() {
        textFieldInfo.isSecureTextEntry = false
        labelStatement.text = "Please enter your email"
        textFieldInfo.placeholder = "Email"
    }
    
    func enterPassword() {
        textFieldInfo.isSecureTextEntry = true
        labelStatement.text = "Please enter your password"
        textFieldInfo.placeholder = "Password"
    }
    
    func enterDisplayName() {
        textFieldInfo.isSecureTextEntry = false
        labelStatement.text = "Enter the name that your friends will see"
        textFieldInfo.placeholder = "Name"
    }
    
    func enterUsername() {
        textFieldInfo.isSecureTextEntry = false
        labelStatement.text = "Please enter a unique username"
        textFieldInfo.placeholder = "Username"
    }
    
    @objc func checkWhenUserTypesAgain(_ textField: UITextField) {
        errorMessageLabel.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if counter != 2 {
            let characterSetNotAllowed = NSCharacterSet.whitespaces
            let rangeOfCharacter = string.rangeOfCharacter(from: characterSetNotAllowed, options: .caseInsensitive, range: nil)
            if let _ = rangeOfCharacter {
                return false //trhey're trying to add not allowed characters
            } else {
                return true //all characters to add are allowed
            }
        }
        return true
    }
    
    func validateEmail(_ enteredEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailFormat)
        return emailPredicate.evaluate(with: enteredEmail)
    }
    
    func switchUIInputs() {
        
        switch counter {
        case -1:
            self.view.endEditing(true)
            self.dismiss(animated: true, completion: nil)
        case 0:
            enterEmail()
            textFieldInfo.text = emailText
        case 1:
            enterPassword()
            textFieldInfo.text = passwordText
        case 2:
            enterDisplayName()
            textFieldInfo.text = displayNameText
        case 3:
            enterUsername()
            textFieldInfo.text = usernameText
        default:
            break
        }
    }
    
    func checkCorrectInput() {
        
        switch counter {
        case 0:
            emailText = textFieldInfo.text
            
            if validateEmail(textFieldInfo.text!) == false {
                emailText = textFieldInfo.text
                errorMessageLabel.isHidden = false
                errorMessageLabel.text = "Valid email please🙂"
            } else {
                correctInput = true
            }
            
        case 1:
            passwordText = textFieldInfo.text
            
            if (textFieldInfo.text?.characters.count)! < 10 {
                errorMessageLabel.isHidden = false
                errorMessageLabel.text = "Password needs to be at least 10 characters💙"
            } else {
                correctInput = true
            }
            
        case 2:
            
            displayNameText = textFieldInfo.text
            
            guard textFieldInfo.text?.isEmpty == false else {
                errorMessageLabel.isHidden = false
                errorMessageLabel.text = "Your name please☺️"
                return
            }
            
            if (textFieldInfo.text?.characters.count)! > 25 {
                errorMessageLabel.isHidden = false
                errorMessageLabel.text = "Name has to be less than 25 characters👽"
            } else {
                correctInput = true
            }
            
        case 3:
            registerBackgroundTask()
            usernameText = textFieldInfo.text
            
            guard textFieldInfo.text?.isEmpty == false else {
                errorMessageLabel.isHidden = false
                errorMessageLabel.text = "Cool username please🙊"
                return
            }
            
            var token = ""
            if let key = UserDefaults.standard.value(forKey: "deviceToken") {
                token = key as! String
            }
            button.isEnabled = false
            api.signUpCredentials(endpoint: APIEndpoints.signupURL, email: emailText.lowercased(), password: passwordText, username: usernameText.lowercased(), diplayName: displayNameText.lowercased(), token: token, successClosure: { [weak self] user in
                
                self?.view.endEditing(true)
                self?.navigationController!.viewControllers.removeAll()
                
                UserInfo.username = user.username
                UserInfo.displayName = user.displayName
                UserInfo.token = user.token
                UserInfo.id = user.userId
                UserInfo.email = user.email
                UserInfo.totalBadgeCount = user.userBadgeCount
                UserDefaults.standard.synchronize()
                
                self?.endBackgroundTask()
                
                self?.performSegue(withIdentifier: "ShowInitialUsers", sender: self)
//                DispatchQueue.main.async {
//                    self?.goToMain()
//                }
                }, failureClosure: { [weak self] error in
                    self?.button.isEnabled = true
                    self?.errorMessageLabel.isHidden = false
                    self?.errorMessageLabel.text = error.capitalizingFirstLetter() + "🙃"
                    self?.endBackgroundTask()
            })
        default:
            break
        }
    }
    
    func createContinueButtonTabBar() {
        
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.backgroundColor = colorRemBlue
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("→", for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
        button.layer.cornerRadius = button.layer.bounds.size.width / 2
        button.addTarget(self, action: #selector(continueButtonClicked), for: UIControlEvents.touchUpInside)
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = button
        
        var toolBar = UIToolbar()
        toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 90))
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        toolBar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        toolBar.barStyle = UIBarStyle.black
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            rightBarButton,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        ]
        
        textFieldInfo?.inputAccessoryView = toolBar
    }
    
    @objc func continueButtonClicked() {
        checkCorrectInput()
        if correctInput == true {
            correctInput = false
            counter += 1
            DispatchQueue.main.async {
                self.switchUIInputs()
            }
        }
    }
    
    @IBAction func previousView(_ sender: Any) {
        counter -= 1
        errorMessageLabel.isHidden = true
        DispatchQueue.main.async {
            self.switchUIInputs()
        }
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        if backgroundTask != UIBackgroundTaskInvalid {
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = UIBackgroundTaskInvalid
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowInitialUsers" {
            if let vc = segue.destination as? InitialUsersVC {
                vc.skipButton.tintColor = .red

            }
        }
    }
}

