//
//  DropClusterView.swift
//  ClusteringTrial3
//
//  Created by Andrew Castellanos on 11/21/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import MapKit
import UIKit

public class DropClusterView: MKAnnotationView {
    
    private var configuration: DropClusterViewConfiguration
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 2
        label.numberOfLines = 1
        label.baselineAdjustment = .alignCenters
        return label
    }()
    
    public override var annotation: MKAnnotation? {
        didSet {
            updateClusterSize()
        }
    }
    
    public convenience init(annotation: MKAnnotation?, reuseIdentifier: String?, configuration: DropClusterViewConfiguration){
        self.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.configuration = configuration
        self.setupView()
    }
    
    public override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.configuration = DropClusterViewConfiguration.default()
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        self.configuration = DropClusterViewConfiguration.default()
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        layer.borderColor = UIColor.white.cgColor
        addSubview(countLabel)
    }
    
    private func updateClusterSize() {
        if let cluster = annotation as? DropCluster {
            
            let count = cluster.annotations.count
            let seen = cluster.seen
            let template = configuration.templateForCount(count: count)
            
            switch template.displayMode {
            case .Image(let imageName):
                image = UIImage(named: imageName)
                break
            case .SolidColor(let sideLength, let color):
                
                if seen == 2 {
                    countLabel.textColor = .red
                } else {
                    countLabel.textColor = .white
                }
                
                backgroundColor	= color
                frame = CGRect(origin: frame.origin, size: CGSize(width: sideLength, height: sideLength))
                break
            }
            
            layer.borderWidth = template.borderWidth
            countLabel.font = template.font
            countLabel.text = "\(count)"
            
            setNeedsLayout()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        countLabel.frame = bounds
        layer.cornerRadius = image == nil ? bounds.size.width / 2 : 0
    }
}
