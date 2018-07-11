//
//  FriendsPopUpAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FriendsPopUpAPI {
    
    func getRelationshipStatus(friendsUsername: String, successClosure: @escaping (FriendshipModel) -> (), failureClosure: @escaping (String) -> ()) {
        let url = APIEndpoints.searchStatus(userID: UserInfo.id, friendsUsername: friendsUsername)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: ["authorization": UserInfo.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    var friendship = FriendshipModel()
                    if let value = response.result.value {
                        let json = JSON(value)
                        for (_, object) in json["status"] {
                            let status = object["status"].string
                            let friendsUser = object["friendsUsername"].string
                            if status == "waiting" && friendsUser == UserInfo.username {
                                friendship.status = .acceptNow
                                if let request = object["_id"].string {
                                    friendship.requestID = request
                                }
                            } else if status == "waiting" {
                                friendship.status = .waiting
                            } else if status == "accepted" {
                                friendship.status = .accepted
                            }
                        }
                        successClosure(friendship)
                        return
                    }
                case.failure(let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                    return
                }
        }
    }
    
    func addUser(username: String, currentUserID: String, currentUserDisplayName: String, friendID: String, friendUsername: String, profileImageURL: String, deviceToken: String, successClosure: (() -> ())?, failureClosure: @escaping (String) -> ()) {
        let params = [
            "friendsID": friendID,
            "friendsUsername": friendUsername,
            "currentUser": username,
            "currentUserID": currentUserID,
            "currentUserDisplayName": currentUserDisplayName,
            "profileImageURL": profileImageURL,
            "deviceToken": deviceToken
        ]
        
        let url = APIEndpoints.getFriendsRequest(currentUserID: UserInfo.id)
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default)
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
