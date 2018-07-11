//
//  Media.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

enum MediaType {
    case photo
    case video
}

struct Media {
    var mediaType : MediaType
    var photo: UIImage?
    var video : URL?
}

