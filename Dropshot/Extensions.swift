//
//  Extensions.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import UIKit

// change color of alert controllers
extension UIView
{
    func searchVisualEffectsSubview() -> UIVisualEffectView?
    {
        if let visualEffectView = self as? UIVisualEffectView
        {
            return visualEffectView
        }
        else
        {
            for subview in subviews
            {
                if let found = subview.searchVisualEffectsSubview()
                {
                    return found
                }
            }
        }
        return nil
    }
}

extension UIViewController {
    
    func alertView(message:String, window: UIWindow, color:UIColor, delay: Double) {
        
        // Creation of new Info View
        let alert = self.createTopAlertBox(message: message, window: window, color: color)
        
        //Add new view to the window
        window.addSubview(alert)
        
        // animate info view
        UIView.animate(withDuration: 0.2, animations: {
            // move down infoView
            alert.frame.origin.y = 0
            // if animation did finish
        }, completion: { (finished:Bool) in
            // if it is true
            if finished {
                self.hideTopAlert(alert, delay: delay, animated: true)
            }
        })
    }
    
    private func createTopAlertBox(message:String, window: UIWindow, color:UIColor) -> UIView {
        let infoView_Height = window.bounds.height / 14.2
        let infoView_Y = 0 - infoView_Height
        
        //Creation of the Info View
        let infoView = UIView(frame: CGRect(x: 0, y: infoView_Y, width: window.bounds.width, height: infoView_Height))
        infoView.backgroundColor = color
        
        // infoView - label to show info text
        let infoLabel_Width = infoView.bounds.width
        let infoLabel_Height = infoView.bounds.height + UIApplication.shared.statusBarFrame.height / 2
        
        let infoLabel = UILabel()
        infoLabel.frame.size.width = infoLabel_Width
        infoLabel.frame.size.height = infoLabel_Height
        infoLabel.numberOfLines = 0
        
        infoLabel.text = message
        infoLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        infoLabel.textColor = .white
        infoLabel.textAlignment = .center
        infoView.addSubview(infoLabel)
        
        return infoView
    }
    
    private func hideTopAlert(_ view: UIView, delay: Double, animated:Bool ) {
        if animated {
            UIView.animate(withDuration: 0.10, delay: delay, animations: {
                view.frame.origin.y = -view.frame.size.height
            }, completion: { (finished) in
                view.removeFromSuperview()
                view.removeFromSuperview()
            })
        }
        else {
            view.removeFromSuperview()
            view.removeFromSuperview()
        }
    }
}

public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone7":                                 return "iPhone 7"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
