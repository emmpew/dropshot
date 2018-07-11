//
//  UserInfo.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 4/10/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation

class UserInfo {
    
    static var deviceToken: String {
        get {
            return UserDefaults.standard.value(forKey: "deviceToken") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "deviceToken")
        }
    }
    
    static var id: String {
        get {
            return UserDefaults.standard.value(forKey: "userId") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userId")
        }
    }
    
    static var token: String {
        get {
            return UserDefaults.standard.value(forKey: "token") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "token")
        }
    }
    
    static var username: String {
        get {
            return UserDefaults.standard.value(forKey: "username") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "username")
        }
    }
    
    static var displayName: String {
        get {
            return UserDefaults.standard.value(forKey: "displayName") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "displayName")
        }
    }
    
    static var email: String {
        get {
            return UserDefaults.standard.value(forKey: "email") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "email")
        }
    }
    
    static var getURL: String {
        get {
            return UserDefaults.standard.value(forKey: "getURL") as! String
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "getURL")
        }
    }
    
    static var profileImageData: Data {
        get {
            return UserDefaults.standard.value(forKey: "profileData") as! Data
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "profileData")
        }
    }
    
    static var totalBadgeCount: Int {
        get {
            return UserDefaults.standard.value(forKey: "totalBadgeCount") as! Int
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "totalBadgeCount")
        }
    }
    
    static var failedDrop: Bool {
        get {
            return UserDefaults.standard.value(forKey: "failedDrop") as! Bool
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "failedDrop")
        }
    }
}
