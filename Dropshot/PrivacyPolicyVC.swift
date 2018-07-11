//
//  PrivacyPolicyVC.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dismissButton: DismissButton!
    
    var webView : WKWebView!
    var rowValue: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WKWebView()
        containerView.addSubview(webView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let frame = CGRect(x: 0, y: 0, width: containerView.bounds.width, height: containerView.bounds.height)
        webView.frame = frame
        switchInitialView(rowValue)
    }
    
    func switchInitialView(_ value: String) {
        switch value {
        case "0":
            let privacyURL = URL(string: "http://www.dropshot.co/privacy.html")
            if let url = privacyURL {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        case "1":
            let termsServiceURL = URL(string: "http://www.dropshot.co/terms.html")
            if let url = termsServiceURL {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        default:
            break
        }
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
