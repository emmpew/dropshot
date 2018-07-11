//
//  BlankNavVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class BlankNavVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Override point for customization after application launch.
        //Sets background to a blank/empty image
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        // Sets shadow (line below the bar) to a blank image
        UINavigationBar.appearance().shadowImage = UIImage()
        // Sets the translucent background color
        UINavigationBar.appearance().backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        // Set translucent. (Default value is already true, so this can be removed if desired.)
        UINavigationBar.appearance().isTranslucent = true
        //hide top bar when swipe
        
        UINavigationBar.appearance().tintColor = UIColor.black
    }

}
