//
//  CameraVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

protocol CameraVCDelegate: class {
    func cameraControllerDidFinish(drop: Drop?)
}

class CameraVC: UIViewController, PreviewDropDelegate {
    
    @IBOutlet weak var recordButton: RecordButton!
    @IBOutlet weak var buttonDismissCamera: DismissButton!
    @IBOutlet weak var buttonSwitch: UIButton!
    @IBOutlet weak var buttonFlash: UIButton!
    @IBOutlet weak var labelDuration: UILabel!
    
    let cameraEngine = CameraEngine()
    private var locLat: CLLocationDegrees?
    private var locLon: CLLocationDegrees?
    private var progressTimer : Timer!
    private var progress : CGFloat! = 0
    private var tempMedia : Media?
    
    weak var delegate: CameraVCDelegate?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        recordButton.progressColor = .red
        recordButton.closeWhenFinished = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CameraVC.tapButton))
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(CameraVC.long))
        tapGesture.numberOfTapsRequired = 1
        recordButton.addGestureRecognizer(tapGesture)
        recordButton.addGestureRecognizer(longGesture)
        
        view.addSubview(recordButton)

        view.backgroundColor = UIColor.black
        labelDuration.isHidden = true
        cameraEngine.startSession()
        
        setupPreviewLayer()
        
        let twoFingerPinch = UIPinchGestureRecognizer(target: self, action: #selector(CameraVC.zoomOnTwoFingerPinch(recognizer:)))
        view.addGestureRecognizer(twoFingerPinch)
        view.isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = event!.allTouches!.first {
            let position = touch.location(in: self.view)
            self.cameraEngine.focus(position)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkStatus()
    }
   
    @objc func tapButton(sender: UITapGestureRecognizer) {
        if getLocation() {
            capturePhoto()
            recordButton.buttonState = .idle
        }
    }
    
    @objc func long(sender: UILongPressGestureRecognizer) {
        if getLocation() {
            if sender.state == .ended {
                stop()
            } else if sender.state == .began {
                record()
            }
        }
    }
    
    func record() {
        if getLocation() {
            self.progressTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(CameraVC.updateProgress), userInfo: nil, repeats: true)
            captureVideo()
        }
    }
    
    @objc func updateProgress() {
        let maxDuration = CGFloat(10) // Max duration of the recordButton
        progress = progress + (CGFloat(0.05) / maxDuration)
        recordButton.setProgress(progress)
        if progress >= 1 {
            stop()
        }
    }
    
    func stop() {
        progressTimer.invalidate()
        captureVideo()
        recordButton.buttonState = .idle
        progress = 0
    }
    
    func getLocation() -> Bool {
        if LocManager.sharedInstance.isRunning && LocManager.sharedInstance.authorizationStatus() == .authorizedWhenInUse {
            locLat = LocManager.sharedInstance.getLastLocation().coordinate.latitude
            locLon = LocManager.sharedInstance.getLastLocation().coordinate.longitude
            return true
        } else {
            alertView(message: "Location is not available", window: appDelegate.window!, color: colorSmoothRed, delay: 1)
            recordButton.buttonState = .idle
            return false
        }
    }
    
    @IBAction func dismissCamera(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.cameraControllerDidFinish(drop: nil)
        }
    }
    
    @IBAction func changeFlashMode(_ sender: Any) {
        let alertController = UIAlertController(title: "Flash mode", message: "Change the flash mode", preferredStyle: UIAlertControllerStyle.actionSheet)
        alertController.view.tintColor = UIColor(red: 255.0/255.0, green: 43.0/255.0, blue: 85.0/255.0, alpha:1.0)
        alertController.addAction(UIAlertAction(title: "On", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            DispatchQueue.main.async {
                self.cameraEngine.flashMode = .on
                self.buttonFlash.setImage(UIImage(named: "FlashOn"), for: UIControlState())
            }
        }))
        alertController.addAction(UIAlertAction(title: "Off", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            DispatchQueue.main.async {
                self.cameraEngine.flashMode = .off
                self.buttonFlash.setImage(UIImage(named: "FlashOff"), for: UIControlState())
            }
        }))
        alertController.addAction(UIAlertAction(title: "Auto", style: UIAlertActionStyle.default, handler: { (_) -> Void in
            DispatchQueue.main.async {
                self.cameraEngine.flashMode = .auto
                self.buttonFlash.setImage(UIImage(named: "FlashOn"), for: UIControlState())
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
        
        if let visualEffectView = alertController.view.searchVisualEffectsSubview()
        {
            visualEffectView.effect = UIBlurEffect(style: .dark)
        }
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        self.cameraEngine.switchCurrentDevice()
    }
    
    @objc func zoomOnTwoFingerPinch(recognizer: UIPinchGestureRecognizer) {
        let maxZoom: CGFloat = 6.0
        let pinchVelocityDividerFactor: CGFloat = 5.0
        if recognizer.state == .changed {
            let desiredZoomFactor = min(maxZoom, cameraEngine.cameraZoomFactor + atan2(recognizer.velocity, pinchVelocityDividerFactor))
            cameraEngine.cameraZoomFactor = desiredZoomFactor
        }
    }
    
    fileprivate func captureVideo() {
        if !self.cameraEngine.isRecording {
            if let url = CameraEngineFileManager.temporaryPath("video.mp4") {
                self.cameraEngine.startRecordingVideo(url, blockCompletion: { [weak self] (url, error) -> (Void) in
                    if error == nil {
                        if let url = url {
                            self?.tempMedia = Media(mediaType: .video, photo: nil, video: url)
                            DispatchQueue.main.async {
                                self?.performSegue(withIdentifier: "ShowPreview", sender: self)
                            }
                        }
                    } else {
                        if let _ = error {
                            //perhaps at this point I shuold reset everything and try again
                            self?.alertView(message: "Something went wrong", window: appDelegate.window!, color: colorSmoothRed, delay: 2)
                        }
                    }
                })
            }
        }
        else {
            self.cameraEngine.stopRecordingVideo()
        }
    }
    
    fileprivate func capturePhoto() {
        self.cameraEngine.capturePhoto({ [weak self] (image, error) -> (Void) in
            if error == nil {
                if	let image = image {
                    self?.tempMedia = Media(mediaType: .photo, photo: image, video: nil)
                }
                DispatchQueue.main.async {
                    self?.performSegue(withIdentifier: "ShowPreview", sender: self)
                }
            } else {
                if let _ = error {
                    self?.alertView(message: "Something went wrong", window: appDelegate.window!, color: colorSmoothRed, delay: 2)
                }
            }
        })
    }
    
    func setupPreviewLayer() {
        guard let layer = self.cameraEngine.previewLayer else {
            return
        }
        layer.frame = self.view.bounds
        self.view.layer.insertSublayer(layer, at: 0)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPreview" {
            if let previewVC = segue.destination as? PreviewDropVC {
                if let media = self.tempMedia {
                    previewVC.setupWith(media: media)
                    previewVC.delegate = self
                }
            }
        }
    }
    
    //MARK:- Location Check
    
    func checkStatus() {
        switch LocManager.sharedInstance.authorizationStatus().rawValue {
        case 3, 4:
            break
        case 1, 2:
            present(Helper.alertWithNoCancel("Location Services", message: "To share drops we need access to location", buttonAction: "Settings"), animated: true, completion: nil)
        //self.alert("Location Services", message: "To share drops we need access to location")
        default:
            present(Helper.alertWithNoCancel("Location Services", message: "To share drops we need access to location", buttonAction: "Settings"), animated: true, completion: nil)
            break
        }
    }
    
    //MARK : Preview Controller delegate
    func didFinishPreview(acceptedContent: Bool, editedImage: UIImage?) {
        if (acceptedContent) {
            //Create the media to pass to the delegate
            let typeOfFile = self.tempMedia?.mediaType == .photo ? "picture" : "video"
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(locLat!), longitude: CLLocationDegrees(locLon!))
            
            let drop = Drop(title: UserInfo.displayName.isEmpty ? UserInfo.username : UserInfo.displayName, username: UserInfo.username, typeOfFile: typeOfFile, seenBy: [], id: "", userID: UserInfo.id, date: Date(), coordinate: coordinate)
            
            if editedImage != nil {
                self.tempMedia?.photo = editedImage
                drop.media = self.tempMedia
            } else {
                drop.media = self.tempMedia
            }
            
            //Call delegate
            if let delegate = self.delegate {
                delegate.cameraControllerDidFinish(drop: drop)
            }
        }
        else {
            _ =  self.navigationController?.popViewController(animated: false)
        }
    }
}
