//
//  PageVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 3/6/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

protocol PageViewControllerDelegate: class {
    func displayPageViewController(_ displayPageViewController: PageVC, didUpdatePageCount count: Int)
    func displayPageViewController(_ displayPageViewController: PageVC, didUpdatePageIndex index: Int)
}

class PageVC: UIPageViewController, UIPageViewControllerDelegate {

    weak var displayDelegate: PageViewControllerDelegate?
    var contentArray: NSArray?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.modelController.pageData = self.contentArray
        
        // Create the model and set it as the data source
        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })
        self.dataSource = self.modelController
        
        displayDelegate?.displayPageViewController(self, didUpdatePageCount: self.modelController.getNumberOfPageData())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        displayDelegate?.displayPageViewController(self, didUpdatePageIndex: self.currentIndex())
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var _modelController: ModelController? = nil
    var modelController: ModelController {
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }
    
    func currentIndex () -> Int {
        return self.modelController.currentPageIndex!
    }
    
    fileprivate func notifyDelegateOfNewIndex() {
        displayDelegate?.displayPageViewController(self,didUpdatePageIndex: self.currentIndex())
    }
    
    fileprivate func scrollToViewController(_ viewController: UIViewController,
                                            direction: UIPageViewControllerNavigationDirection = .forward) {
        setViewControllers([viewController],
                           direction: direction,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyDelegateOfNewIndex()
        })
    }
    
    func scrollToViewController(index newIndex: Int) {
        if let firstViewController = viewControllers?.first,
            let currentIndex = self.viewControllers?.index(of: firstViewController) {
            let direction: UIPageViewControllerNavigationDirection = newIndex >= currentIndex ? .forward : .reverse
            let nextViewController = self.viewControllers?[newIndex]
            scrollToViewController(nextViewController!, direction: direction)
        }
    }
    
    func scrollToNextViewController(){
        if let visibleViewController = viewControllers?.first,
            let nextViewController = self.modelController.pageViewController(self, viewControllerAfter: visibleViewController) {
            scrollToViewController(nextViewController)
        }
    }
    
    func scrollToPreviousViewController(){
        if let visibleViewController = viewControllers?.first,
            let previousViewController = self.modelController.pageViewController(self, viewControllerBefore: visibleViewController) {
            scrollToViewController(previousViewController, direction: .reverse)
        }
    }
}
