//
//  ProfileViewController.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var friendsButton: UIButton!
    @IBOutlet weak var addFriendsButton: UIButton!
    @IBOutlet weak var requestsButton: UIButton!
    @IBOutlet weak var closeButton: DismissButton!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    
    var api = ProfileAPI()
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserInfo.totalBadgeCount = UIApplication.shared.applicationIconBadgeNumber
        
        picker.delegate = self
        self.view.layoutIfNeeded()
        usernameLabel.textColor = colorRemBlue
        rightBarButtonItem.image = UIImage(named: "SettingsButton.png")?.withRenderingMode(.alwaysOriginal)
        
        usernameLabel.text = UserInfo.displayName.isEmpty ? UserInfo.username : UserInfo.displayName

        roundImage()
        profilePictureSetup()
        customizeButtons()
        setNavigationBarColor()
        loadCountRequests()
        
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        profilePicture.isUserInteractionEnabled = true
        profilePicture.addGestureRecognizer(avaTap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if UserInfo.totalBadgeCount == 0 {
            setupButton(button: requestsButton)
        }
    }
    
    //MARK:- Functions
    
    func profilePictureSetup() {
        let profileData = UserDefaults.standard.value(forKey: "profileData")
        let getURL = UserDefaults.standard.value(forKey: "getURL") as? String
        if profileData == nil {
            DispatchQueue.main.async {
                if getURL == nil || getURL == ""{
                    self.profilePicture.image = UIImage(named: "Profile")
                } else {
                    if let url = URL(string: getURL!), let data = NSData(contentsOf: url), let image = UIImage(data: data as Data){
                        UserInfo.profileImageData = data as Data
                        self.profilePicture.image = image
                    }
                }
            }
        } else {
            if let imageData = profileData {
                let image = UIImage(data: imageData as! Data)
                profilePicture.image = image
            }
        }
    }
    
    func changeRequestButtonColor() {
        requestsButton.backgroundColor = colorRemBlue
        requestsButton.setTitleColor(.white, for: UIControlState())
        requestsButton.layer.borderColor = UIColor.white.cgColor
    }
    
    func loadCountRequests() {
        if UserInfo.totalBadgeCount >= 1 {
            changeRequestButtonColor()
        }
    }
    
    @IBAction func showSettingsStoryboard(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated:true, completion: nil)
    }
    
    @IBAction func dismissProfile(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }

    //MARK:- Picker Controller
    
    // call picker to select image
    @objc func loadImg(_ recognizer:UITapGestureRecognizer) {
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        //customize picker navigation bar
        setPickerNavigationBarColor()
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profilePicture.image = image
            if let imageData = UIImageJPEGRepresentation(image, 0.3) {
                UserInfo.profileImageData = imageData
            }
            api.saveProfileImage(image: image, successClosure: { _ in
            }, failureClosure: { [weak self] (_ ) in
                let message = String("Error uploading the image")
                self?.alertView(message: message, window: appDelegate.window!, color: colorSmoothRed, delay: 3)
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK:- UI
    
    func roundImage() {
        //profile picture setup
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
    }
    
    func setupButton(button: UIButton) {
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = colorRemBlue.cgColor
        button.setTitleColor(colorRemBlue, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Avenir-Light", size: fontSize17)
    }
    
    func customizeButtons() {
        let buttons: [UIButton] = [friendsButton, addFriendsButton, requestsButton]
        for button in buttons {
            setupButton(button: button)
        }
    }
    
    // to remove the "back" title on the segued view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        // This will show in the next view controller being pushed
        navigationItem.backBarButtonItem = backItem
    }
    
    func setNavigationBarColor() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func setPickerNavigationBarColor() {
        picker.navigationBar.setBackgroundImage(UIImage(), for: .default)
        picker.navigationBar.shadowImage = UIImage()
        picker.navigationBar.backgroundColor = .white
        picker.navigationBar.isTranslucent = true
        picker.navigationBar.tintColor = colorRemBlue
        picker.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colorRemBlue]
        
        let navigationSeparator = UIView(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.size.height)! - 1, width: (navigationController?.navigationBar.frame.size.width)!, height: 0.5))
        navigationSeparator.backgroundColor = colorRemBlue // Here your custom color
        navigationSeparator.isOpaque = true
        picker.navigationBar.addSubview(navigationSeparator)
    }
}
