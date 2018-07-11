//
//  APIEndpoints.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation

class APIEndpoints {
    
    private static let baseURL = "http://dropshot.co/v1"
    
    //AppDelegate
    
    static func addDeviceToken (currentUserID: String) -> String {
        return "\(baseURL)/addDeviceToken/\(currentUserID)/"
    }
    
    //Log In
    
    static let signupURL = "\(baseURL)/signupuser"
    static let signinURL = "\(baseURL)/signinuser"
    
    //Main
    
    static func queryFriendsDrops (id: String) -> String {
        return "\(baseURL)/queryFriendsDrops/\(id)"
    }
    
    static func deleteDropURL (userID: String, dropID: String) -> String {
        return "\(baseURL)/users/\(userID)/deleteDrop/\(dropID)"
    }
    
    static func addSeenByURL (currentUserID: String) -> String {
        return "\(baseURL)/addSeenBy/\(currentUserID)"
    }
    
    static func completeUpload (userID: String, postID: String) -> String {
        return "\(baseURL)/users/\(userID)/uploadCompleted/\(postID)"
    }
    
    //Camera
    
    static let uploadContentURL = "\(baseURL)/uploadContent"
    
    static let uploadVideoURL = "\(baseURL)/uploadVideos"
    
    //Profile
    
    static func changeProfilePicture (currentUserID: String) -> String {
        return "\(baseURL)/changeProfilePicture/\(currentUserID)"
    }
    
    //Friendship
    
    static func getFriendsRequest (currentUserID: String) -> String {
        return "\(baseURL)/accessFriendshipCollection/\(currentUserID)"
    }
    
    static func getCountRequest (currentUserID: String) -> String {
        return "\(baseURL)/getCountRequest/\(currentUserID)"
    }
    
    static func searchUser (word: String, currentUser: String) -> String {
        return "\(baseURL)/searchUsers/\(word)/\(currentUser)"
    }
    
    static func searchStatus (userID: String, friendsUsername: String) -> String {
        return "\(baseURL)/searchStatus/\(userID)/\(friendsUsername)"
    }
    
    static func getAllFriends (currentUserID: String) -> String {
        return "\(baseURL)/retrieveAllFriends/\(currentUserID)/"
    }
    
    //Report Drops
    
    static func reportDrop (currentUserID: String) -> String {
        return "\(baseURL)/reportUpload/\(currentUserID)"
    }
    
    //Settings
    
    static let checkCurrentPassword = "\(baseURL)/checkCurrentPassword"
    
    static func changeUserInfo (currentUserID: String, updateEntry: String) -> String {
        if updateEntry == "email" {
            return "\(baseURL)/changeUserEmail/\(currentUserID)"
        } else if updateEntry == "displayName" {
            return "\(baseURL)/changeDisplayName/\(currentUserID)"
        } else {
            return "\(baseURL)/changePassword/\(currentUserID)"
        }
    }
}
