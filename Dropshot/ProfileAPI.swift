//
//  ProfileAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileAPI {
    
    static func uploadUserImage(imageData: Data, url: String, successClosure: @escaping (String) -> (), failureClosure: @escaping (String) -> ()) {
        Alamofire.upload(imageData, to: url, method: .put, headers: ["Content-Type":"image/jpeg"]).response { response in
            if response.error == nil {
                DispatchQueue.main.async {
                    successClosure("success")
                }
            } else {
                DispatchQueue.main.async {
                    if let err = response.error?.localizedDescription {
                        failureClosure(err)
                    }
                }
            }
        }
    }
    
    func saveProfileImage(image: UIImage, successClosure: @escaping (String) -> (), failureClosure: @escaping (String) -> ()) {
        
        let url = APIEndpoints.changeProfilePicture(currentUserID: UserInfo.id)
        let avaData = UIImageJPEGRepresentation(image, 0.4)
        
        Alamofire.request(url, method: .patch, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    if let value = response.result.value {
                        let json = JSON(value)
                        if let imageURL = json["getURL"].string {
                            UserInfo.getURL = imageURL
                        }
                        
                        if let postURL = json["postURL"].string {
                            if let image = avaData {
                                ProfileAPI.uploadUserImage(imageData: image, url: postURL, successClosure: successClosure, failureClosure: failureClosure)
                                return
                            }
                        }
                    }
                case.failure(let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                    return
                }
        }
    }

}
