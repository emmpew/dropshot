//
//  Helper.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import UIKit

class Helper {
    
    static func popupAlert(title: String?, message: String?, alertStyle: UIAlertControllerStyle, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        alert.view.tintColor = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 85.0/255.0, alpha:1.0)
        for (index, title) in actionTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default, handler: actions[index])
            alert.addAction(action)
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }
    
    static func setAnimationView(view: UIView, hidden: Bool) {
        UIView.transition(with: view, duration: 0.6, options: .transitionCrossDissolve, animations: {
            view.isHidden = hidden
        }) { (_) in
            
        }
    }
    
    static func alertWithNoCancel(_ title: String, message: String, buttonAction: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let settings = UIAlertAction(title: buttonAction, style: .default) { (_) in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
        
        alert.addAction(settings)
        return alert
    }
    
    static func alertToSettings(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .cancel)
        let settings = UIAlertAction(title: "Settings", style: .default) { (_) in
            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
        alert.addAction(settings)
        alert.addAction(ok)
        DispatchQueue.main.async {
            topMostController().present(alert, animated: false, completion: nil)
        }
    }
    
    static func topMostController() -> UIViewController {
        var topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }
}
