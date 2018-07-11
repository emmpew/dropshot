//
//  UIOutlinedLabel.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/14/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class UIOutlinedLabel: UILabel {
    
    var outlineWidth: CGFloat = 1.5
    var outlineColor: UIColor = UIColor.black
    
    override func drawText(in rect: CGRect) {
        
        let strokeTextAttributes = [
            NSAttributedStringKey.strokeColor.rawValue : outlineColor,
            NSAttributedStringKey.strokeWidth : -1 * outlineWidth,
            ] as! [String : Any]
        
        self.attributedText = NSAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
        super.drawText(in: rect)
    }
    
}
