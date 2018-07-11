//
//  PreviewDropVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import AVFoundation
import CoreLocation

protocol PreviewDropDelegate: class {
    func didFinishPreview(acceptedContent: Bool, editedImage: UIImage?)
}

class PreviewDropVC: UIViewController {

    private var apiFilter = PreviewFilterAPI()
    private var media: Media!
    private var player: Player!
    var locLat: CLLocationDegrees!
    var locLon: CLLocationDegrees!
    private var imageView = UIImageView()
    private var isFilterControlHidden = true
    private var num = 0
    private var imageArray = [UIImage]()
    weak var delegate: PreviewDropDelegate?
    
    fileprivate let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer()
    fileprivate let screenView: UIView = UIView(frame: CGRect(origin: CGPoint.zero, size: ScreenUtils.screenSize))
    fileprivate let textField = DropTextField(y: ScreenUtils.screenSize.height/2, width: ScreenUtils.screenSize.width, heightOfScreen: ScreenUtils.screenSize.height)
    fileprivate let buttonClose = CustomButton(frame: CGRect(x: 20, y: 20, width: 30, height: 30), withImageNamed: "CancelButton")
    fileprivate let buttonSend = CustomButton(frame: CGRect(x: ScreenUtils.screenSize.width - 70, y: ScreenUtils.screenSize.height - 70, width: 50, height: 50), withImageNamed: "DropContent")
    //Filters
    fileprivate let buttonFilter = CustomButton(frame: CGRect(x: 20, y: ScreenUtils.screenSize.height - 64, width: 44, height: 44), withImageNamed: "FilterButtonOn")
    fileprivate let buttonPreviousFilter = CustomButton(frame: CGRect(x: (ScreenUtils.screenSize.width / 2) - 75, y: ScreenUtils.screenSize.height - 160, width: 60, height: 50), withImageNamed: "FilterScrollLeft")
    fileprivate let buttonNextFilter = CustomButton(frame: CGRect(x: (ScreenUtils.screenSize.width / 2) + 15, y: ScreenUtils.screenSize.height - 160, width: 60, height: 50), withImageNamed: "FilterScrollRight")
    
    //MARK : Public methods
    public func setupWith(media: Media) {
        self.media = media
    }
    
    //MARK: view lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.addSubview(screenView)
        setupContent()
        setupButtonClose()
        setupButtonSend()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(textField)
    }
    
    func setupImageView(image: UIImage) {
        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        imageView.image = image
        imageArray = apiFilter.placeFilters(originalImage: image, imageView: imageView)
        imageView.isUserInteractionEnabled = true
        imageView.isMultipleTouchEnabled = true
        imageView.isExclusiveTouch = false
        self.screenView.addSubview(imageView)
    }
    
    fileprivate func setupContent() {
        switch self.media!.mediaType {
        case .photo:
            if let photo = self.media!.photo {
                tapGesture.addTarget(self, action: #selector(handleTap))
                setupImageView(image: photo)
                setupTextField()
                setupButtonFilter()
                setupPreviousFilter()
                setupNextFilter()
            }
        case .video:
            if let url = self.media!.video {
                self.playVideo(url)
            }
        }
    }
    
    fileprivate func setupTextField() {
        screenView.addSubview(textField)
        tapGesture.delegate = self
        imageView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self.textField, selector: #selector(DropTextField.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self.textField, selector: #selector(DropTextField.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self.textField, selector: #selector(DropTextField.keyboardTypeChanged(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    }
    
    fileprivate func setupButtonSend() {
        self.buttonSend.setAction {
            [weak weakSelf = self] in
            switch self.media!.mediaType {
            case .photo:
                let imageDropped = ScreenUtils.screenShot(weakSelf?.screenView)
                if let finalImage = imageDropped {
                    weakSelf?.buttonSend.isEnabled = false
                    weakSelf?.cleanImageView()
                    if let delegate = weakSelf?.delegate {
                        delegate.didFinishPreview(acceptedContent: true, editedImage: finalImage)
                    }
                }
            case .video:
                if let url = weakSelf?.media!.video {
                    weakSelf?.buttonSend.isEnabled = false
                    weakSelf?.hidePlayer(url: url)
                    if let delegate = weakSelf?.delegate {
                        delegate.didFinishPreview(acceptedContent: true, editedImage: nil)
                    }
                }
            }
        }
        self.view.addSubview(self.buttonSend)
    }
    
    fileprivate func setupButtonClose() {
        self.buttonClose.setAction {
            [weak weakSelf = self] in
            if let media = weakSelf?.media {
                switch media.mediaType {
                case .photo:
                    weakSelf?.cleanImageView()
                case .video:
                    if let url = media.video {
                        weakSelf?.hidePlayer(url: url)
                    }
                }
            }
            //inform the delegate that user did not accept photo
            if let delegate = weakSelf?.delegate {
                delegate.didFinishPreview(acceptedContent: false, editedImage:nil)
            }
        }
        self.view.addSubview(self.buttonClose)
    }
    
    fileprivate func setupButtonFilter() {
        self.buttonFilter.setAction {
            [weak weakSelf = self] in
            if weakSelf?.isFilterControlHidden == true {
                weakSelf?.isFilterControlHidden = false
                weakSelf?.buttonPreviousFilter.isHidden = false
                weakSelf?.buttonNextFilter.isHidden = false
                DispatchQueue.main.async {
                    weakSelf?.buttonFilter.setImage(UIImage(named: "FilterButtonOff"), for: UIControlState())
                }
            } else {
                weakSelf?.isFilterControlHidden = true
                weakSelf?.buttonPreviousFilter.isHidden = true
                weakSelf?.buttonNextFilter.isHidden = true
                DispatchQueue.main.async {
                    weakSelf?.buttonFilter.setImage(UIImage(named: "FilterButtonOn"), for: UIControlState())
                }
            }
        }
        self.view.addSubview(buttonFilter)
    }
    
    fileprivate func setupPreviousFilter() {
        self.buttonPreviousFilter.isHidden = true
        self.buttonPreviousFilter.setAction {
            [weak weakSelf = self] in
            if let imageArray = weakSelf?.imageArray {
                if weakSelf?.num == 0 {
                    weakSelf?.num = imageArray.count - 1
                } else {
                    weakSelf?.num -= 1
                }
                weakSelf?.imageView.image = imageArray[(weakSelf?.num)!]
            }
        }
        self.view.addSubview(buttonPreviousFilter)
    }
    
    fileprivate func setupNextFilter() {
        self.buttonNextFilter.isHidden = true
        self.buttonNextFilter.setAction {
            [weak weakSelf = self] in
            if let imageArray = weakSelf?.imageArray {
                if weakSelf?.num == imageArray.count - 1 {
                    weakSelf?.num = 0
                } else {
                    weakSelf?.num += 1
                }
                weakSelf?.imageView.image = imageArray[(weakSelf?.num)!]
            }
        }
        self.view.addSubview(buttonNextFilter)
    }
    
    fileprivate func playVideo(_ url: URL) {
        player = Player()
        player.view.frame = self.view.bounds
        player.fillMode = "AVLayerVideoGravityResizeAspect"
        self.addChildViewController(self.player)
        screenView.addSubview(self.player.view)
        player.didMove(toParentViewController: self)
        let videoUrl: URL = url
        player.url = videoUrl
        player.playFromBeginning()
        player.playbackLoops = true
        buttonFilter.isHidden = true
    }
    
    private func hidePlayer(url: URL) {
        player.stop()
        player.removeFromParentViewController()
        player.removePlayerObservers()
        player.url = nil

        screenView.removeFromSuperview()
    }
    
    private func cleanImageView() {
        imageView.image = nil
        imageArray.removeAll()
        self.view.endEditing(true)
        
        screenView.removeFromSuperview()
    }
}

extension PreviewDropVC: UIGestureRecognizerDelegate {
    
    @objc func handleTap() {
        self.textField.handleTap()
    }
}
