//
//  DismissButton.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class DismissButton: UIButton {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buttonStyle()
    }
    
    override func awakeFromNib() {
        buttonStyle()
    }
    
    func buttonStyle() {
        
        self.layoutIfNeeded()
        
        //color
        self.layer.backgroundColor = colorPurpleHaze.cgColor
        self.layer.borderColor = UIColor.white.cgColor
        self.setTitleColor(.white, for: UIControlState())
        
        //dimensions
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = self.layer.bounds.size.width / 2
        self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/4)
        
        //text
        self.setTitle("+", for: UIControlState())
    }
    
}

