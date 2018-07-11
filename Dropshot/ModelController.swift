//
//  ModelController.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/14/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class ModelController: NSObject, UIPageViewControllerDataSource {

    var pageData: NSArray?
    var currentPageIndex: Int?
    
    override init() {
        super.init()
        currentPageIndex = 0
    }
    
    func getNumberOfPageData() -> Int {
        return self.pageData!.count
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> DataViewController? {
        // Return the data view controller for the given index
        if ((self.pageData?.count)! == 0) || (index >= (self.pageData?.count)!) {
            return nil
        }
        
        // Create a new view controller and pass the data you want to show
        let dataViewController = storyboard.instantiateViewController(withIdentifier: "DataViewController") as! DataViewController
        dataViewController.dataObject = (self.pageData![index] as! Drop)
        return dataViewController
    }
    
    func indexOfViewController(_ viewController: DataViewController) -> Int {
        if pageData == nil || viewController.dataObject == nil {
            return NSNotFound
        }
        return pageData!.index(of: viewController.dataObject!)
    }
    
    // MARK: - Page View Controller Data Source : can loop
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if (index == 0) || (index == NSNotFound) {
            return nil
        }
        
        index -= 1
        currentPageIndex = index
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = self.indexOfViewController(viewController as! DataViewController)
        if index == NSNotFound {
            return nil
        }
        
        index += 1
        currentPageIndex = index
        return self.viewControllerAtIndex(index, storyboard: viewController.storyboard!)
    }
}
