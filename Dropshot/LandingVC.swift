//
//  LandingVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class LandingVC: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var logInBtn: UIButton!
    
    var pageViewController: UIPageViewController!
    var pageImages = [String]()
    var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.view.layoutIfNeeded()
        signUpBtn.backgroundColor = colorRemBlue
        pageImages = ["Login111", "Login222", "Login333"]
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        let initialVC = self.viewControllerAtIndex(index: 0)
        let viewControllers = NSArray(object: initialVC)
        pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height - 80)
        self.addChildViewController(pageViewController)
        self.view.addSubview(pageViewController.view)
        pageViewController.didMove(toParentViewController: self)
    }
    
    func viewControllerAtIndex(index: Int) -> SwipeContentVC {
        if pageImages.count == 0 || index >= pageImages.count {
            return SwipeContentVC()
        }
        let contentVC: SwipeContentVC = self.storyboard?.instantiateViewController(withIdentifier: "SwipeContentVC") as! SwipeContentVC
        contentVC.imageFile = pageImages[index]
        contentVC.pageIndex = index
        return contentVC
    }
    
    //MARK:- Page View Controller
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let contentVC = viewController as! SwipeContentVC
        var index = contentVC.pageIndex as Int
        if index == NSNotFound {
            return nil
        }
        index += 1
        if index == self.pageImages.count {
            return nil
        }
        return self.viewControllerAtIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let contentVC = viewController as! SwipeContentVC
        var index = contentVC.pageIndex as Int
        if index == 0 || index == NSNotFound {
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index: index)
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageImages.count
    }
}

