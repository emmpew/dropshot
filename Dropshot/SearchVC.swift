//
//  SearchVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class SearchVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noUsersFoundLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var api = SearchUserAPI()
    var searchResults = [SearchedUser]()
    var searchBar = UISearchBar()
    let textCellIdentifier = "SearchCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "AddFriendCell", bundle: nil), forCellReuseIdentifier: textCellIdentifier)
        noUsersFoundLabel.isHidden = true
        //searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        myActivityIndicator.center = view.center
        myActivityIndicator.layer.zPosition = 1000
        searchBarSetup()
        setNavigationBarColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        customizeTextFieldSearch()
    }

    @IBAction func dismissVC(_ sender: Any) {
        searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- Textfield
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let characterSetNotAllowed = NSCharacterSet.whitespaces
            let rangeOfCharacter = string.rangeOfCharacter(from: characterSetNotAllowed, options: .caseInsensitive, range: nil)
            if let _ = rangeOfCharacter {
                return false //trhey're trying to add not allowed characters
            } else {
                return true //all characters to add are allowed
            }
    }
    
    //MARK:- TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! AddFriendCell
        cell.deviceToken = searchResults[indexPath.row].deviceToken
        cell.userID = searchResults[indexPath.row].id
        cell.nameLabel.text = searchResults[indexPath.row].username
        if let userDisplayName = searchResults[indexPath.row].displayName {
            cell.displayName.text = userDisplayName
        } else {
            cell.displayName.text = ""
        }
        if let url = URL(string: searchResults[indexPath.row].imageURL), let data = NSData(contentsOf: url), let image = UIImage(data: data as Data){
            cell.profilePicture.image = image
        } else {
            cell.profilePicture.image = UIImage(named: "Profile")
        }
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! AddFriendCell
        //send info to friend VC

        //show view controller with friend profile
        let s                   = UIScreen.main.bounds.size
        let pv                  = FriendsPopUpVC()
        pv.view.frame           = CGRect(x: 0, y: 0, width: s.width - 2 * 40, height: s.height * 0.55)
        pv.view.backgroundColor = .white
        
        pv.comingFromVC = 0
        pv.image = cell.profilePicture.image
        pv.name = cell.nameLabel.text
        pv.friendID = cell.userID
        pv.friendDeviceToken = cell.deviceToken
        
        presentPopUpViewController(pv)
        //disable highlight after click
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath:
        IndexPath) {
        let customCell = cell as! AddFriendCell
        customCell.backgroundColor = .clear
        customCell.nameLabel?.textColor = .darkGray
    }
    
    //MARK:- SearchBar
    
    func searchBarSetup() {
        
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        
        searchBar.searchBarStyle = .prominent
        searchBar.isTranslucent = false
        
        searchBar.barTintColor = colorRemBlue
        searchBar.tintColor = colorRemBlue
        
        searchBar.autocorrectionType = .no
        searchBar.autocapitalizationType = .none
        
        self.navigationItem.titleView = searchBar
    }
    
    func customizeTextFieldSearch() {
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = colorRemBlue  //changes typed text color
        textFieldInsideSearchBar?.backgroundColor = .white  //changes textfield color
        textFieldInsideSearchBar?.attributedPlaceholder = NSAttributedString(string:"Enter friend's username", attributes:[NSAttributedStringKey.foregroundColor: colorRemBlue])
        textFieldInsideSearchBar?.textAlignment = .left
        
        let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        glassIconView.tintColor = colorRemBlue
        
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.backgroundColor = colorPurpleHaze
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.white.cgColor
        button.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 17.0)
        button.setTitle("x", for: UIControlState())
        button.layer.cornerRadius = button.layer.bounds.size.width / 2
        button.addTarget(self, action: #selector(dismissAction), for: UIControlEvents.touchUpInside)
        
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = button
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 55))
        toolBar.setBackgroundImage(UIImage(), forToolbarPosition: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        toolBar.setShadowImage(UIImage(), forToolbarPosition: UIBarPosition.any)
        toolBar.barStyle = UIBarStyle.default
        toolBar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            rightBarButton,
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        ]
        
        textFieldInsideSearchBar?.inputAccessoryView = toolBar
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }
    
    @objc func dismissAction() {
        searchBar.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let characterSetNotAllowed = NSCharacterSet.whitespaces
        let rangeOfCharacter = text.rangeOfCharacter(from: characterSetNotAllowed, options: .caseInsensitive, range: nil)
        if let _ = rangeOfCharacter {
            return false //trhey're trying to add not allowed characters
        } else {
            return true //all characters to add are allowed
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        noUsersFoundLabel.isHidden = true
        let selector = #selector(SearchVC.doSearch)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: selector, object: nil)
        perform(selector, with: nil, afterDelay: 0.8)
    }
    
    @objc func doSearch() {
        let word = searchBar.text!
        if word != "" {
            myActivityIndicator.startAnimating()
            self.view.addSubview(myActivityIndicator)
            api.searchUsers(currentUser: UserInfo.username, word: word, successClosure: { [weak self] user in
                self?.searchResults = user
                if self?.searchResults.count == 0 {
                    if let messageImageView = self?.noUsersFoundLabel {
                        Helper.setAnimationView(view: messageImageView, hidden: false)
                    }
                } else {
                    self?.noUsersFoundLabel.isHidden = true
                }
                self?.myActivityIndicator.stopAnimating()
                self?.myActivityIndicator.removeFromSuperview()
                self?.tableView.reloadData()
                }, failureClosure:{ [weak self] _ in
                    self?.myActivityIndicator.stopAnimating()
                    self?.myActivityIndicator.removeFromSuperview()
                    DispatchQueue.main.async {
                        self?.alertView(message: "Unable to search username", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                    }
            })
        } else {
            searchResults.removeAll(keepingCapacity: false)
            tableView.reloadData()
        }
    }
    
    //MARK:- Navigation Bar
    
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
}
