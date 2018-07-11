//
//  RootViewController.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 3/6/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

protocol MediaPreviewDelegate: class {
    func didFinishShowMedia(seenMedia: [String], totalDrops: [Drop]) -> Void
    func deleteDrop(drop: Drop) -> Void
}

class MediaPreviewDrops: UIViewController {
    
    weak var delegate:MediaPreviewDelegate?
    var seenDrops = [String]()
    var photosToShow: NSArray?
    
    @IBOutlet weak var pageControl: UIPageControl!
    var pageVC: PageVC? {
        didSet {
            pageVC?.displayDelegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setPageControl()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let pageVC = segue.destination as? PageVC {
            self.pageVC = pageVC
            pageVC.contentArray = photosToShow
        }
    }
    
    func setPageControl() {
        pageControl.isHidden = true
        pageControl.addTarget(self, action: #selector(MediaPreviewDrops.didChangePageControlValue), for: .valueChanged)
    }
    
    /// This updates the seen array each time the user sees a photo
    ///
    /// - Parameter index: The index of the photo to be seen
    func updateContentVisibility(index:Int) {
        if let drops = self.photosToShow {
            let drop: Drop = drops[index] as! Drop
            if !drop.seenBy.contains(UserInfo.username) {
                drop.seenBy.append(UserInfo.username)
                seenDrops.append(drop.id)
            }
        }
    }
    
    @objc func didChangePageControlValue() {
        pageVC?.scrollToViewController(index: pageControl.currentPage)
    }

    @IBAction func previousPressed(_ sender: Any) {
        pageVC?.scrollToPreviousViewController()
    }
    
    @IBAction func nextPressed(_ sender: Any) {        
        if (pageVC?.currentIndex())! + 1 >= (photosToShow?.count)! {
            if let delegate = delegate {
                delegate.didFinishShowMedia(seenMedia: seenDrops, totalDrops: photosToShow as! [Drop])
            }
        }
        else {
            pageVC?.scrollToNextViewController()
        }
    }
    
    @IBAction func extrasButton(_ sender: Any) {
        let index = pageVC?.modelController.currentPageIndex
        if let drop = photosToShow?[index!] as? Drop {
            if drop.username == UserInfo.username && drop.userID == UserInfo.id {
                popupAlert(title: nil, message: nil, alertStyle: .actionSheet, actionTitles: ["Delete Drop?"], actions: [{ (action1) in
                    self.popupAlert(title: nil, message: nil, alertStyle: .actionSheet, actionTitles: ["Yes, I want to delete it"], actions: [{ (delete) in
                        DropContentAPI().deleteDrop(userID: UserInfo.id, drop: drop,successClosure: { [weak self] in
                            self?.delegate?.deleteDrop(drop: drop)
                            }, failureClosure: { [weak self] (error) in
                                self?.alert("ERROR", message: error)
                        })
                        }])
                    }])
            } else {
                popupAlert(title: nil, message: nil, alertStyle: .actionSheet, actionTitles: ["Report"], actions: [{ (report) in
                        self.popupAlert(title: nil, message: nil, alertStyle: .actionSheet, actionTitles: ["Spam", "Inappropriate"], actions: [{ (spam) in
                            DropContentAPI().createComplaint(drop: drop, reason: "Spam", successClosure: { [weak self] in
                                self?.alert("", message: "Thank you for your feedback")
                                }, failureClosure: { [weak self] (error) in
                                    self?.alert("ERROR", message: error)
                            })
                            }, { (inappropriate) in
                                DropContentAPI().createComplaint(drop: drop, reason: "Inappropriate", successClosure: { [weak self] in
                                    self?.alert("", message: "Thank you for your feedback")
                                    }, failureClosure: { [weak self] (error) in
                                        self?.alert("ERROR", message: error)
                                })
                            }])
                }])
            }
        }
    }
    
    @IBAction func dismissVC(_ sender: DismissButton) {
        if let delegate = delegate {
            delegate.didFinishShowMedia(seenMedia: seenDrops, totalDrops: photosToShow as! [Drop])
        }
    }
    
    func popupAlert(title: String?, message: String?, alertStyle: UIAlertControllerStyle, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        alert.view.tintColor = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 85.0/255.0, alpha:1.0)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alert (_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.view.tintColor = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 85.0/255.0, alpha:1.0)
        let ok = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}

extension MediaPreviewDrops: PageViewControllerDelegate {
    
    func displayPageViewController(_ displayPageViewController: PageVC,
                                didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func displayPageViewController(_ displayPageViewController: PageVC,
                                didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
        self.updateContentVisibility(index: index)
    }
}
