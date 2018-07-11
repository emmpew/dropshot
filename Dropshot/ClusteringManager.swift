//
//  ClusteringManager.swift
//  ClusteringTrial3
//
//  Created by Andrew Castellanos on 11/21/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import MapKit

public protocol ClusteringManagerDelegate: NSObjectProtocol {
    func cellSizeFactor(forCoordinator coordinator: ClusteringManager) -> CGFloat
}

public class ClusteringManager {
    
    public weak var delegate: ClusteringManagerDelegate? = nil
    
    private var backingTree: QuadTree?
    private var tree: QuadTree? {
        set {
            backingTree = newValue
        }
        get {
            if backingTree == nil {
                backingTree = QuadTree()
            }
            return backingTree
        }
    }
    private let lock = NSRecursiveLock()
    
    public init() { }
    
    public init(annotations: [MKAnnotation]) {
        add(annotations: annotations)
    }
    
    public func add(annotations:[MKAnnotation]){
        lock.lock()
        for annotation in annotations {
            _ = tree?.insert(annotation: annotation)
        }
        lock.unlock()
    }
    
    public func removeAll() {
        tree = nil
    }
    
    public func replace(annotations:[MKAnnotation]){
        removeAll()
        add(annotations: annotations)
    }
    
    public func allAnnotations() -> [MKAnnotation] {
        var annotations = [MKAnnotation]()
        lock.lock()
        tree?.enumerateAnnotationsUsingBlock(){ obj in
            annotations.append(obj)
        }
        lock.unlock()
        return annotations
    }
    
    public func clusteredAnnotations(withinMapRect rect:MKMapRect, zoomScale: Double) -> [MKAnnotation] {
        guard !zoomScale.isInfinite else { return [] }
        
        var cellSize = ZoomLevel(MKZoomScale(zoomScale)).cellSize()
        
        if let delegate = delegate, delegate.responds(to: Selector(("cellSizeFactorForCoordinator:"))) {
            cellSize *= delegate.cellSizeFactor(forCoordinator: self)
        }
        
        let scaleFactor = zoomScale / Double(cellSize)
        
        let minX = Int(floor(MKMapRectGetMinX(rect) * scaleFactor))
        let maxX = Int(floor(MKMapRectGetMaxX(rect) * scaleFactor))
        let minY = Int(floor(MKMapRectGetMinY(rect) * scaleFactor))
        let maxY = Int(floor(MKMapRectGetMaxY(rect) * scaleFactor))
        
        var clusteredAnnotations = [MKAnnotation]()
        
        lock.lock()
        
        for i in minX...maxX {
            for j in minY...maxY {
                
                let mapPoint = MKMapPoint(x: Double(i) / scaleFactor, y: Double(j) / scaleFactor)
                let mapSize = MKMapSize(width: 1.0 / scaleFactor, height: 1.0 / scaleFactor)
                let mapRect = MKMapRect(origin: mapPoint, size: mapSize)
                let mapBox = BoundingBox(mapRect: mapRect)
                
                var totalLatitude: Double = 0
                var totalLongitude: Double = 0
                
                var annotations = [MKAnnotation]()
                
                tree?.enumerateAnnotations(inBox: mapBox) { obj in
                    totalLatitude += obj.coordinate.latitude
                    totalLongitude += obj.coordinate.longitude
                    annotations.append(obj)
                }
                
                let count = annotations.count
                
                switch count {
                case 0: break
                case 1:
                    clusteredAnnotations += annotations
                default:
                    let coordinate = CLLocationCoordinate2D(
                        latitude: CLLocationDegrees(totalLatitude)/CLLocationDegrees(count),
                        longitude: CLLocationDegrees(totalLongitude)/CLLocationDegrees(count)
                    )
                    let cluster = DropCluster()
                    cluster.coordinate = coordinate
                    cluster.annotations = annotations as! [Drop]
                    clusteredAnnotations.append(cluster)
                }
            }
        }
        
        lock.unlock()
        
        return clusteredAnnotations
    }
    
    public func display(annotations: [MKAnnotation], onMapView mapView:MKMapView){
        
        let before = NSMutableSet(array: mapView.annotations)
        before.remove(mapView.userLocation)
        
        let after = NSSet(array: annotations)
        
        let toKeep = NSMutableSet(set: before)
        toKeep.intersect(after as Set<NSObject>)
        
        let toAdd = NSMutableSet(set: after)
        toAdd.minus(toKeep as Set<NSObject>)
        
        let toRemove = NSMutableSet(set: before)
        toRemove.minus(after as Set<NSObject>)
        
        if let toAddAnnotations = toAdd.allObjects as? [MKAnnotation] {
            mapView.addAnnotations(toAddAnnotations)
        }
        
        if let removeAnnotations = toRemove.allObjects as? [MKAnnotation] {
            mapView.removeAnnotations(removeAnnotations) //aqui me dio problemas
        }
    }
    
}
