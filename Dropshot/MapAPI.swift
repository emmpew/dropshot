//
//  MapAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import Alamofire
import SwiftyJSON

class MapAPI {
    
    func testConnection(url: String, successClosure: @escaping (Bool) -> (), failureClosure: @escaping (String) -> ()) {
        Alamofire.request(url).response { response in
            if (response.error != nil) {
                if let error = response.error?.localizedDescription {
                    failureClosure(error)
                }
            } else {
                successClosure(true)
            }
        }
    }
    
    func checkIfUserHasSeenDrop (currentUser: String, dropArray: [String], successClosure:  (() -> ())?, failureClosure: @escaping (String) -> ()) {
        
        let params = [
            "currentUsername": currentUser,
            "idArray": dropArray
        ] as [String : Any]
        
        let url = APIEndpoints.addSeenByURL(currentUserID: UserInfo.id)
        
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success(_):
                    successClosure?()
                    return
                case.failure(let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                    return
                }
        }
    }
    
    func deleteDrop(userID: String, dropID: String, successClosure: (()->())?, failureClosure: @escaping (String) -> ()) {
        let url = APIEndpoints.deleteDropURL(userID: userID, dropID: dropID)
        Alamofire.request(url, method: .delete, encoding: JSONEncoding.default, headers: ["authorization": UserInfo.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                
                switch response.result {
                case .success(_):
                    successClosure?()
                    return
                    
                case .failure (let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                    return
                }
        }
    }
    
    func queryDrops(currentUser: String, token: String, id: String, successClosure: @escaping ([Drop]) -> (), failureClosure: @escaping (String) -> ()) {
        let url = APIEndpoints.queryFriendsDrops(id: id)
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: ["authorization": token])
            .validate(statusCode: 200..<300)
            .responseJSON { [weak self] response in
                switch response.result {
                case .success(_):
                    var dropsArray = [Drop]()
                    if let value = response.result.value {
                        let json = JSON(value)
                        for (_, object) in json["post"] {
                            let username = object["username"].string
                            let displayName = object["displayName"].string
                            let contentURL = object["contentURL"].string
                            let completed = object["completed"].bool 
                            let typeOfFile = object["typeFile"].string
                            let userID = object["userID"].string
                            let id = object["_id"].string
                            let seenBy = object["seenBy"].arrayObject
                            let createdAt = object["createdAt"].string
                            let lat = object["lat"].doubleValue
                            let lon = object["lon"].doubleValue
                            
                            let date = self?.stringToDate(date: createdAt!)
                            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))

                            let drop = Drop(title: (displayName?.isEmpty)! ? username! : displayName!, username: username!, typeOfFile: typeOfFile!, seenBy: seenBy as! [String], id: id!, userID: userID!, date: date!, coordinate: coordinate)
                            drop.contentURL = contentURL
                            drop.completed = completed
                            
                            dropsArray.append(drop)
                        }
                    }
                    successClosure(dropsArray)
                    return
                case.failure(let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                    return
                }
        }
    }
    
    //Mark:- Upload
    
    func scaleUIImageToSize(_ image: UIImage, size: CGSize) -> UIImage {
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    static func uploadCompleted(userID: String, uploadID: String, drop: Drop, successClosure: @escaping (Drop)->(), failureClosure: @escaping (Int, Drop?) -> ()) {
        let url = APIEndpoints.completeUpload(userID: userID, postID: uploadID)
        Alamofire.request(url, method: .patch, encoding: JSONEncoding.default, headers: ["authorization": UserInfo.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    DispatchQueue.main.async {
                        successClosure(drop)
                    }
                    return
                case .failure (_ ):
                    failureClosure(2, drop)
                    return
                }
        }
    }
    
    static func uploadImageToS3(image: UIImage, url: String, drop: Drop, successClosure: @escaping (Drop) -> (), failureClosure: @escaping (Int, Drop?) -> ()) {
        
        let scaledImage = MapAPI().scaleUIImageToSize(image, size: CGSize(width: (image.size.width), height: (image.size.height)))
        let imageData = UIImageJPEGRepresentation(scaledImage, 0.5)!
        
        Alamofire.upload(imageData, to: url, method: .put, headers: ["Content-Type":"image/jpeg"]).response { response in
            
            if response.error == nil {
                DispatchQueue.main.async {
                    MapAPI.uploadCompleted(userID: UserInfo.id, uploadID: drop.id, drop: drop, successClosure: successClosure, failureClosure: failureClosure)
                }
            } else {
                DispatchQueue.main.async {
                    failureClosure(1, drop)
                }
            }
        }
    }
    
    
    func saveImageDrop (endpoint: String, username: String, displayName: String, image: UIImage, userID: String, lat: Double, lon: Double, successClosure: @escaping (Drop) -> (), failureClosure: @escaping (Int, Drop?) -> ()) {
        let params = [
            "username": username,
            "displayName": displayName,
            "typeFile": "picture",
            "userID": userID,
            "lat": lat,
            "lon": lon
            ] as [String : Any]
        
        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        let username = json["username"].string
                        let displayName = json["displayName"].string
                        let contentURL = json["contentURL"].string
                        let dataURL = json["dataURL"].string
                        let typeOfFile = json["typeFile"].string
                        let userID = json["userID"].string
                        let id = json["id"].string
                        let seenBy = json["seenBy"].arrayObject
                        let createdAt = json["createdAt"].string
                        let lat = json["lat"].doubleValue
                        let lon = json["lon"].doubleValue
                        let completed = json["completed"].bool
                        let date = self.stringToDate(date: createdAt!)
                        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
                        
                        let drop = Drop(title: (displayName?.isEmpty)! ? username! : displayName!, username: username!, typeOfFile: typeOfFile!, seenBy: seenBy as! [String], id: id!, userID: userID!, date: date, coordinate: coordinate)
                        drop.contentURL = contentURL
                        drop.completed = completed
                        drop.dataStringURL = dataURL
                        
                        MapAPI.uploadImageToS3(image: image, url: dataURL!, drop: drop, successClosure: successClosure, failureClosure: failureClosure)
                    }
                case .failure(_ ):
                    failureClosure(0, nil)
                    return
                }
        }
    }
    
    static func uploadVideoToS3(videoDataURL: URL, url: String, drop: Drop, successClosure: @escaping (Drop) -> (), failureClosure: @escaping (Int, Drop?) -> ()) {
        
        let dataURL = try? Data(contentsOf: videoDataURL)
        if let data = dataURL {
            Alamofire.upload(data, to: url, method: .put, headers: ["Content-Type":"video/mp4"]).response { response in
                
                if response.error == nil {
                    DispatchQueue.main.async {
                        MapAPI.uploadCompleted(userID: UserInfo.id, uploadID: drop.id, drop: drop, successClosure: successClosure, failureClosure: failureClosure)
                    }
                } else {
                    DispatchQueue.main.async {
                        failureClosure(1, drop)
                    }
                }
            }
        } else {
            failureClosure(1, drop)
        }
    }
    
    func saveVideoDrop (endpoint: String, username: String, displayName: String, url: URL, userID: String, lat: Double, lon: Double, successClosure: @escaping (Drop) -> (), failureClosure: @escaping (Int, Drop?) -> ()) {
        let params = [
            "username": username,
            "displayName": displayName,
            "typeFile": "video",
            "userID": userID,
            "lat": lat,
            "lon": lon
            ] as [String : Any]
        
        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    if let value = response.result.value {
                        let json = JSON(value)
                        
                        let username = json["username"].string
                        let displayName = json["displayName"].string
                        let contentURL = json["contentURL"].string
                        let dataURL = json["dataURL"].string
                        let typeOfFile = json["typeFile"].string
                        let userID = json["userID"].string
                        let id = json["id"].string
                        let seenBy = json["seenBy"].arrayObject
                        let createdAt = json["createdAt"].string
                        let lat = json["lat"].doubleValue
                        let lon = json["lon"].doubleValue
                        let completed = json["completed"].bool
                        let date = self.stringToDate(date: createdAt!)
                        let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lon))
                        
                        let drop = Drop(title: (displayName?.isEmpty)! ? username! : displayName!, username: username!, typeOfFile: typeOfFile!, seenBy: seenBy as! [String], id: id!, userID: userID!, date: date, coordinate: coordinate)
                        drop.contentURL = contentURL
                        drop.completed = completed
                        drop.dataStringURL = dataURL
                        
                        MapAPI.uploadVideoToS3(videoDataURL: url, url: dataURL!, drop: drop, successClosure: successClosure, failureClosure: failureClosure)
                    }
                case .failure(_ ):
                    failureClosure(0, nil)
                    return
                }
        }
    }
    
    func stringToDate(date:String) -> Date {
        let formatter = DateFormatter()
        // Format 1
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date)
        return parsedDate!
    }
    
}
