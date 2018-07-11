//
//  DropClusterViewConfiguration.swift
//  ClusteringTrial3
//
//  Created by Andrew Castellanos on 11/21/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import UIKit

public struct DropClusterViewConfiguration {
    
    let templates: [DropClusterTemplate]
    let defaultTemplate: DropClusterTemplate
    
    public init (templates: [DropClusterTemplate], defaultTemplate: DropClusterTemplate) {
        self.templates = templates
        self.defaultTemplate = defaultTemplate
    }
    
    public static func `default`() -> DropClusterViewConfiguration {

        var smallTemplate = DropClusterTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 6)), sideLength: 30)
        smallTemplate.borderWidth = 0
        smallTemplate.fontSize = 13
        
        var mediumTemplate = DropClusterTemplate(range: Range(uncheckedBounds: (lower: 6, upper: 15)), sideLength: 40)
        mediumTemplate.borderWidth = 0
        mediumTemplate.fontSize = 14
        
        var largeTemplate = DropClusterTemplate(range: nil, sideLength: 50)
        largeTemplate.borderWidth = 0
        largeTemplate.fontSize = 15
        
        return DropClusterViewConfiguration(templates: [smallTemplate, mediumTemplate], defaultTemplate: largeTemplate)
    }
    
    public static func halfSeen() -> DropClusterViewConfiguration {
        
        var smallTemplate = DropClusterTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 6)), displayMode: .SolidColor(sideLength: 30, color: UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 100.0/255.0, alpha: 1.0)))
        smallTemplate.borderWidth = 4
        smallTemplate.fontSize = 13
        
        
        var mediumTemplate = DropClusterTemplate(range: Range(uncheckedBounds: (lower: 6, upper: 15)), displayMode: .SolidColor(sideLength: 40, color: UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 100.0/255.0, alpha: 1.0)))
        mediumTemplate.borderWidth = 5
        mediumTemplate.fontSize = 14
        
        var largeTemplate = DropClusterTemplate(range: nil, displayMode: .SolidColor(sideLength: 50, color: UIColor(red: 255.0/255.0, green: 75.0/255.0, blue: 100.0/255.0, alpha: 1.0)))
        largeTemplate.borderWidth = 6
        largeTemplate.fontSize = 15
        
        return DropClusterViewConfiguration(templates: [smallTemplate, mediumTemplate], defaultTemplate: largeTemplate)
    }
    
    public static func completelySeen() -> DropClusterViewConfiguration {
        
        var smallTemplate = DropClusterTemplate(range: Range(uncheckedBounds: (lower: 0, upper: 6)), displayMode: .SolidColor(sideLength: 30, color: .white))
        smallTemplate.borderWidth = 3
        smallTemplate.fontSize = 13
        
        var mediumTemplate = DropClusterTemplate(range: Range(uncheckedBounds: (lower: 6, upper: 15)), displayMode: .SolidColor(sideLength: 40, color: .white))
        mediumTemplate.borderWidth = 4
        mediumTemplate.fontSize = 14
        
        var largeTemplate = DropClusterTemplate(range: nil, displayMode: .SolidColor(sideLength: 50, color: .white))
        largeTemplate.borderWidth = 5
        largeTemplate.fontSize = 15
        
        return DropClusterViewConfiguration(templates: [smallTemplate, mediumTemplate], defaultTemplate: largeTemplate)
    }
    
    public func templateForCount(count: Int) -> DropClusterTemplate {
        for template in templates {
            if template.range?.contains(count) ?? false {
                return template
            }
        }
        return self.defaultTemplate
    }
    
}
