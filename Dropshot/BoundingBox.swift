//
//  BoundingBox.swift
//  ClusteringTrial3
//
//  Created by Andrew Castellanos on 11/21/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import UIKit

struct BoundingBox {
    let x0, y0, xf, yf: CGFloat
}

extension BoundingBox {
    
    var xMid: CGFloat {
        return (xf + x0) / 2.0
    }
    
    var yMid: CGFloat {
        return (yf + y0) / 2.0
    }
    
    func intersects(box2: BoundingBox) -> Bool {
        return (x0 <= box2.xf && xf >= box2.x0 && y0 <= box2.yf && yf >= box2.y0)
    }
    
}
