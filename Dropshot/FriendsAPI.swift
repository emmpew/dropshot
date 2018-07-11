//
//  FriendsAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class FriendsAPI {
    
    func getAllFriends(successClosure: @escaping ([Friends]) -> (), failureClosure: @escaping (String) -> ()) {
        
        let url = APIEndpoints.getAllFriends(currentUserID: UserInfo.id)
        
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: ["authorization": UserInfo.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    var friendsArray = [Friends]()
                    
                    if let value = response.result.value {
                        let json = JSON(value)
                        for (_, object) in json["friends"] {
                            let username = object["username"].string
                            let displayName = object["displayName"].string
                            let profileImageURL = object["imageURL"].string
                            
                            let friend = Friends(username: username, displayName: displayName, imageFile: profileImageURL)
                            friendsArray.append(friend)
                        }
                        
                    }
                    successClosure(friendsArray)
                    return
                    
                case.failure(let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                }
        }
    }
    
}
