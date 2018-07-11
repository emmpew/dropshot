//
//  DropContentAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/14/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class DropContentAPI {
    
    func deleteDrop(userID: String, drop: Drop, successClosure: (()->())?, failureClosure: @escaping (String) -> ()) {
        
        let url = APIEndpoints.deleteDropURL(userID: userID, dropID: drop.id)
        
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
    
    func createComplaint (drop: Drop, reason: String, successClosure:  (() -> ())?, failureClosure: @escaping (String) -> ()) {
        
        let params = [
            "reportedById": UserInfo.id,
            "reportedByUsername": UserInfo.username,
            "uploadedByUser": drop.title!,
            "uploadedByUserId": drop.userID,
            "uploadId": drop.id,
            "uploadContentURL": drop.contentURL!,
            "reason": reason
        ]
        
        let url = APIEndpoints.reportDrop(currentUserID: UserInfo.id)
        
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: ["authorization": UserInfo.token])
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
}

