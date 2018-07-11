//
//  CameraEngineCaptureOutput.swift
//  CameraEngine2
//
//  Created by Remi Robert on 24/12/15.
//  Copyright © 2015 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public typealias blockCompletionCapturePhoto = (_ image: UIImage?, _ error: Error?) -> (Void)
public typealias blockCompletionCapturePhotoBuffer = ((_ sampleBuffer: CMSampleBuffer?, _ error: Error?) -> Void)
public typealias blockCompletionCaptureVideo = (_ url: URL?, _ error: NSError?) -> (Void)
public typealias blockCompletionOutputBuffer = (_ sampleBuffer: CMSampleBuffer) -> (Void)
public typealias blockCompletionProgressRecording = (_ duration: Float64) -> (Void)

extension AVCaptureVideoOrientation {
    static func orientationFromUIDeviceOrientation(_ orientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch orientation {
        case .portrait: return .portrait
        //case .landscapeLeft: return .landscapeRight
        //case .landscapeRight: return .landscapeLeft
        //case .portraitUpsideDown: return .portraitUpsideDown
        default: return .portrait
        }
    }
}

class CameraEngineCaptureOutput: NSObject {
    
    let stillCameraOutput = AVCapturePhotoOutput()
    let movieFileOutput = AVCaptureMovieFileOutput()
    var captureVideoOutput = AVCaptureVideoDataOutput()
    var captureAudioOutput = AVCaptureAudioDataOutput()
    var blockCompletionVideo: blockCompletionCaptureVideo?
    var blockCompletionPhoto: blockCompletionCapturePhoto?
    
    let videoEncoder = CameraEngineVideoEncoder()
    
    var isRecording = false
    var blockCompletionBuffer: blockCompletionOutputBuffer?
    var blockCompletionProgress: blockCompletionProgressRecording?
    
    func capturePhotoBuffer(settings: AVCapturePhotoSettings, _ blockCompletion: @escaping blockCompletionCapturePhotoBuffer) {
        guard let connectionVideo  = stillCameraOutput.connection(with: AVMediaType.video) else {
            blockCompletion(nil, nil)
            return
        }
        connectionVideo.videoOrientation = AVCaptureVideoOrientation.orientationFromUIDeviceOrientation(UIDevice.current.orientation)
        stillCameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func capturePhoto(settings: AVCapturePhotoSettings, _ blockCompletion: @escaping blockCompletionCapturePhoto) {
        guard let connectionVideo  = stillCameraOutput.connection(with: AVMediaType.video) else {
            blockCompletion(nil, nil)
            return
        }
        blockCompletionPhoto = blockCompletion
        connectionVideo.videoOrientation = AVCaptureVideoOrientation.orientationFromUIDeviceOrientation(UIDevice.current.orientation)
        stillCameraOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func setPressetVideoEncoder(_ videoEncoderPresset: CameraEngineVideoEncoderEncoderSettings) {
        videoEncoder.presetSettingEncoder = videoEncoderPresset.configuration()
    }
    
    func startRecordVideo(_ blockCompletion: @escaping blockCompletionCaptureVideo, url: URL) {
        if isRecording == false {
            videoEncoder.startWriting(url)
            isRecording = true
        }
        else {
            isRecording = false
            stopRecordVideo()
        }
        blockCompletionVideo = blockCompletion
    }
    
    func stopRecordVideo() {
        isRecording = false
        videoEncoder.stopWriting(blockCompletionVideo) //aqui pasa algo tambien
    }
    
    func configureCaptureOutput(_ session: AVCaptureSession, sessionQueue: DispatchQueue) {
        if session.canAddOutput(captureVideoOutput) {
            session.addOutput(captureVideoOutput)
            captureVideoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        }
        if session.canAddOutput(captureAudioOutput) {
            session.addOutput(captureAudioOutput)
            captureAudioOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        }
        
        if session.canAddOutput(stillCameraOutput) {
            session.addOutput(stillCameraOutput)
        }
    }
}

extension CameraEngineCaptureOutput: AVCapturePhotoCaptureDelegate {
    public func photoOutput(captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            blockCompletionPhoto?(nil, error)
        }
        else {
            if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: nil) {
                let image = UIImage(data: dataImage)
                blockCompletionPhoto?(image, nil)
            }
            else {
                blockCompletionPhoto?(nil, nil)
            }
        }
    }
}

extension CameraEngineCaptureOutput: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    private func progressCurrentBuffer(_ sampleBuffer: CMSampleBuffer) {
        if let block = blockCompletionProgress, isRecording {
            block(videoEncoder.progressCurrentBuffer(sampleBuffer))
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        progressCurrentBuffer(sampleBuffer)
        if let block = blockCompletionBuffer {
            block(sampleBuffer)
        }
        if CMSampleBufferDataIsReady(sampleBuffer) == false || isRecording == false {
            return
        }
        if captureOutput == captureVideoOutput {
            videoEncoder.appendBuffer(sampleBuffer, isVideo: true)
        }
        else if captureOutput == captureAudioOutput {
            videoEncoder.appendBuffer(sampleBuffer, isVideo: false)
        }
    }
}

extension CameraEngineCaptureOutput: AVCaptureFileOutputRecordingDelegate {
    
    func fileOutput(captureOutput: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
    }
    
    func fileOutput(captureOutput: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let blockCompletionVideo = blockCompletionVideo {
            blockCompletionVideo(outputFileURL, error as NSError?)
        }
    }    
}
