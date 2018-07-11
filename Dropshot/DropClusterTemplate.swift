//
//  DropClusterTemplate.swift
//  ClusteringTrial3
//
//  Created by Andrew Castellanos on 11/21/16.
//  Copyright © 2016 Andrew. All rights reserved.
///

import Foundation
import UIKit

public enum DropClusterDisplayMode {
    case SolidColor(sideLength: CGFloat, color: UIColor)
    case Image(imageName: String)
}

public struct DropClusterTemplate {
    
    let range: Range<Int>?
    let displayMode: DropClusterDisplayMode
    
    public var borderWidth: CGFloat = 0
    
    public var fontSize: CGFloat = 15
    public var fontName: String?
    
    public var font: UIFont? {
        if let fontName = fontName {
            return UIFont(name: fontName, size: fontSize)
        } else {
            return UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
    
    public init(range: Range<Int>?, displayMode: DropClusterDisplayMode) {
        self.range = range
        self.displayMode = displayMode
    }
    
    public init (range: Range<Int>?, sideLength: CGFloat) {
        self.init(range: range, displayMode: .SolidColor(sideLength: sideLength, color: UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 100.0/255.0, alpha: 1.0)))
    }
}

