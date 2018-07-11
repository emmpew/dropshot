//
//  InitialUsersVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 5/15/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

class InitialUsersVC: UIViewController, UITableViewDelegate, UITableViewDataSource, RedirectsToMainScreen {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    
    let textCellIdentifier = "cell"
    let data = [InitialUsersModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "InitialUserCell", bundle: nil), forCellReuseIdentifier: textCellIdentifier)
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    @IBAction func skipButtonPressed(_ sender: Any) {
        DispatchQueue.main.async {
            self.goToMain()
        }
    }
    
    // MARK: - TableView Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 99
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! InitialUserCell
        if let url = URL(string: data[indexPath.row].image) {
            if let data = NSData(contentsOf: url), let image = UIImage(data: data as Data){
                cell.profileImage.image = image
            }
        } else {
            cell.profileImage.image = UIImage(named: "Profile")
        }
        cell.usernameLabel.text = data[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? InitialUserCell {
            
            //show view controller with friend profile
            let s                   = UIScreen.main.bounds.size
            let pv                  = FriendsPopUpVC()
            pv.view.frame           = CGRect(x: 0, y: 0, width: s.width - 2 * 40, height: s.height * 0.55)
            pv.view.backgroundColor = .white
            
            pv.status = .none
            pv.indexPath = indexPath
            pv.comingFromVC = 3
            pv.image = cell.profileImage.image
            pv.name = cell.usernameLabel.text
            //agregar estos tambien
//            pv.friendID = cell.userID
//            pv.friendDeviceToken = cell.deviceToken
//            pv.delegate = self
            
            presentPopUpViewController(pv)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
