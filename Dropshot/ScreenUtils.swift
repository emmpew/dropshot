//
//  ScreenUtils.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

open class ScreenUtils {
    
    open static let screenSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    
    // Allow you to take a screenshot of the screen
    open static func screenShot(_ view: UIView?) -> UIImage? {
        guard let imageView = view else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, true, 0.0)
        imageView.drawHierarchy(in: imageView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
}
