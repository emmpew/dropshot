//
//  MainVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/11/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation
import AVKit
import UserNotifications

class MainVC: UIViewController {
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    let downloadManager = DownloadManager()
    let api = MapAPI()
    var currentUsername = UserInfo.username
    var annID = [String]() //array to hold unique drop ids
    var annotationArray = [Drop]()
    var tempAnnotations: NSArray?
    var actionButton: ActionButton!
    fileprivate var takenDrop: Drop?
    
    let clusteringManager = ClusteringManager()
    let configuration = DropClusterViewConfiguration.default()
    let configurationHalfSeen = DropClusterViewConfiguration.halfSeen()
    let configurationCompletelySeen = DropClusterViewConfiguration.completelySeen()

    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .hybridFlyover
            mapView.showsUserLocation = true
        }
    }

    @IBOutlet weak var mapIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if takenDrop == nil {
            UserDefaults.standard.removeObject(forKey: "failedDrop")
        }
        
        initialMapSetup()
        setupContentFileManager()
        if LocManager.sharedInstance.locationServicesEnabled() {
            startLocationServices()
            mapView.showsUserLocation = true
            
        } else {
            DispatchQueue.main.async {
                Helper.alertToSettings("Turn On Location Services?", message: "GPS access is restricted. In order to use DropShot, please enable GPS in the Settings app under Privacy > Location Services.")
            }
        }

        displayDrops()
        
        let profileImage = UIImage(named: "Profile.png")!
        let dropImage = UIImage(named: "Drop.png")!
        
        let profileFloatingButton = ActionButtonItem(title: "Profile", image: profileImage)
        profileFloatingButton.action = { item in
            self.actionButton.toggle()
            let storyboard = UIStoryboard(name: "Profile", bundle: nil)
            let vc = storyboard.instantiateInitialViewController()
            self.present(vc!, animated:true, completion: nil)
        }
        
        let dropFloatingButton = ActionButtonItem(title: "Drop", image: dropImage)
        dropFloatingButton.action = { item in
            
            if self.askCameraAuthorization() == .denied || self.askMicAuthorization() == .denied  {
                self.actionButton.toggle()
                let alert = UIAlertController(
                    title: "Need Authorization",
                    message: "Wouldn't you like to authorize this app " +
                    "to use the camera?",
                    preferredStyle: .alert)
                alert.addAction(UIAlertAction(
                    title: "No", style: .cancel))
                alert.addAction(UIAlertAction(
                title: "OK", style: .default) {
                    _ in
                    let url = URL(string:UIApplicationOpenSettingsURLString)!
                    UIApplication.shared.open(url)
                })
                self.present(alert, animated: true, completion: nil)
            } else {
                
                if let _ = UserDefaults.standard.value(forKey: "failedDrop") {
                    if UserInfo.failedDrop {
                        self.actionButton.toggle()
                        let alert = UIAlertController(
                            title: "",
                            message: "First lets finish uploading your current drop😊",
                            preferredStyle: .alert)
                        alert.addAction(UIAlertAction(
                            title: "OK", style: .cancel))
                        
                        self.present(alert, animated: true, completion: nil)
                    }
                } else {
                    self.actionButton.toggle()
                    let storyboard = UIStoryboard(name: "Camera", bundle: nil)
                    let vc = storyboard.instantiateInitialViewController() as! UINavigationController
                    let cameraVC = vc.topViewController as! CameraVC
                    cameraVC.delegate = self
                    self.present(vc, animated:true, completion: nil)
                }
            }
        }
        
        actionButton = ActionButton(attachedToView: self.view, items: [profileFloatingButton, dropFloatingButton])
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setTitle("+", forState: UIControlState())
        actionButton.backgroundColor = UIColor(red: 76.0/255.0, green: 191.0/255.0, blue: 211.0/255.0, alpha: 1.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func reloadDrops(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            displayDrops()
        }
    }
    
    //MARK:- Utility
    
    fileprivate func initialMapSetup() {
        mapIndicator.hidesWhenStopped = true
        mapView.userLocation.title = "Zoom"
        clusteringManager.delegate = self
    }
    
    fileprivate func setupContentFileManager() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dataPath = documentsDirectory.appendingPathComponent("MyFolder")
        do {
            if !FileManager.default.fileExists(atPath: dataPath.path) {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            }
        } catch let error as NSError {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    func displayDrops() {
        registerBackgroundTask()
        mapIndicator.startAnimating()
        api.testConnection(url: "https://www.google.com/", successClosure: { [weak self]  (success) in
            if success {
                self?.populateWithAllDrops()
            }
        }) { [weak self] (error) in
            DispatchQueue.main.async {
                self?.mapIndicator.stopAnimating()
                switch UIApplication.shared.applicationState {
                case .active:
                    DispatchQueue.main.async {
                        let message = String(error)
                        self?.alertView(message: message, window: appDelegate.window!, color: colorSmoothRed, delay: 4)
                    }
                case .background:
                    break
                case .inactive:
                    break
                }
                if self?.backgroundTask != UIBackgroundTaskInvalid {
                    self?.endBackgroundTask()
                }
            }
        }
    }
    
    func populateWithAllDrops() {
        api.queryDrops(currentUser: currentUsername, token: UserInfo.token, id: UserInfo.id, successClosure: { [weak self] (annotations) in
            var newDrop: [Drop] = []
            for drop in annotations {
                if let dropID = self?.annID {
                    if !dropID.contains(drop.id) {
                        self?.annID.append(drop.id)
                        self?.annotationArray.append(drop)
                        newDrop.append(drop)
                    }
                }
            }
            DispatchQueue.global(qos: .background).async {
                self?.getContent(array: newDrop)
            }
            self?.mapIndicator.stopAnimating()
            self?.clusteringManager.add(annotations: newDrop)
            self?.reloadVisibleDrops()
            if self?.backgroundTask != UIBackgroundTaskInvalid {
                self?.endBackgroundTask()
            }
            
        }) { [weak self] (error) in
            DispatchQueue.main.async {
                self?.mapIndicator.stopAnimating()
                switch UIApplication.shared.applicationState {
                case .active:
                    DispatchQueue.main.async {
                        let message = String(error)
                        self?.alertView(message: message, window: appDelegate.window!, color: colorSmoothRed, delay: 4)
                    }
                case .background:
                    break
                case .inactive:
                    break
                }
                if self?.backgroundTask != UIBackgroundTaskInvalid {
                    self?.endBackgroundTask()
                }
            }
            return
        }
    }
    
    func reloadVisibleDrops() {
        DispatchQueue.global(qos: .userInitiated).async {
            let mapBoundsWidth = Double(self.mapView.bounds.size.width)
            let mapRectWidth = self.mapView.visibleMapRect.size.width
            let scale = mapBoundsWidth / mapRectWidth
            let annotationArray = self.clusteringManager.clusteredAnnotations(withinMapRect: self.mapView.visibleMapRect, zoomScale:scale)
            
            DispatchQueue.main.async { //aqui tambien
                self.clusteringManager.display(annotations: annotationArray, onMapView: self.mapView) //aqui me dio problemas
            }
        }
    }
    
    @objc func buttonClicked (_ sender : UIButton!) {
        //check if loc available first
        if LocManager.sharedInstance.isRunning && LocManager.sharedInstance.authorizationStatus() == .authorizedWhenInUse {
            if mapView.region.span.latitudeDelta > 5.0 && mapView.region.span.longitudeDelta > 5.0 {
                zoomInOutUser(degrees: 0.04)
            } else {
                zoomInOutUser(degrees: 50)
            }
        }
    }
    
    func zoomInOutUser(degrees: Double) {
        let locLat = LocManager.sharedInstance.getLastLocation().coordinate.latitude
        let locLon = LocManager.sharedInstance.getLastLocation().coordinate.longitude
        let currLocation = CLLocation(latitude: locLat, longitude: locLon)
        let location: CLLocationCoordinate2D = CLLocationCoordinate2DMake((currLocation.coordinate.latitude), (currLocation.coordinate.longitude))
        let latitudeDelta : CLLocationDegrees = degrees
        let longitudeDelta : CLLocationDegrees = degrees
        let span : MKCoordinateSpan = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let region : MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        mapView.setRegion(region, animated: true)
    }
    
    fileprivate struct Constants {
        static let LeftCalloutFrame = CGRect(x: 0, y: 0, width: 50, height: 60)
        static let RightCalloutFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
        static let AnnotationViewReuseIdentifier = "pin"
        static let ShowPostSegue = "ShowDropCluster"
        static let ShowCameraSegue = "ShowCamera"
    }
    
    //MARK:- CAMERA SETUP
    
    public func askCameraAuthorization() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    public func askMicAuthorization() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
    }
    
    //MARK:- LOCATION SETUP
    
    func startLocationServices() {
        LocManager.sharedInstance.startUpdatingLocationWith(type: Authorization.WhenInUseAuthorization)
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(MainVC.locationUpdated(notification:)), name: NSNotification.Name(rawValue: LocationNotification.kLocationUpdated), object: nil)
        nc.addObserver(self, selector: #selector(MainVC.locationAuthorizationStatusChanged(notification:)), name: NSNotification.Name(rawValue: LocationNotification.kAuthorizationStatusChanged), object: nil)
        nc.addObserver(self, selector: #selector(MainVC.locationManagerDidFailWithError(notification:)), name: NSNotification.Name(rawValue: LocationNotification.kLocationManagerDidFailWithError), object: nil)
    }
    
    @objc func locationUpdated(notification: NSNotification) {
      
    }
    
    @objc func locationAuthorizationStatusChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo, let data = userInfo[LocationNotification.kNotificationDataKey] {
            let data = data as! LocationNotification
            switch data.status {
            case 3, 4:
                break
            case 1, 2:
                DispatchQueue.main.async {
                    Helper.alertToSettings("Location is Off", message: "Turn on Location Services to enjoy more Dropshot!")
                }
            default:
                break
            }
        }
    }
    
    @objc func locationManagerDidFailWithError(notification:NSNotification) {
        if let data = notification.userInfo![LocationNotification.kNotificationDataKey] {
            let data = data as! LocationNotification
            if let error = data.error {
                switch error.code {
                case 0:
                    DispatchQueue.main.async {
                        self.alertView(message: "Location is unavailable", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                    }
                    break
                default:
                    DispatchQueue.main.async {
                        self.alertView(message: "Location is unavailable", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                    }
                    break
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMediaPreviewVC" {
            if let mediaPreview = segue.destination as? MediaPreviewDrops {
                mediaPreview.photosToShow = tempAnnotations
                mediaPreview.delegate = self
                tempAnnotations = nil
            }
        }
    }
}

extension MainVC: CameraVCDelegate {
    
    func cameraControllerDidFinish(drop: Drop?) {
        self.dismiss(animated: true, completion: nil)
        if let drop = drop {
            self.takenDrop = drop
            if let takenDrop = self.takenDrop {
                registerBackgroundTask()
                self.showNewUploadOnMap(drop: takenDrop) //add drop to map
                self.sendCurrentMedia() //send info to server
                if let type = takenDrop.media?.mediaType {
                    if type == .photo {
                        if let image = takenDrop.media?.photo {
                            takenDrop.image = image
                        }
                    }
                }
            }
        }
    }
    
    func showNewUploadOnMap(drop: Drop) {
        annotationArray.append(drop)
        clusteringManager.add(annotations: [drop])
        reloadVisibleDrops()
    }
    
    func removeFromMap(drop: Drop) {
       
        clusteringManager.removeAll()
        
        let filteredDrop = annotationArray.filter { $0 != drop }
        annotationArray.removeAll()
        annotationArray = filteredDrop
        
        clusteringManager.add(annotations: annotationArray)
        reloadVisibleDrops()
    }
    
    func sendCurrentMedia() {
        guard let drop = self.takenDrop else {
            return
        }
        if drop.media?.mediaType == .photo {
            let image = drop.media?.photo!
            //send to server
            api.saveImageDrop(endpoint: APIEndpoints.uploadContentURL, username: drop.username, displayName: UserInfo.displayName, image: image!, userID: UserInfo.id, lat: drop.coordinate.latitude, lon: drop.coordinate.longitude, successClosure: { [weak self] (success) in
                self?.successfulDropHappened(drop: drop, success: success)
                }, failureClosure: { [weak self] (whereItFailed, dropFailed) in
                    drop.failed = whereItFailed
                    self?.alertFailedDropHappened(drop: drop, dropFailed: dropFailed)
                    return
            })
        } else {
            if let url = drop.media?.video {
                api.saveVideoDrop(endpoint: APIEndpoints.uploadVideoURL, username: drop.username, displayName: UserInfo.displayName, url: url, userID: UserInfo.id, lat: drop.coordinate.latitude, lon: drop.coordinate.longitude, successClosure: { [weak self] (success) in
                    CameraEngineFileManager.removeURL(url)
                    CameraEngineFileManager.removeItemAtPath(url.path)
                    self?.downloadManager.addDownload(URL(string: success.contentURL!)!)
                    self?.successfulDropHappened(drop: drop, success: success)
                    }, failureClosure: { [weak self] (whereItFailed, dropFailed) in
                        drop.failed = whereItFailed
                        self?.alertFailedDropHappened(drop: drop, dropFailed: dropFailed)
                        return
                })
            }
        }
    }
    
    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }
    
    func endBackgroundTask() {
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }
    
    func localNotificationAlert() {
//        let notificationType2 = UIApplication.shared.notifica
        
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType == [] {
        } else {
            let content = UNMutableNotificationContent()
            content.title = "Failed Drop"
            content.body = "Failed to upload drop. Please try again😊"
            content.sound = UNNotificationSound.default()
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1.0,
                repeats: false)
            let request = UNNotificationRequest(
                identifier: "10.second.message",
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(
                request, withCompletionHandler: nil)
        }
    }
    
    func alertFailedDropHappened(drop: Drop, dropFailed: Drop?) {
        UserInfo.failedDrop = true
        drop.completed = false
        mapView.removeAnnotation(drop)
        if let dropFail = dropFailed {
            if drop.failed == 1 || drop.failed == 2 {
                drop.id = dropFail.id
                drop.data = dropFail.data
                drop.dataStringURL = dropFail.dataStringURL
                drop.contentURL = dropFail.contentURL
            }
        }
        mapView.addAnnotation(drop)
        reloadVisibleDrops()
        
        switch UIApplication.shared.applicationState {
        case .active:
            DispatchQueue.main.async {
                self.alertView(message: "Failed to upload drop. Try again😊", window: appDelegate.window!, color: colorSmoothRed, delay: 3)
            }
        case .background:
            localNotificationAlert()
        case .inactive:
            localNotificationAlert()
        }
        
        if backgroundTask != UIBackgroundTaskInvalid {
            endBackgroundTask()
        }
    }
    
    func successfulDropHappened(drop: Drop, success: Drop) {
        
        UserDefaults.standard.removeObject(forKey: "failedDrop") //always removing it
        success.completed = true
        drop.id = success.id
        drop.contentURL = success.contentURL
        drop.dataStringURL = success.dataStringURL
        drop.failed = nil
        drop.completed = true

        mapView.removeAnnotation(drop)
        removeFromMap(drop: drop)
        
        showNewUploadOnMap(drop: success)
    
        annID.append(drop.id)
        reloadVisibleDrops()
        getContent(array: [drop])
        
        self.takenDrop = nil

        switch UIApplication.shared.applicationState {
        case .active:
            DispatchQueue.main.async {
                self.alertView(message: "Successful Upload", window: appDelegate.window!, color: colorRemBlue, delay: 3)
            }
        case .background:
            break
        case .inactive:
            break
        }
        
        if backgroundTask != UIBackgroundTaskInvalid {
            endBackgroundTask()
        }
    }
    
    //MARK:- RETRY UPLOAD
    
    func retryUploadToS3() {
        guard let drop = self.takenDrop else {
            return
        }
        
        if let stringURL = drop.dataStringURL {
            if drop.media?.mediaType == .photo {
                if let image = drop.media?.photo {
                    MapAPI.uploadImageToS3(image: image, url: stringURL, drop: drop, successClosure: { [weak self] (success) in
                        self?.successfulDropHappened(drop: drop, success: success)
                        }, failureClosure: { [weak self] (whereItFailed, dropFailed) in
                            drop.completed = false
                            drop.failed = whereItFailed
                            self?.alertFailedDropHappened(drop: drop, dropFailed: dropFailed)
                    })

                }
            } else {
                if let videoURL = drop.media?.video {
                    MapAPI.uploadVideoToS3(videoDataURL: videoURL, url: stringURL, drop: drop, successClosure: { [weak self] (success) in
                        self?.successfulDropHappened(drop: drop, success: success)
                        }, failureClosure: { [weak self] (whereItFailed, dropFailed) in
                            drop.completed = false
                            drop.failed = whereItFailed
                            self?.alertFailedDropHappened(drop: drop, dropFailed: dropFailed)
                    })
                }
            }
        }
    }
    
    func retryCompletingUpload() {
        guard let drop = self.takenDrop else {
            return
        }
        
        MapAPI.uploadCompleted(userID: UserInfo.id, uploadID: drop.id, drop: drop, successClosure: { [weak self] (success) in
            self?.successfulDropHappened(drop: drop, success: success)
        }) { [weak self] (whereItFailed, dropFailed) in
            drop.completed = false
            drop.failed = whereItFailed
            self?.alertFailedDropHappened(drop: drop, dropFailed: dropFailed)
        }
    }
}

extension MainVC: MediaPreviewDelegate {
    func didFinishShowMedia(seenMedia: [String], totalDrops: [Drop]) {
        self.dismiss(animated: true, completion: nil)
        if totalDrops.count == 1 {
            if !seenMedia.isEmpty {
                self.mapView.removeAnnotation(totalDrops.first!)
                self.mapView.addAnnotation(totalDrops.first!)
            }
        }
        reloadVisibleDrops()
        //add upload api
        if !seenMedia.isEmpty {
            MapAPI().checkIfUserHasSeenDrop(currentUser: currentUsername, dropArray: seenMedia, successClosure: nil) { (_) in
                //print("error = \(error)")
            }
        }
    }
    
    func deleteDrop(drop: Drop) {
        self.dismiss(animated: true, completion: nil)
        clusteringManager.removeAll()
        
        let filteredAnnIDArray = annID.filter { $0 != drop.id }
        annID.removeAll()
        annID = filteredAnnIDArray
        
        let filteredDrops = annotationArray.filter { $0 != drop }
        annotationArray.removeAll()
        annotationArray = filteredDrops
        
        clusteringManager.add(annotations: annotationArray)
        reloadVisibleDrops()
        UserDefaults.standard.removeObject(forKey: "failedDrop")
    }
}

extension MainVC: ClusteringManagerDelegate {
    
    func cellSizeFactor(forCoordinator coordinator:ClusteringManager) -> CGFloat {
        return 1.0
    }
}

extension MainVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        reloadVisibleDrops()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var reuseId = ""
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotation is DropCluster {
            
            reuseId = "Cluster"
            var clusterView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
            if clusterView == nil {
                clusterView = DropClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configuration)
            } else {
                clusterView?.annotation = annotation
            }
            
            clusterView?.leftCalloutAccessoryView = nil
            clusterView?.rightCalloutAccessoryView = nil
            
            if let drop = annotation as? DropCluster {
                if let seen = drop.seen {
                    if seen == 0 {
                        clusterView = DropClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configurationHalfSeen)
                    } else if seen == 2 {
                        clusterView = DropClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configurationCompletelySeen)
                    } else {
                        clusterView = DropClusterView(annotation: annotation, reuseIdentifier: reuseId, configuration: self.configuration)
                    }
                }
            }
            
            if let clusterView = clusterView {
                clusterView.canShowCallout = true
                clusterView.leftCalloutAccessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 51))
                clusterView.rightCalloutAccessoryView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 51))
                
                if let cluster = annotation as? DropCluster {
                    let filteredDrop = cluster.annotations.filter { $0.completed == false }
                    if filteredDrop.first?.completed == false {
                        let imageButton = UIImage(named: "Refresh")
                        let calloutButton = UIButton(type: .custom) as UIButton
                        calloutButton.frame = CGRect(x: 0, y: 0, width: 60, height: 51)
                        calloutButton.setImage(imageButton, for: .normal)
                        calloutButton.tintColor = .black
                        clusterView.rightCalloutAccessoryView = calloutButton
                    }
                }
            }
            
            return clusterView
            
        } else {
            
            reuseId = "Pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView?.pinTintColor = colorSmoothRed
            } else {
                pinView?.annotation = annotation
            }
            
            pinView?.leftCalloutAccessoryView = nil
            pinView?.rightCalloutAccessoryView = nil
            
            if let pinView = pinView {
                pinView.canShowCallout = true
                pinView.leftCalloutAccessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 51))
                pinView.rightCalloutAccessoryView = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 51))
                
                if let drop = annotation as? Drop {
                    if drop.seenBy.contains(currentUsername) {
                        pinView.pinTintColor = UIColor.white
                    } else {
                        pinView.pinTintColor = colorSmoothRed
                    }
                }
                
                if let drop = annotation as? Drop {
                    let username = drop.username
                    let userid = drop.userID
                    if username == currentUsername && userid == UserInfo.id {
                        if let completed = drop.completed {
                            if completed { //if all the content was uploaded successfully
                                let imageButton = UIImage(named: "Delete")
                                let calloutButton = UIButton(type: .custom) as UIButton
                                calloutButton.frame = CGRect(x: 0, y: 0, width: 60, height: 51)
                                calloutButton.setImage(imageButton, for: .normal)
                                calloutButton.tintColor = .black
                                
                                pinView.rightCalloutAccessoryView = calloutButton
                            } else { //if all the content was NOT uploaded
                                let imageButton = UIImage(named: "Refresh")
                                let calloutButton = UIButton(type: .custom) as UIButton
                                calloutButton.frame = CGRect(x: 0, y: 0, width: 60, height: 51)
                                calloutButton.setImage(imageButton, for: .normal)
                                calloutButton.tintColor = .black
                                pinView.rightCalloutAccessoryView = calloutButton
                            }
                        } else {
                            //when is still uploading the content
                            let indicatorAnnotation = UIActivityIndicatorView()
                            indicatorAnnotation.activityIndicatorViewStyle = .gray
                            indicatorAnnotation.color = colorRemBlue
                            indicatorAnnotation.frame = CGRect(x: 0, y: 0, width: 60, height: 51)
                            indicatorAnnotation.startAnimating()
                            pinView.rightCalloutAccessoryView = indicatorAnnotation
                        }
                    }
                }
            }
            return pinView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let drop = view.annotation as? Drop {
            if control == view.rightCalloutAccessoryView {
                if let completed = drop.completed {
                    if completed { //if completed then show option to delete
                        let alert = Helper.popupAlert(title: nil, message: nil, alertStyle: .actionSheet, actionTitles: ["Delete Drop?"], actions: [{ (delete) in
                            let alert2 = Helper.popupAlert(title: nil, message: nil, alertStyle: .actionSheet, actionTitles: ["Yes, I want to delete it"], actions: [{ [ weak self] (delete) in
                                self?.api.deleteDrop(userID: UserInfo.id, dropID: drop.id, successClosure: {
                                    self?.deleteDrop(drop: drop)
                                    self?.alertView(message: "Successfully deleted drop", window: appDelegate.window!, color: colorRemBlue, delay: 3)
                                }, failureClosure: { [weak self] (error) in
                                    self?.alertView(message: error, window: appDelegate.window!, color: colorSmoothRed, delay: 3)
                                })
                                }])
                            self.present(alert2, animated: true, completion: nil)
                            }])
                        self.present(alert, animated: true, completion: nil)
                    } else { //if failed handled accordingly
                        //it means upload failed so depending where it failed
                        //show button and retry accordingly
                        if let failed = drop.failed {
                            let indicatorAnnotation = UIActivityIndicatorView()
                            indicatorAnnotation.activityIndicatorViewStyle = .gray
                            indicatorAnnotation.color = colorRemBlue
                            indicatorAnnotation.frame = CGRect(x: 0, y: 0, width: 60, height: 51)
                            switch failed {
                            case 0: //it means it didnt save on db
                                self.sendCurrentMedia()
                                DispatchQueue.main.async {
                                    indicatorAnnotation.startAnimating()
                                    view.rightCalloutAccessoryView = indicatorAnnotation
                                }
                                return
                            case 1: //it means there was a problem uploading to s3
                                self.retryUploadToS3()
                                DispatchQueue.main.async {
                                    indicatorAnnotation.startAnimating()
                                    view.rightCalloutAccessoryView = indicatorAnnotation
                                }
                                return
                            case 2: //it means there was a problem changing the drop status to completed
                                self.retryCompletingUpload()
                                DispatchQueue.main.async {
                                    indicatorAnnotation.startAnimating()
                                    view.rightCalloutAccessoryView = indicatorAnnotation
                                }
                                return
                            default:
                                break
                            }
                        }
                    }
                }
            } else {
                var dropCluster = [Drop]()
                dropCluster.append(drop)
                tempAnnotations = dropCluster as NSArray?
                self.performSegue(withIdentifier: "ShowMediaPreviewVC", sender: self)
            }
        } else if let dropCluster = view.annotation as? DropCluster {
            if control == view.leftCalloutAccessoryView {
                let sortedAnnotations = sortArray(array: dropCluster.annotations)
                let dropClusterContent = NSMutableArray()
                dropClusterContent.addObjects(from: sortedAnnotations as [AnyObject])
                tempAnnotations = dropClusterContent
                self.performSegue(withIdentifier: "ShowMediaPreviewVC", sender: self)
            } else {
                let filteredDrop = dropCluster.annotations.filter { $0.completed == false }
                if let drop = filteredDrop.first {
                    if let failed = drop.failed {
                        let indicatorAnnotation = UIActivityIndicatorView()
                        indicatorAnnotation.activityIndicatorViewStyle = .gray
                        indicatorAnnotation.color = colorRemBlue
                        indicatorAnnotation.frame = CGRect(x: 0, y: 0, width: 60, height: 51)
                        switch failed {
                        case 0: //it means it didnt save on db
                            self.sendCurrentMedia()
                            DispatchQueue.main.async {
                                indicatorAnnotation.startAnimating()
                                view.rightCalloutAccessoryView = indicatorAnnotation
                            }
                            return
                        case 1: //it means there was a problem uploading to s3
                            self.retryUploadToS3()
                            DispatchQueue.main.async {
                                indicatorAnnotation.startAnimating()
                                view.rightCalloutAccessoryView = indicatorAnnotation
                            }
                            return
                        case 2: //it means there was a problem changing the drop status to completed
                            self.retryCompletingUpload()
                            DispatchQueue.main.async {
                                indicatorAnnotation.startAnimating()
                                view.rightCalloutAccessoryView = indicatorAnnotation
                            }
                            return
                        default:
                            break
                        }
                    }
                }
            }
        }
    }
    
    func getURL(url: URL, fileType: String) -> URL? {
        var returnURL: URL!
        do {
            let manager = FileManager.default
            let destinationURL = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("MyFolder").appendingPathComponent(url.lastPathComponent)
            
            let baseURL = URL(fileURLWithPath:destinationURL.path)
            returnURL = baseURL
        } catch {
            return nil
        }
        return returnURL
    }
    
    func showPictureURL(_ url: URL, imageButton: UIButton, drop: Drop) {
        if drop.typeOfFile == "picture" {
            if let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) {
                DispatchQueue.main.async {
                    drop.image = image
                    self.setImageOnButton(image: image, imageButton: imageButton)
                }
            }
        } else {
            let image = getImageFromVideo(url: url)
            DispatchQueue.main.async {
                drop.image = image
                self.setImageOnButton(image: image!, imageButton: imageButton)
            }
        }
    }
    
    func setImageOnButton(image: UIImage, imageButton: UIButton) {
        imageButton.imageView?.contentMode = UIViewContentMode.scaleAspectFill
        imageButton.setImage(image, for: UIControlState())
    }
    
    func getImageFromVideo(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        do {
            let imageRef = try imageGenerator.copyCGImage(at: CMTimeMake(1, 1), actualTime: nil) //show image from second 1
            let image = UIImage(cgImage: imageRef)
            return image
        } catch let errorImage as NSError {
            DispatchQueue.main.async(execute: {
                let message = String(errorImage.localizedDescription)
                self.alertView(message: message, window: appDelegate.window!, color: colorRemBlue, delay: 3)
            })
            return nil
        }
    }
    
    func checkIfFileExists(url: URL, drop: Drop) -> Bool {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent("MyFolder").appendingPathComponent(url.lastPathComponent).path) {
            return false
        } else {
            return true
        }
    }
    
    func checkIfURLReadable(url: URL) -> Bool {
        if FileManager.default.isReadableFile(atPath: url.path) {
            return true
        } else {
            return false
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let indicatorAnnotation = UIActivityIndicatorView()
        indicatorAnnotation.activityIndicatorViewStyle = .gray
        indicatorAnnotation.color = UIColor.black
        indicatorAnnotation.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        if let drop = view.annotation as? Drop {
            if let thumbnailImageButton = view.leftCalloutAccessoryView as? UIButton {
                if let image = drop.image {
                    setImageOnButton(image: image, imageButton: thumbnailImageButton)
                } else {
                    if let urlString = drop.contentURL {
                        guard let url = URL(string: urlString) else { return }
                        let fileExists = checkIfFileExists(url: url, drop: drop)
                        if fileExists {
                            let typeOfFile = drop.typeOfFile == "picture" ? "jpeg" : "mp4"
                            guard let baseURL = getURL(url: url, fileType: typeOfFile) else { return }
                            let readableFile = checkIfURLReadable(url: baseURL)
                            if readableFile {
                                //show url from filemanager
                                showPictureURL(baseURL, imageButton: thumbnailImageButton, drop: drop)
                            } else {
                                //stream url
                                indicatorAnnotation.startAnimating()
                                showPictureURL(url, imageButton: thumbnailImageButton, drop: drop)
                                indicatorAnnotation.stopAnimating()
                            }
                        } else {
                            indicatorAnnotation.startAnimating()
                            downloadManager.addDownload(url) //download content
                            showPictureURL(url, imageButton: thumbnailImageButton, drop: drop) //stream url
                            indicatorAnnotation.stopAnimating()
                        }
                    }
                }
            }
        } else if let _ = view.annotation as? DropCluster {
            if let leftButton = view.leftCalloutAccessoryView as? UIButton {
                let playDropCluster = UIImage(named: "PlayCluster")
                leftButton.setImage(playDropCluster, for: .normal)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        if let ulav = mapView.view(for: mapView.userLocation) {
            let button : UIButton = UIButton(type: .detailDisclosure) as UIButton
            let centerImage: UIImage = (UIImage(named: "Zoom")?.withRenderingMode(.alwaysOriginal))!
            button.setImage(centerImage, for: UIControlState())
            button.addTarget(self, action: #selector(MainVC.buttonClicked(_:)), for: UIControlEvents.touchUpInside)
            ulav.rightCalloutAccessoryView = button
        }
    }
    
    func sortArray (array: [Drop]) -> [Drop] {
        let sortedAnnotations = array.sorted(by: { (s1, s2) in
            if s1.seen == s2.seen {
                return s1.date > s2.date
            }
            return s1.seen! < s2.seen!
        })
        return sortedAnnotations
    }
    
    func getContent(array: [Drop]) {
        let sortedAnnotations = sortArray(array: array)
        saveContentToFileManager(contentArray: sortedAnnotations)
    }
    
    func saveContentToFileManager(contentArray: [Drop]) {
        for each in contentArray {
            guard let videoURL = URL(string: each.contentURL!) else { return }
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent("MyFolder").appendingPathComponent(videoURL.lastPathComponent).path) {
                downloadManager.addDownload(videoURL)
            }
        }
    }
}


