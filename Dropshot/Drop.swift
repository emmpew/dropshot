//
//  Drop.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit
import AVFoundation

open class Drop: NSObject {
    
    var _coordinate: CLLocationCoordinate2D
    dynamic open var coordinate: CLLocationCoordinate2D {
        get { return _coordinate }
    }
    
    open var seen: String? {
        get { return getSeen() }
    }
    
    open var title: String?
    var username: String
    var contentURL: String?
    var typeOfFile: String
    var seenBy: [String]
    var id: String
    var userID: String
    var date: Date
    
    var completed: Bool?
    var failed: Int?
    var data: Data?
    var dataStringURL: String?
    
    var media: Media?
    var image: UIImage?
    //var video: URL?
    
    init(title: String, username: String, typeOfFile: String, seenBy: [String], id: String, userID: String, date: Date, coordinate: CLLocationCoordinate2D) {
        self._coordinate = coordinate
        self.title = title
        self.username = username
        self.typeOfFile = typeOfFile
        self.seenBy = seenBy
        self.id = id
        self.userID = userID
        self.date = date
    }
    
}

extension Drop: MKAnnotation {
    
    func setCoordinate(_ newCoordinate: CLLocationCoordinate2D) {
        self._coordinate = newCoordinate
    }
    
    fileprivate func getSeen() -> String {
        
        if seenBy.contains(UserInfo.username) {
            return "true"
        } else {
            return "false"
        }
    }
}
