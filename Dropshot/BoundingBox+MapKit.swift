//
//  BoundingBox+MapKit.swift
//  ClusteringTrial3
//
//  Created by Andrew Castellanos on 11/21/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import MapKit
import UIKit

extension BoundingBox {
    init(mapRect: MKMapRect) {
        let topLeft = MKCoordinateForMapPoint(mapRect.origin)
        let bottomRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)))
        
        let minLat = bottomRight.latitude
        let maxLat = topLeft.latitude
        
        let minLon = topLeft.longitude
        let maxLon = bottomRight.longitude
        
        self.init(x0: CGFloat(minLat), y0: CGFloat(minLon), xf: CGFloat(maxLat), yf: CGFloat(maxLon))
    }
    
    func contains(coordinate: CLLocationCoordinate2D) -> Bool {
        let containsX = (x0 <= CGFloat(coordinate.latitude)) && (CGFloat(coordinate.latitude) <= xf)
        let containsY = (y0 <= CGFloat(coordinate.longitude)) && (CGFloat(coordinate.longitude) <= yf)
        return (containsX && containsY)
    }
    
    func mapRect() -> MKMapRect {
        let topLeft  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(x0), CLLocationDegrees(y0)))
        let botRight  = MKMapPointForCoordinate(CLLocationCoordinate2DMake(CLLocationDegrees(xf), CLLocationDegrees(yf)))
        return MKMapRectMake(topLeft.x, botRight.y, fabs(botRight.x - topLeft.x), fabs(botRight.y - topLeft.y))
    }
}
