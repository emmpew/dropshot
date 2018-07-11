//
//  DownloadOperation.swift
//  PushNotification
//
//  Created by Andrew Castellanos on 2/13/17.
//  Copyright © 2017 Andrew. All rights reserved.
//

import UIKit

/// Asynchronous Operation subclass for downloading

class DownloadOperation : AsynchronousOperation {
    let task: URLSessionTask
    
    init(session: URLSession, url: URL) {
        task = session.downloadTask(with: url)
        super.init()
    }
    
    override func cancel() {
        task.cancel()
        super.cancel()
    }
    
    override func main() {
        task.resume()
    }
}

// MARK: NSURLSessionDownloadDelegate methods

extension DownloadOperation: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        do {
            let manager = FileManager.default
            
            let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            guard let videoURL = downloadTask.originalRequest!.url else {return}
            
            let destinationURL = documentsDirectoryURL.appendingPathComponent("MyFolder").appendingPathComponent(downloadTask.response?.suggestedFilename ?? videoURL.lastPathComponent)
            
            if manager.fileExists(atPath: destinationURL.path) {
                try manager.removeItem(at: destinationURL)
            }
            try manager.moveItem(at: location, to: destinationURL)
        } catch {
            print("\(error)")
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
//        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
//        print("\(downloadTask.originalRequest!.url!.absoluteString) \(progress)")
    }
}

// MARK: NSURLSessionTaskDelegate methods

extension DownloadOperation: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)  {
        completeOperation()
        if error != nil {
            if let err = error {
                print("\(err)")
            }
        }
    }
    
}
