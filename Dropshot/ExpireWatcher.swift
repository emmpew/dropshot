//
//  ExpireWatcher.swift
//  Dropshot
//
//  Created by Andrew Castellanos on 3/2/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import Foundation

class ExpireWatcher {
    
    static func deleteFiles() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard let documentsDirectory = URL(string: paths[0]) else { return }
        let dataPath = documentsDirectory.appendingPathComponent("MyFolder")
        
        do {
            try FileManager().removeItem(atPath: dataPath.absoluteString)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    static func deleteFileIfOld() {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        guard let documentsDirectory = URL(string: paths[0]) else { return }
        let dataPath = documentsDirectory.appendingPathComponent("MyFolder")
        let array = try? FileManager.default.contentsOfDirectory(atPath:dataPath.absoluteString)
        
        if let checkArray = array {
            for file in checkArray {
                let path = documentsDirectory.appendingPathComponent("MyFolder").appendingPathComponent(file).path
                let fileAttributes = try? FileManager.default.attributesOfItem(atPath: path)
                let creationDate = fileAttributes?[FileAttributeKey.creationDate] as? Date
                
                if checkDate(creationDate) {
                    do {
                        try FileManager().removeItem(atPath: path)
                    } catch let error as NSError {
                        print(error.localizedDescription)
                    }
                } 
            }
        }
    }
    
    static func checkDate(_ date: Date?) -> Bool {
        if let from = date {
            let now = Date()
            let difference = now.timeIntervalSince(from)
            return abs(difference) > 60*60*24
        }
        return false
    }
}
