//
//  CameraEngineDeviceInput.swift
//  CameraEngine2
//
//  Created by Remi Robert on 01/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraEngineDeviceInputErrorType: Error {
    case unableToAddCamera
    case unableToAddMic
}

class CameraEngineDeviceInput {

    private var cameraDeviceInput: AVCaptureDeviceInput?
    private var micDeviceInput: AVCaptureDeviceInput?
    
    func configureInputCamera(_ session: AVCaptureSession, device: AVCaptureDevice) throws {
		session.beginConfiguration()
        let possibleCameraInput: AnyObject? = try AVCaptureDeviceInput(device: device)
        if let cameraInput = possibleCameraInput as? AVCaptureDeviceInput {
            if let currentDeviceInput = cameraDeviceInput {
                session.removeInput(currentDeviceInput)
            }
            cameraDeviceInput = cameraInput
            if session.canAddInput(cameraDeviceInput!) {
                session.addInput(cameraDeviceInput!)
            }
            else {
                throw CameraEngineDeviceInputErrorType.unableToAddCamera
            }
        }
		session.commitConfiguration()
    }
    
    func configureInputMic(_ session: AVCaptureSession, device: AVCaptureDevice) throws {
        if micDeviceInput != nil {
            return
        }
        try micDeviceInput = AVCaptureDeviceInput(device: device)
        if session.canAddInput(micDeviceInput!) {
            session.addInput(micDeviceInput!)
        }
        else {
            throw CameraEngineDeviceInputErrorType.unableToAddMic
        }
    }
}
