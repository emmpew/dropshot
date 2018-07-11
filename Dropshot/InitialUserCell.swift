//
//  InitialUserCell.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 5/15/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

class InitialUserCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
