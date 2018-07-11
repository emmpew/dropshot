//
//  SearchUserAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class SearchUserAPI {
    
    func searchUsers(currentUser: String, word: String, successClosure: @escaping ([SearchedUser]) -> (), failureClosure: @escaping (String) -> ()) {
        let url = APIEndpoints.searchUser(word: word, currentUser: currentUser)
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default, headers: ["authorization": UserInfo.token])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    var searchResult = [SearchedUser]()
                    if let value = response.result.value {
                        let json = JSON(value)
                        for (_, object) in json["searchResult"] {
                            var user = SearchedUser()
                            
                            let username = object["username"].string
                            let profileImage = object["imageURL"].string
                            let id = object["_id"].string
                            let deviceToken = object["deviceToken"].string
                            let displayName = object["displayName"].string
                            
                            user.displayName = displayName
                            user.username = username
                            user.imageURL = profileImage
                            user.id = id
                            user.deviceToken = deviceToken
                            searchResult.append(user)
                        }
                        successClosure(searchResult)
                        return
                    }
                case.failure(let error):
                    let err = error.localizedDescription
                    failureClosure(err)
                    return
                }
        }
    }
}
