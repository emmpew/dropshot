//
//  RequestsCell.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class RequestsCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var requestID: String!
    
    var acceptRequestAction : (() -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        // button rounded corners
        addButton.layer.cornerRadius = 10
        addButton.layer.borderWidth = 1
        addButton.layer.borderColor = UIColor.lightGray.cgColor
        addButton.titleLabel?.font = UIFont(name: "Arial Rounded MT Bold", size: 16.0)
        addButton.backgroundColor = .white
        addButton.setTitleColor(.lightGray, for: UIControlState())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addFriend(_ sender: Any) {
        addButton.isEnabled = false
        if let btnAction = self.acceptRequestAction {
            btnAction()
        }
    }
    
}
