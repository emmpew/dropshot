//
//  RedirectsToWelcomeScreen.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

protocol RedirectsToWelcomeScreen {
    
}

extension RedirectsToWelcomeScreen {
    
    func goToWelcomeScreen() {
        let storyboard = UIStoryboard(name: "Welcome", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "LandingVC")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        window?.rootViewController = viewController
    }
}
