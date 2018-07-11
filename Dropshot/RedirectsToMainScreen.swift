//
//  RedirectsToMainScreen.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

protocol RedirectsToMainScreen {
    
}

extension RedirectsToMainScreen {
    
    func goToMain () {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let mainVC = mainStoryboard.instantiateViewController(withIdentifier: "MainVC") as! MainVC
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = appDelegate.window
        let nav: UINavigationController = UINavigationController(rootViewController: mainVC)
        nav.navigationBar.isHidden = true
        DispatchQueue.main.async {
            UIView.transition(with: window!, duration: 0.2, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                window?.rootViewController = nav
            }, completion: nil)
        }
    }
}

