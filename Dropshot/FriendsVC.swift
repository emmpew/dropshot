//
//  FriendsVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var noFriendsLabel: UILabel!
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let api = FriendsAPI()
    var friends = [Friends]()
    let textCellIdentifier = "FriendCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UINib(nibName: "FriendsCell", bundle: nil), forCellReuseIdentifier: textCellIdentifier)
        noFriendsLabel.isHidden = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        myActivityIndicator.center = view.center
        myActivityIndicator.layer.zPosition = 1000
        getFriends()
        setNavigationBarColor()
    }
    
    func getFriends() {
        myActivityIndicator.startAnimating()
        self.view.addSubview(myActivityIndicator)
        api.getAllFriends(successClosure: { [weak self] friends in
            self?.friends = friends
            if self?.friends.count == 0 {
                if let messageImage = self?.noFriendsLabel {
                    Helper.setAnimationView(view: messageImage, hidden: false)
                }
            } else {
                self?.noFriendsLabel.isHidden = true
            }
            self?.myActivityIndicator.stopAnimating()
            self?.myActivityIndicator.removeFromSuperview()
            self?.tableView.reloadData()
            }, failureClosure: { [weak self] _ in
                self?.myActivityIndicator.stopAnimating()
                self?.myActivityIndicator.removeFromSuperview()
                DispatchQueue.main.async {
                    self?.alertView(message: "Unable to load friends", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                }
        })
    }
    
    func setNavigationBarColor() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colorRemBlue]
        
        let navigationSeparator = UIView(frame: CGRect(x: 0, y: (navigationController?.navigationBar.frame.size.height)! - 1, width: (navigationController?.navigationBar.frame.size.width)!, height: 0.5))
        navigationSeparator.backgroundColor = colorRemBlue // Here your custom color
        navigationSeparator.isOpaque = true
        self.navigationController?.navigationBar.addSubview(navigationSeparator)
    }
    

    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! FriendsCell
        cell.usernameLabel.text = friends[indexPath.row].username
        if let userDisplayName = friends[indexPath.row].displayName {
            cell.displayNameLabel.text = userDisplayName
        } else {
            cell.displayNameLabel.text = ""
        }
        if let url = URL(string: friends[indexPath.row].imageFile) {
            if let data = NSData(contentsOf: url), let image = UIImage(data: data as Data){
                cell.profileImage.image = image
            }
        } else {
            cell.profileImage.image = UIImage(named: "Profile")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? FriendsCell {
            
            let s                   = UIScreen.main.bounds.size
            let pv                  = FriendsPopUpVC(nibName: "FriendsPopUpVC", bundle: nil)
            pv.view.frame           = CGRect(x: 0, y: 0, width: s.width - 2 * 40, height: s.height * 0.50)
            pv.view.backgroundColor = .white
            
            pv.image = cell.profileImage.image
            pv.name = cell.usernameLabel.text
            pv.comingFromVC = 2
            
            presentPopUpViewController(pv)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

}
