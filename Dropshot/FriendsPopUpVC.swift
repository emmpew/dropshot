//
//  FriendsPopUpVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

protocol FriendsPopUpDelegate: class {
    func updateStatus(status: FriendshipStatus?, indexPath: IndexPath?)
}

class FriendsPopUpVC: UIViewController {
    
    weak var delegate: FriendsPopUpDelegate?

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var addFriendButton: UIButton!
    
    var currentStatus: FriendshipStatus?
    var status: FriendshipStatus?
    var comingFromVC = 0
    var indexPath: IndexPath?
    var requestID: String?
    var url: String = ""
    
    var image: UIImage?
    var name: String?
    var friendID: String?
    var friendDeviceToken: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addFriendButton.layer.cornerRadius = 10
        addFriendButton.layer.borderWidth = 1
        addFriendButton.layer.borderColor = UIColor.white.cgColor
        usernameLabel.textColor = .darkGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        getFriendsRelationshipStatus()
    }
    
    func getFriendsRelationshipStatus() {
        switch comingFromVC {
        case 0:
            if let friendsUsername = usernameLabel.text {
                FriendsPopUpAPI().getRelationshipStatus(friendsUsername: friendsUsername, successClosure: { [weak self] friendship in
                    self?.status = friendship.status
                    self?.requestID = friendship.requestID
                    self?.setStatusButton(searchStatus: friendship.status)
                    }, failureClosure: { [weak self] _ in
                        DispatchQueue.main.async {
                            self?.alertView(message: "Unable to show user", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                        }
                })
            }
        case 1:
            if let currentStatus = currentStatus {
                if currentStatus == .acceptNow {
                    status = .acceptNow
                    setStatusButton(searchStatus: .acceptNow)
                } else {
                    status = .accepted
                    setStatusButton(searchStatus: .accepted)
                }
            }
        case 2:
            status = .accepted
            setStatusButton(searchStatus: .accepted)
        case 3:
            status = .none
            setStatusButton(searchStatus: .none)
        default:
            break
        }
    }
    
    func setStatusButton(searchStatus: FriendshipStatus) {
        switch searchStatus {
        case .accepted:
            addFriendButton.layer.borderColor = colorRemBlue.cgColor
            addFriendButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 18.0)
            addFriendButton.setTitle("✓", for: UIControlState())
            addFriendButton.setTitleColor(colorRemBlue, for: UIControlState())
        case .waiting:
            addFriendButton.layer.borderColor = colorSmoothRed.cgColor
            addFriendButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
            addFriendButton.setTitle("Sent", for: UIControlState())
            addFriendButton.setTitleColor(colorSmoothRed, for: UIControlState())
        case .none:
            addFriendButton.setTitle("+Add", for: UIControlState())
            addFriendButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
            addFriendButton.setTitleColor(colorRemBlue, for: UIControlState())
            addFriendButton.layer.borderColor = colorRemBlue.cgColor
        case .acceptNow:
            addFriendButton.setTitle("+Accept", for: UIControlState())
            addFriendButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
            addFriendButton.setTitleColor(colorSmoothRed, for: UIControlState())
            addFriendButton.layer.borderColor = colorSmoothRed.cgColor
        }
    }
    
    func pressButton(searchStatus: FriendshipStatus) {
        switch searchStatus {
        case .accepted:
            break
        case .waiting:
            break
        case .none:
            FriendsPopUpAPI().addUser(username: UserInfo.username, currentUserID: UserInfo.id, currentUserDisplayName: UserInfo.displayName, friendID: friendID!, friendUsername: name!, profileImageURL: url, deviceToken: friendDeviceToken, successClosure: { [weak self] in
                DispatchQueue.main.async {
                    //change UI of button when user accepted
                    self?.status = .waiting
                    self?.setStatusButton(searchStatus: .waiting)
                }
                }, failureClosure: { [weak self] _ in
                    DispatchQueue.main.async {
                        self?.alertView(message: "Unable to add friend", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                    }
            })
            break
        case .acceptNow:
            if let requestID = requestID {
                RequestsAPI().acceptRequest(requestID: requestID, successClosure: { [weak self] _ in
                    DispatchQueue.main.async {
                        //change UI of button when user accepted
                        //agregar delegate
                        if let delegate = self?.delegate {
                            delegate.updateStatus(status: .accepted, indexPath: self?.indexPath)
                        }
                        self?.status = .accepted
                        self?.setStatusButton(searchStatus: .accepted)
                    }
                    }, failureClosure: { [weak self] _ in
                        DispatchQueue.main.async {
                            self?.alertView(message: "Unable to accept friend request", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                        }
                })
            }
            break
        }
    }
    
    func setupUI() {
        //profile picture setup
        self.view.layoutIfNeeded()
        profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2
        profilePicture.clipsToBounds = true
        profilePicture.backgroundColor = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 85.0/255.0, alpha:1.0)
        
        if let image = image, let name = name {
            profilePicture.image = image
            usernameLabel.text = name
        }
        
        let getURL = UserDefaults.standard.value(forKey: "getURL") as? String
        if getURL == nil || getURL == "" {
            url = ""
        } else {
            url = UserInfo.getURL
        }
    }

    @IBAction func takeActionButton(_ sender: Any) {
        addFriendButton.isEnabled = false
        pressButton(searchStatus: status!)
    }
}
