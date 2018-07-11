//
//  EditProfileVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}

class EditProfileVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var rowValue: String!
    var passwordCounter = 0
    var api = EditProfileAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        switchInitialView(rowValue)
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupDismissButton()
        if textField.isHidden == false {
            textField.becomeFirstResponder()
        }
    }
   
    @IBAction func backButtonClicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func switchInitialView(_ value: String)  {
        switch value {
        case "0":
            showChangeDisplayName()
        case "1":
            break
        case "2":
            showChangeEmailView()
        case "3":
            showCurrentPasswordView()
        default:
            break
        }
    }
    
    func showChangeDisplayName() {
        labelDescription.text = "Select the name that will be seen by friends when you make a drop!"
        textField.text = UserInfo.displayName
        textField.placeholder = "Name"
    }
    
    func showChangeEmailView() {
        labelDescription.text = "Your email helps in case you lose your password and need to reset it!"
        textField.text = UserInfo.email
        textField.placeholder = "Email"
    }
    
    func showCurrentPasswordView() {
        labelDescription.text = "If you need to change your password, first please enter your CURRENT pasword"
        textField.placeholder = "Current Password"
    }
    
    func showNewPasswordView() {
        labelDescription.text = "Now enter the NEW password you want to use to log in"
        textField.text = ""
        textField.placeholder = "New Password"
    }
    
    func sendInfoServer (_ updateEntry: String, newInfo: String) {
        api.changeUserInfo(updateEntry: updateEntry, newInfo: newInfo, successClosure: { [weak self] in
            if updateEntry == "email" {
                UserInfo.email = newInfo
            } else {
                UserInfo.displayName = newInfo
            }
            self?.view.endEditing(true)
            self?.dismiss(animated: true, completion: nil)
        }, failureClosure: { [weak self] error in
            self?.alert("Error", message: error + "🙃")
        })
    }
    
    //Do not allow white spaces
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if rowValue != "0" {
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
    
    //regex restrictions for email textfield
    func validateEmail (_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regex, options:  .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // alert message function
    func alert (_ error: String, message : String) {
        let alert = UIAlertController(title: error, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupDismissButton() {
        
        let button = UIButton()
        
        button.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        button.backgroundColor = colorRemBlue
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
        button.setTitle("→", for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
        button.layer.cornerRadius = button.layer.bounds.size.width / 2
        button.addTarget(self, action: #selector(dismissAction), for: UIControlEvents.touchUpInside)
        
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
        
        textField?.inputAccessoryView = toolBar
    }
    
    @objc func dismissAction() {
        switch rowValue {
        case "0":
            if textField.text == UserInfo.displayName {
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            } else {
                if textField.text?.characters.count > 25 {
                    alert("Name too long", message: "Name has to be less than 25 characters💙")
                    return
                } else {
                    if let displayName = textField.text?.lowercased() {
                        sendInfoServer("displayName", newInfo: displayName)
                    }
                }
            }
        case "1":
            break
        case "2":
            if textField.text == UserInfo.email {
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: nil)
            } else {
                if !validateEmail(textField.text!) {
                    alert("Incorrect email", message: "Please provide valid email address☺️")
                    return
                } else {
                    if let email = textField.text?.lowercased() {
                        sendInfoServer("email", newInfo: email)
                    }
                }
            }
        case "3":
            if passwordCounter == 0 {
                passwordCheck()
            } else {
                if self.textField.text?.characters.count < 10 {
                    self.alert("Password error", message: "Password needs to be at least 10 characters🙂")
                    return
                } else {
                    if let password = textField.text {
                        sendInfoServer("password", newInfo: password)
                    }
                }
            }
        default:
            break
        }
    }
    
    func passwordCheck() {
        let username = UserInfo.username
        if let password = textField.text {
            if textField.text?.isEmpty ?? true {
                self.alert("", message: "Please enter your current password")
            } else {
                api.checkCurrentPassword(endpoint: APIEndpoints.checkCurrentPassword, username: username, password: password, successClosure: { [weak self] user in
                    if UserInfo.username == user.username && UserInfo.id == user.userId  {
                        DispatchQueue.main.async {
                            self?.passwordCounter += 1
                            self?.showNewPasswordView()
                        }
                    }
                    }, failureClosure: { [weak self] error in
                        self?.alert("Error", message: error + "🙃")
                })
            }
        }
    }
}
