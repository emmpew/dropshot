//
//  FriendshipStatusModel.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation

enum FriendshipStatus {
    case accepted
    case waiting
    case none
    case acceptNow
}

struct FriendshipModel {
    
    var requestID: String?
    var status: FriendshipStatus = .none
}
