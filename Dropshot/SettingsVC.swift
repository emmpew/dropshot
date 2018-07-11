//
//  SettingsVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class SettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate, RedirectsToWelcomeScreen {
    
    var dataCell = SettingsModel()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dismissButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        setNavigationBarColor()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.hidesBarsOnSwipe = true
    }

    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataCell.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCell.items[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: self.tableView.sectionHeaderHeight))
        returnedView.backgroundColor = .white
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 100, height: 40))
        label.text = dataCell.sections[section]
        label.font = UIFont(name: "Avenir-Light", size: 17.0)
        label.font = UIFont.boldSystemFont(ofSize: 17)
        label.textColor = colorRemBlue
        
        let label2 = UILabel(frame: CGRect(x: 10, y: 35, width: self.tableView.frame.width - 20, height: 0.5))
        label2.layer.borderWidth = 0.5
        label2.layer.borderColor = colorRemBlue.cgColor
        
        returnedView.addSubview(label2)
        returnedView.addSubview(label)
        
        return returnedView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let row = indexPath.row
        let section = indexPath.section
        let cellData = dataCell.items[section][row]
        cell.textLabel?.text = cellData
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let ud = UserDefaults.standard
        let settings = tableView.cellForRow(at: indexPath)!.textLabel!.text!
        let header = self.tableView(tableView, titleForHeaderInSection: (indexPath as IndexPath).section)
        
        ud.setValue(settings, forKey: header!)
        switch settings {
            
        case "Name", "Email", "Password":
            editProfileTap()
        case "Username":
            let alert = UIAlertController(title: "My Username", message: UserInfo.username, preferredStyle: .alert)
            alert.view.tintColor = colorMellowBlue
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            break
        case "Privacy Policy":
            goToPrivacyPolicy()
        case "Terms of Service":
            goToPrivacyPolicy()
        case "Log Out":
            self.showAlert(title: "Log Out", message: "Are you sure you want to log out?")
        default:
            break
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataCell.sections[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .darkGray
        cell.textLabel?.font = UIFont(name: "Avenir-Light", size: 15.0)
    }
    
    //MARK:- Functions
    
    fileprivate func showAlert(title: String?, message: String?, button: String = "Log Out", button2: String = "Cancel") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.view.tintColor = colorSmoothRed
        alert.addAction(UIAlertAction(title: button, style: .default, handler: { (UIAlertAction) in
            DispatchQueue.main.async {
                self.logOut()
                self.navigationController!.viewControllers.removeAll()
            }
        }))
        alert.addAction(UIAlertAction(title: button2, style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func logOut() {
        UIApplication.shared.unregisterForRemoteNotifications()
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
            UIApplication.shared.applicationIconBadgeNumber = 0
            ExpireWatcher.deleteFiles()
            goToWelcomeScreen()
        }
    }
    
    func editProfileTap() {
        let editVC = self.storyboard?.instantiateViewController(withIdentifier: "EditProfile") as! EditProfileVC
        let selectedRow = tableView.indexPathForSelectedRow!
        editVC.rowValue = (selectedRow as NSIndexPath).row.description
        present(editVC, animated: true, completion: nil)
    }
    
    func goToPrivacyPolicy() {
        let privacyVC = self.storyboard?.instantiateViewController(withIdentifier: "PrivacyPolicy") as! PrivacyPolicyVC
        let selectedRow = tableView.indexPathForSelectedRow!
        privacyVC.rowValue = selectedRow.row.description
        present(privacyVC, animated: true, completion: nil)
    }
    
    func setNavigationBarColor() {
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: colorRemBlue]
    }

}
