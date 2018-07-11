//
//  LocManager.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import CoreLocation

public enum Authorization {
    case WhenInUseAuthorization
    case AlwaysAuthorization
}

public class LocationNotification: NSObject {
    
    public static let kLocationUpdated = "locationUpdated"
    public static let kAuthorizationStatusChanged = "authorizationStatusChanged"
    public static let kLocationManagerDidFailWithError = "Failed to retrieve location"
    public static let kNotificationDataKey = "data"
    public static let kLocationNotAvailable = "Location Authorization Not Available"
    
    let name: String
    let status: Int
    let statusMessage: String
    let latitude: Double
    let longitude: Double
    let error: NSError?
    
    init(name: String, status: Int, statusMessage: String, latitude: Double = 0.0, longitude: Double = 0.0, error: NSError? = nil) {
        self.name = name
        self.status = status
        self.statusMessage = statusMessage
        self.latitude = latitude
        self.longitude = longitude
        self.error = error
    }
    
}

public class LocManager: NSObject, CLLocationManagerDelegate {
    
    public static let sharedInstance = LocManager()
    
    public var debug = true
    public var isRunning = false
    
    private let locationManager = CLLocationManager()
    
    let statusAuthorization = [
        CLAuthorizationStatus.authorizedWhenInUse : "authorization when in use",
        CLAuthorizationStatus.authorizedAlways : "authorization always",
        CLAuthorizationStatus.notDetermined : "authorization not determined",
        CLAuthorizationStatus.denied : "authorization denied",
        CLAuthorizationStatus.restricted : "authorization restricted"
    ]
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func sendNotification(notification: LocationNotification) {
        
        var userInfo = [String : Any]()
        userInfo[LocationNotification.kNotificationDataKey] = notification
        
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: notification.name), object: self, userInfo: userInfo)
        
    }
    
    public func startUpdatingLocationWith(type: Authorization) {
        
        let status = authorizationStatus()
        
        guard status != .denied && status != .restricted else { return }
        
        if status == .notDetermined {
            switch type {
            case .WhenInUseAuthorization:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
        startUpdatingLocation()
        
    }
    
    private func startUpdatingLocation() {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        isRunning = true
    }
    
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        isRunning = false
    }
    
    public func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public func locationServicesEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    public func getLastLocation() -> CLLocation {
        
        let currLocation = locationManager.location!
        return currLocation
    }
    
    //MARK:- Location Manager Delegate Methods
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let arrayOfLocation = locations as NSArray
        let location = arrayOfLocation.lastObject as! CLLocation
        let coordLatLon = location.coordinate
        
        let status = authorizationStatus()
        
        isRunning = true
        
        let notification = LocationNotification(name: LocationNotification.kLocationUpdated, status: Int(status.rawValue), statusMessage: statusAuthorization[status]!, latitude: coordLatLon.latitude, longitude: coordLatLon.longitude)
        sendNotification(notification: notification)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways, .notDetermined:
            startUpdatingLocation()
            break
        case .denied, .restricted:
            stopUpdatingLocation()
            break
        }
        
        let notification = LocationNotification(name: LocationNotification.kAuthorizationStatusChanged, status: Int(status.rawValue), statusMessage: statusAuthorization[status]!)
        sendNotification(notification: notification)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        let status = authorizationStatus()
        let statusMessage = statusAuthorization[status]
        
        isRunning = false
        
        let notification = LocationNotification(name: LocationNotification.kLocationManagerDidFailWithError, status: Int(status.rawValue), statusMessage: statusMessage!, error: error as NSError?)
        sendNotification(notification: notification)
    }
}

