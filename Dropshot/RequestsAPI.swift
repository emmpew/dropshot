//
//  RequestsAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RequestsAPI {
    
    func getAllRequests(successClosure: @escaping ([RequestUser]) -> (), failureClosure: @escaping (String) -> ()) {
        
        let url = APIEndpoints.getFriendsRequest(currentUserID: UserInfo.id)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: ["authorization": UserInfo.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    var requestsArray = [RequestUser]()
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        for (_, object) in json["requests"] {
                            let username = object["currentUser"].string
                            let displayName = object["currentUserDisplayName"].string
                            let profileImageURL = object["profileImageURL"].string
                            let requestID = object["_id"].string
                            
                            let requests = RequestUser(username: username, displayName: displayName, imageFile: profileImageURL, requestID: requestID!, status: .acceptNow)
                            requestsArray.append(requests)
                        }
                    }
                    
                    successClosure(requestsArray)
                    return
                    
                case.failure(let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                    return
                }
        }
    }
    
    func acceptRequest(requestID: String, successClosure: (() -> ())?, failureClosure: @escaping (String) -> ()) {
        
        let params = [
            "requestID": requestID
        ]
        
        let url = APIEndpoints.getFriendsRequest(currentUserID: UserInfo.id)
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
    
}
