//
//  DataViewController.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/14/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import AVFoundation

class DataViewController: UIViewController {
    
    var dataObject: Drop?
    var api = DropContentAPI()
    var player: Player!
    let currentUsername = UserInfo.username
    let myActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameLabel: UIOutlinedLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var seenImage: UIImageView!
    @IBOutlet weak var errorHeadingLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        seenImage.isHidden = true
        myActivityIndicator.center = view.center
        myActivityIndicator.layer.zPosition = 1000
        getContent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        errorLabel.isHidden = true
        errorHeadingLabel.isHidden = true
        self.errorHeadingLabel.text = "Error"
        self.errorLabel.text = "Something went wrong"
    }
    
    func getContent() {
        if let drop = self.dataObject {
            self.setDate()
            self.userNameLabel.text = (drop.title?.isEmpty)! ? drop.username : drop.title
            if drop.typeOfFile == "picture" {
                if let image = drop.image {
                    self.imageView.image = image
                    self.imageView.contentMode = .scaleAspectFill
                    self.imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                } else {
                    if let localImage = drop.media?.photo {
                        self.imageView.image = localImage
                        self.imageView.contentMode = .scaleAspectFill
                        self.imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                    } else {
                        if let urlString = drop.contentURL {
                            guard let url = URL(string: urlString) else {
                                self.errorLoadingURL(drop: drop)
                                return
                            }
                            self.prepareImageURL(url, drop: drop)
                        }
                    }
                }
            } else {
                if let completed = drop.completed {
                    if completed {
                        if let urlString = drop.contentURL {
                            guard let url = URL(string: urlString) else {
                                self.errorLoadingURL(drop: drop)
                                return
                            }
                            self.prepareVideoURL(url, drop: drop)
                        }
                    } else {
                        if let url = drop.media?.video {
                            playVideo(url)
                        }
                    }
                } else {
                    if let url = drop.media?.video {
                        playVideo(url)
                    }
                }
            }
        }
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func prepareImageURL(_ url: URL, drop: Drop) {
        guard let baseURL = getURL(url: url, fileType: "jpeg") else {
            self.errorLoadingURL(drop: drop)
            return
        }
        if FileManager.default.isReadableFile(atPath: baseURL.path) {
            showPictureURL(baseURL)
        } else {
            myActivityIndicator.startAnimating()
            self.view.addSubview(myActivityIndicator)
            if let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) {
                myActivityIndicator.stopAnimating()
                myActivityIndicator.removeFromSuperview()
                self.imageView.image = image
                self.imageView.contentMode = .scaleAspectFill
            }
        }
    }
    
    func prepareVideoURL (_ url: URL, drop: Drop) {
        guard let baseURL = getURL(url: url, fileType: "mp4") else {
            self.errorLoadingURL(drop: drop)
            return
        }
        if FileManager.default.isReadableFile(atPath: baseURL.path) {
            playVideo(baseURL)
        } else {
            myActivityIndicator.startAnimating()
            self.view.addSubview(myActivityIndicator)
            playVideo(url)
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
    
    func showPictureURL(_ url: URL) {
        let data = try? Data(contentsOf: url)
        self.imageView.image = UIImage(data: data!)
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    func playVideo (_ url: URL) {
        self.player = Player()
        self.player.playerDelegate = self
        self.player.view.frame = self.view.bounds
        self.player.fillMode = "AVLayerVideoGravityResizeAspect"
        self.addChildViewController(self.player)
        self.view.addSubview(self.player.view)
        self.player.didMove(toParentViewController: self)
        self.player.url = url
        self.player.playFromCurrentTime()
        self.player.playbackLoops = true
        self.view.addSubview(userNameLabel)
        self.view.addSubview(dateLabel)
        self.view.addSubview(seenImage)
    }
    
    func errorLoadingURL(drop: Drop) {
        DispatchQueue.main.async {
            self.userNameLabel.text = ""
            self.dateLabel.text = ""
            self.seenImage.isHidden = true
            self.errorLabel.isHidden = false
            self.errorHeadingLabel.isHidden = false
        }
    }
    
    func setDate() {
        if let from = dataObject?.date {
            let now = Date()
            let components : NSCalendar.Unit = [.second, .minute, .hour, .day]
            let difference = (Calendar.current as NSCalendar).components(components, from: from, to: now, options: [])
            if difference.second! <= 0 {
                dateLabel.text = "now"
            }
            if difference.second! > 0 && difference.minute! == 0 {
                if let time = difference.second {
                    dateLabel.text = "\(time)s"
                }
            }
            if difference.minute! > 0 && difference.hour! == 0 {
                if let time = difference.minute {
                    dateLabel.text = "\(time)m"
                }
            }
            if difference.hour! > 0 && difference.day! == 0 {
                if let time = difference.hour {
                    dateLabel.text = "\(time)h"
                }
            }
            if difference.day! > 0 {
                dateLabel.text = "23h"
            }
        }
    }
}

extension DataViewController: PlayerDelegate {
    
    func playerReady(_ player: Player) {
        myActivityIndicator.stopAnimating()
        myActivityIndicator.removeFromSuperview()
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
    }
    
    func playerBufferingStateDidChange(_ player: Player) {
    }
}


