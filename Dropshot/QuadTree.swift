//
//  QuadTree.swift
//  ClusteringTrial3
//
//  Created by Andrew Castellanos on 11/21/16.
//  Copyright © 2016 Andrew. All rights reserved.
//

import Foundation
import MapKit

open class QuadTree {
    
    let rootNode = QuadTreeNode(boundingBox: BoundingBox(mapRect: MKMapRectWorld))
    
    // MARK: Internal functions
    
    func insert(annotation: MKAnnotation) -> Bool {
        return insert(annotation: annotation, toNode:rootNode)
    }
    
    func enumerateAnnotations(inBox box: BoundingBox, callback: (MKAnnotation) -> Void) {
        enumerateAnnotations(inBox: box, withNode:rootNode, callback: callback)
    }
    
    func enumerateAnnotationsUsingBlock(_ callback: (MKAnnotation) -> Void) {
        enumerateAnnotations(inBox: BoundingBox(mapRect: MKMapRectWorld), withNode:rootNode, callback:callback)
    }
    
    // MARK: Private functions
    
    private func insert(annotation: MKAnnotation, toNode node: QuadTreeNode) -> Bool {
        if !node.boundingBox.contains(coordinate: annotation.coordinate) {
            return false
        }
      
        if node.canAppendAnnotation() {
            return node.append(annotation: annotation)
        }
        
        let siblings = node.siblings() ?? node.createSiblings()
        
        if insert(annotation: annotation, toNode:siblings.northEast) {
            return true
        }
        
        if insert(annotation: annotation, toNode:siblings.northWest) {
            return true
        }
        
        if insert(annotation: annotation, toNode:siblings.southEast) {
            return true
        }
        
        if insert(annotation: annotation, toNode:siblings.southWest) {
            return true
        }
        
        return false
    }
    
    private func enumerateAnnotations(inBox box: BoundingBox, withNode node: QuadTreeNode, callback: (MKAnnotation) -> Void) {
        if !node.boundingBox.intersects(box2: box) {
            return
        }
        
        for annotation in node.annotations {
            if box.contains(coordinate: annotation.coordinate) {
                callback(annotation)
            }
        }
        
        if node.isLeaf() {
            return
        }
        
        if let northEast = node.northEast {
            enumerateAnnotations(inBox: box, withNode: northEast, callback: callback)
        }
        
        if let northWest = node.northWest {
            enumerateAnnotations(inBox: box, withNode: northWest, callback: callback)
        }
        
        if let southEast = node.southEast {
            enumerateAnnotations(inBox: box, withNode: southEast, callback: callback)
        }
        
        if let southWest = node.southWest {
            enumerateAnnotations(inBox: box, withNode: southWest, callback: callback)
        }
    }

}
