//
//  SignUpAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SignUpAPI {
    
    func signInCredentials(endpoint: String, username: String, password: String, token: String, successClosure: @escaping (User) -> (), failureClosure: @escaping (String) -> ()) {
        let params = [
            "deviceToken": token,
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
                        user.email = json["email"].string!
                        user.displayName = json["displayName"].string!
                        user.token = json["token"].string!
                        user.userId = json["userId"].string!
                        user.userBadgeCount = json["badgeCount"].int
                        if let imageURL = json["getURL"].string {
                            user.getURL = imageURL
                        }
                        
                        successClosure(user)
                        return
                    }
                case .failure(_ ):
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
    
    func signUpCredentials(endpoint: String, email: String, password: String, username: String, diplayName: String, token: String, successClosure: @escaping (User) -> (), failureClosure: @escaping (String) -> ()) {
        let params = [
            "email": email,
            "password": password,
            "displayName": diplayName,
            "username": username,
            "deviceToken": token,
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
                        user.email = json["email"].string!
                        user.displayName = json["displayName"].string!
                        user.token = json["token"].string!
                        user.userId = json["userId"].string!
                        user.userBadgeCount = 0
                        
                        successClosure(user)
                    }
                case .failure(_):
                    if let httpStatusCode = response.response?.statusCode {
                        switch(httpStatusCode) {
                        case 500:
                            failureClosure("Username is taken. Please pick a different one")
                        default:
                            failureClosure("Something went wrong")
                            break
                        }
                    }
                    return
                }
        }
    }
}

