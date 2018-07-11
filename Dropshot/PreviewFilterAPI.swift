//
//  PreviewFilterAPI.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 12/15/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import UIKit

class PreviewFilterAPI {
    
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        //"CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        //"CIPhotoEffectProcess",
        //"CIPhotoEffectTonal",
        "CIPhotoEffectTransfer"
        //"CISepiaTone"
    ]
    
    func placeFilters(originalImage: UIImage, imageView: UIImageView) -> [UIImage] {
        
        var imageArray = [UIImage]()
        imageArray.append(originalImage)
        
        for i in 0..<CIFilterNames.count {
            let imageUse = imageView.image
            // Create each image with filter
            let ciContext = CIContext(options: nil)
            let coreImage = CIImage(image: imageUse!)
            let filter = CIFilter(name: "\(CIFilterNames[i])" )
            filter!.setDefaults()
            filter!.setValue(coreImage, forKey: kCIInputImageKey)
            let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
            let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
            let imageForButton = UIImage(cgImage: filteredImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
            imageArray.append(imageForButton)
        }
        
        return imageArray
    }

}

