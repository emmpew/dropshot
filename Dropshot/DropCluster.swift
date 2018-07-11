//
//  DropCluster.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import MapKit

open class DropCluster: NSObject {
    
    fileprivate var _title: String = ""
    open var title: String? {
        get { return getTitle() }
    }
    
    fileprivate var _seen: Int = 1
    open var seen: Int? {
        get {
            return getSeen() }
    }
    
//    fileprivate var _failed: Int = 4
//    open var failed: Int? {
//        get {
//            return getCompleted() }
//    }
    
    open var coordinate = CLLocationCoordinate2D()
    open var subtitle: String?
    open var annotations: [Drop] = []
}

extension DropCluster: MKAnnotation {
    
    fileprivate func getTitle() -> String {
        if annotations.count > 0 {
            return "  \(annotations.count)"
        }
        return _title
    }
    
//    fileprivate func getCompleted() -> Int {
//        print("getting completed")
//        let filteredDrop = annotations.filter { $0.completed == false }
//        if let drop = filteredDrop.first {
//            if let failed = drop.failed {
//                switch failed {
//                case 0:
//                    return 0
//                case 1:
//                    return 1
//                case 2:
//                    return 2
//                default:
//                    break
//                }
//            }
//
//        }
//        return 4
//    }
    
    fileprivate func getSeen() -> Int {
        let username = UserInfo.username
        var seenArray = [String]()
        if annotations.count > 0 {
            for drop in annotations {
                let result: String
                if drop.seenBy.contains(username) {
                    result = username
                } else {
                    result = "0123no345@#$"
                }
                seenArray.append(result)
            }
            return seenArray.checkIfUserHasSeenDrop(value: username)
        }
        return _seen
    }
}

extension Array where Element : Equatable {
    
    func checkIfUserHasSeenDrop(value: Element) -> Int {
        if !contains { $0 != value } { //TODOS
            return 2
        } else if !contains { $0 == value } { //NADA
            return 1
        } else { // ALGUNOS
            return 0
        }
    }
}
