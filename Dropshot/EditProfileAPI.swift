//
//  EditProfileAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class EditProfileAPI {
    
    func changeUserInfo(updateEntry: String, newInfo: String, successClosure: (() -> ())?, failureClosure: @escaping (String) -> ()) {
        let params = [
            "newInfo" : newInfo
        ]
        
        let url = APIEndpoints.changeUserInfo(currentUserID: UserInfo.id, updateEntry: updateEntry)
        
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "reload"), object: nil)
                    successClosure?()
                    return
                case.failure(let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                    return
                }
        }
    }
    
    func checkCurrentPassword(endpoint: String, username: String, password: String, successClosure: @escaping (User) -> (), failureClosure: @escaping (String) -> ()) {
        let params = [
            "username": username,
            "password": password
        ]
        Alamofire.request(endpoint, method: .post, parameters: params, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success( _):
                    if let value = response.result.value {
                        let json = JSON(value)
                        let user = User()
                        user.username = json["username"].string!
                        user.userId = json["userId"].string!
                        
                        successClosure(user)
                        return
                    }
                case .failure(_):
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 400:
                            failureClosure("Please provide your username/password")
                        case 401:
                            failureClosure("Invalid password/username")
                        default:
                            failureClosure("Connection error")
                            break
                        }
                    }
                    return
                }
        }
    }
}
