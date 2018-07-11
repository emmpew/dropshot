
//
//  RequestsVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class RequestsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, FriendsPopUpDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noRequestsLabel: UILabel!
    @IBOutlet weak var dismissButton: DismissButton!
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var api = RequestsAPI()
    var userRequests = [RequestUser]()
    let textCellIdentifier = "RequestCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UINib(nibName: "RequestsCell", bundle: nil), forCellReuseIdentifier: textCellIdentifier)
        
        noRequestsLabel.isHidden = true
        tableView.delegate = self
        tableView.dataSource = self
        myActivityIndicator.center = view.center
        myActivityIndicator.layer.zPosition = 1000
        loadRequest()
        setNavigationBarColor()
        UserInfo.totalBadgeCount = 0
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    //MARK:- API Calls
    
    func loadRequest() {
        myActivityIndicator.startAnimating()
        self.view.addSubview(myActivityIndicator)
        api.getAllRequests(successClosure: { [weak self] (requests) in
            self?.userRequests = requests
            if self?.userRequests.count == 0 {
                if let noRequests = self?.noRequestsLabel {
                    Helper.setAnimationView(view: noRequests, hidden: false)
                }
            } else {
                self?.noRequestsLabel.isHidden = true
            }
            self?.myActivityIndicator.stopAnimating()
            self?.myActivityIndicator.removeFromSuperview()
            self?.tableView.reloadData()
            }, failureClosure: { [weak self] _ in
                self?.myActivityIndicator.stopAnimating()
                self?.myActivityIndicator.removeFromSuperview()
                DispatchQueue.main.async {
                    self?.alertView(message: "Unable to load requests", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
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

    @IBAction func dismissTVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - TableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRequests.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! RequestsCell
        cell.requestID = userRequests[indexPath.row].requestID
        cell.usernameLabel.text = userRequests[indexPath.row].username
        if let userDisplayName = userRequests[indexPath.row].displayName {
            cell.displayNameLabel.text = userDisplayName
        } else {
            cell.displayNameLabel.text = ""
        }
        if let url = URL(string: userRequests[indexPath.row].imageFile) {
            if let data = NSData(contentsOf: url), let image = UIImage(data: data as Data){
                cell.profileImage.image = image
            }
        } else {
            cell.profileImage.image = UIImage(named: "Profile")
        }
        
        if let requestID = userRequests[indexPath.row].requestID {
            cell.acceptRequestAction = { [weak self] in
                if self?.userRequests[indexPath.row].status == .acceptNow {
                    RequestsAPI().acceptRequest(requestID: requestID, successClosure: { _ in
                        DispatchQueue.main.async {
                            cell.addButton.isEnabled = true
                            //change UI of button when user accepted
                            self?.userRequests[indexPath.row].status = .accepted
                            cell.addButton.layer.borderColor = UIColor.white.cgColor
                            cell.addButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 18.0)
                            cell.addButton.setTitle("✓", for: UIControlState())
                            cell.addButton.setTitleColor(.white, for: UIControlState())
                            cell.addButton.backgroundColor = colorRemBlue
                        }
                    }, failureClosure:  { [weak self] _ in
                        cell.addButton.isEnabled = true
                        DispatchQueue.main.async {
                            self?.alertView(message: "Unable to add friend", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                        }
                    })
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cell = tableView.cellForRow(at: indexPath) as! RequestsCell
        //send info to friend VC
        
        //show view controller with friend profile
        let s                   = UIScreen.main.bounds.size
        let pv                  = FriendsPopUpVC()
        pv.view.frame           = CGRect(x: 0, y: 0, width: s.width - 2 * 40, height: s.height * 0.55)
        pv.view.backgroundColor = .white
        pv.requestID = cell.requestID
        pv.image = cell.profileImage.image!
        pv.name = cell.usernameLabel.text!
        pv.comingFromVC = 1
        pv.indexPath = indexPath
        pv.currentStatus = userRequests[indexPath.row].status
        pv.delegate = self
        
        presentPopUpViewController(pv)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath:
        IndexPath) {
        let customCell = cell as! RequestsCell
        customCell.backgroundColor = .clear
        customCell.usernameLabel?.textColor = .darkGray
    }
    
    //Delegate
    func updateStatus(status: FriendshipStatus?, indexPath: IndexPath?) {
        if let newStatus = status {
            if newStatus == .accepted {
                if let indexPath = indexPath {
                    let cell = tableView.cellForRow(at: indexPath) as! RequestsCell
                    userRequests[indexPath.row].status = .accepted
                    DispatchQueue.main.async {
                        cell.addButton.layer.borderColor = UIColor.white.cgColor
                        cell.addButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 18.0)
                        cell.addButton.setTitle("✓", for: UIControlState())
                        cell.addButton.setTitleColor(.white, for: UIControlState())
                        cell.addButton.backgroundColor = colorRemBlue
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}
