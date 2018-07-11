//
//  LogInVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class LogInVC: UIViewController, UITextFieldDelegate, RedirectsToMainScreen {
    
    @IBOutlet weak var labelLogIn: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!

    var api = SignUpAPI()
    let button = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !UIApplication.shared.isRegisteredForRemoteNotifications {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.registerForRemoteNotification()
        }
        setupUI()
        usernameTextField.delegate = self
        usernameTextField.autocapitalizationType = .none
        usernameTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.autocorrectionType = .no
        
        self.usernameTextField.addTarget(self, action: #selector(LogInVC.checkWhenUserTypesAgain(_:)), for: UIControlEvents.editingChanged)
        self.passwordTextField.addTarget(self, action: #selector(LogInVC.checkWhenUserTypesAgain(_:)), for: UIControlEvents.editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupContinueButton()
        usernameTextField.becomeFirstResponder()
    }
    
    //MARK:- API Calls
    
    @objc func logInClicked() {
        if usernameTextField.text?.isEmpty ?? true && passwordTextField.text?.isEmpty ?? true  {
            errorMessageLabel.text = "Please enter username/password"
            errorMessageLabel.isHidden = false
        } else {
            if let username = usernameTextField.text {
                if let password = passwordTextField.text {
                    var deviceToken = ""
                    if let key = UserDefaults.standard.value(forKey: "deviceToken") {
                        deviceToken = key as! String
                    }
                    api.signInCredentials(endpoint: APIEndpoints.signinURL, username: username, password: password, token: deviceToken, successClosure: { [weak self] user in
                        self?.button.isEnabled = false
                        self?.view.endEditing(true)
                        UserInfo.username = user.username
                        UserInfo.displayName = user.displayName
                        UserInfo.token = user.token
                        UserInfo.id = user.userId
                        UserInfo.getURL = user.getURL
                        UserInfo.email = user.email
                        UserInfo.totalBadgeCount = user.userBadgeCount
                        UIApplication.shared.applicationIconBadgeNumber = user.userBadgeCount
                        
                        UserDefaults.standard.synchronize()
                        
                        self?.navigationController!.viewControllers.removeAll()
                        DispatchQueue.main.async {
                            self?.goToMain()
                        }
                        }, failureClosure: { [weak self] error in
                            self?.errorMessageLabel.isHidden = false
                            self?.errorMessageLabel.text = error.capitalizingFirstLetter()
                    })
                }
            }
        }
    }
    
    //MARK:- UI
    
    func setupUI() {
        errorMessageLabel.isHidden = true
        labelLogIn.text = "Welcome!"
        usernameTextField.placeholder = "Username"
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
    }
    
    @objc func checkWhenUserTypesAgain(_ textField: UITextField) {
        errorMessageLabel.isHidden = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let characterSetNotAllowed = NSCharacterSet.whitespaces
        let rangeOfCharacter = string.rangeOfCharacter(from: characterSetNotAllowed, options: .caseInsensitive, range: nil)
        if let _ = rangeOfCharacter {
            return false //trhey're trying to add not allowed characters
        } else {
            return true //all characters to add are allowed
        }
    }

    func setupContinueButton() {
        
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.backgroundColor = colorRemBlue
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("→", for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
        button.layer.cornerRadius = button.layer.bounds.size.width / 2
        button.addTarget(self, action: #selector(logInClicked), for: UIControlEvents.touchUpInside)
        
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
        
        usernameTextField?.inputAccessoryView = toolBar
        passwordTextField?.inputAccessoryView = toolBar
    }
    
    @IBAction func backToLandingVC(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension String {
    func capitalizingFirstLetter() -> String {
        let first = String(characters.prefix(1)).capitalized
        let other = String(characters.dropFirst())
        return first + other
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
