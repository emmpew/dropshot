//
//  CameraEngineVideoEncoder.swift
//  CameraEngine2
//
//  Created by Remi Robert on 11/02/16.
//  Copyright © 2016 Remi Robert. All rights reserved.
//

import UIKit
import AVFoundation

public enum CameraEngineVideoEncoderEncoderSettings: String {
    case Preset640x480
    case Preset960x540
    case Preset1280x720
    case Preset1920x1080
    case Preset3840x2160
    case Unknow
    
    private func avFoundationPresetString() -> String? {
        switch self {
        case .Preset640x480: return AVOutputSettingsPreset.preset640x480.rawValue
        case .Preset960x540: return AVOutputSettingsPreset.preset960x540.rawValue
        case .Preset1280x720: return AVOutputSettingsPreset.preset1280x720.rawValue
        case .Preset1920x1080: return AVOutputSettingsPreset.preset1920x1080.rawValue
        case .Preset3840x2160: return nil
        case .Unknow: return nil
        }
    }
    
    func configuration() -> AVOutputSettingsAssistant? {
        if let presetSetting = avFoundationPresetString() {
            return AVOutputSettingsAssistant(preset: AVOutputSettingsPreset(rawValue: presetSetting))
        }
        return nil
    }
    
    public static func availableFocus() -> [CameraEngineVideoEncoderEncoderSettings] {
        return AVOutputSettingsAssistant.availableOutputSettingsPresets().map {
            switch $0 {
            case AVOutputSettingsPreset.preset640x480: return .Preset640x480
            case AVOutputSettingsPreset.preset960x540: return .Preset960x540
            case AVOutputSettingsPreset.preset1280x720: return .Preset1280x720
            case AVOutputSettingsPreset.preset1920x1080: return .Preset1920x1080
            default: return .Unknow
            }
        }
    }
    
    public func description() -> String {
        switch self {
        case .Preset640x480: return "Preset 640x480"
        case .Preset960x540: return "Preset 960x540"
        case .Preset1280x720: return "Preset 1280x720"
        case .Preset1920x1080: return "Preset 1920x1080"
        case .Preset3840x2160: return "Preset 3840x2160"
        case .Unknow: return "Preset Unknow"
        }
    }
}

extension UIDevice {
    static func orientationTransformation() -> CGFloat {
        switch UIDevice.current.orientation {
        case .portrait: return CGFloat.pi / 2
        //case .portraitUpsideDown: return CGFloat(M_PI / 4)
        //case .landscapeRight: return CGFloat(M_PI)
        //case .landscapeLeft: return CGFloat(M_PI * 2)
        default: return CGFloat.pi / 2
        }
    }
}

class CameraEngineVideoEncoder {
    
    private var assetWriter: AVAssetWriter!
    private var videoInputWriter: AVAssetWriterInput!
    private var audioInputWriter: AVAssetWriterInput!
    private var firstFrame = false
    private var startTime: CMTime!
    
    lazy var presetSettingEncoder: AVOutputSettingsAssistant? = {
        return CameraEngineVideoEncoderEncoderSettings.Preset1280x720.configuration()
    }()
    
    let videoWriterCompressionSettings = [
        AVVideoAverageBitRateKey : Int(125000)
    ]
    
    
    private func initVideoEncoder(_ url: URL) {
        firstFrame = false
        guard let presetSettingEncoder = presetSettingEncoder else {
            print("[Camera engine] presetSettingEncoder = nil")
            return
        }
        
        do {
            assetWriter = try AVAssetWriter(url: url, fileType: AVFileType.mp4)
        }
        catch {
            fatalError("error init assetWriter")
        }
        
        var videoOutputSettings = presetSettingEncoder.videoSettings
        
        var compressionSetting = videoOutputSettings?[AVVideoCompressionPropertiesKey] as! [String : AnyObject]
        let bitrate = NSNumber(integerLiteral: 900000)
        compressionSetting[AVVideoAverageBitRateKey] = bitrate
        videoOutputSettings?[AVVideoCompressionPropertiesKey] = compressionSetting
        videoOutputSettings?[AVVideoWidthKey] = NSNumber(integerLiteral: 640)
        videoOutputSettings?[AVVideoHeightKey] = NSNumber(integerLiteral: 360)
        videoOutputSettings?[AVVideoCodecKey] = AVVideoCodecH264
        
        let audioOutputSettings = presetSettingEncoder.audioSettings
        
        guard assetWriter.canApply(outputSettings: videoOutputSettings, forMediaType: AVMediaType.video) else {
            fatalError("Negative [VIDEO] : Can't apply the Output settings...")
        }
        guard assetWriter.canApply(outputSettings: audioOutputSettings, forMediaType: AVMediaType.audio) else {
            fatalError("Negative [AUDIO] : Can't apply the Output settings...")
        }
        
        videoInputWriter = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInputWriter.expectsMediaDataInRealTime = true
        videoInputWriter.transform = CGAffineTransform(rotationAngle: UIDevice.orientationTransformation())
        
        audioInputWriter = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        audioInputWriter.expectsMediaDataInRealTime = true
        
        if assetWriter.canAdd(videoInputWriter) {
            assetWriter.add(videoInputWriter)
        }
        if assetWriter.canAdd(audioInputWriter) {
            assetWriter.add(audioInputWriter)
        }
    }
    
    func startWriting(_ url: URL) {
        firstFrame = false
        startTime = CMClockGetTime(CMClockGetHostTimeClock())
        initVideoEncoder(url)
    }
    
    func stopWriting(_ blockCompletion: blockCompletionCaptureVideo?) {
        videoInputWriter.markAsFinished()
        audioInputWriter.markAsFinished()
        
        assetWriter.finishWriting { [weak self] () -> Void in
            if let blockCompletion = blockCompletion {
                blockCompletion(self?.assetWriter.outputURL, nil)
            }
            //aqui pasa algo, me da error por veces
        }
    }
    
    func appendBuffer(_ sampleBuffer: CMSampleBuffer!, isVideo: Bool) {
        if !isVideo && !firstFrame {
            return
        }
        firstFrame = true
        if CMSampleBufferDataIsReady(sampleBuffer) {
            if assetWriter.status == AVAssetWriterStatus.unknown {
                let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: startTime)
            }
            if isVideo {
                if videoInputWriter.isReadyForMoreMediaData {
                    videoInputWriter.append(sampleBuffer)
                }
            }
            else {
                if audioInputWriter.isReadyForMoreMediaData {
                    audioInputWriter.append(sampleBuffer)
                }
            }
        }
    }
    
    func progressCurrentBuffer(_ sampleBuffer: CMSampleBuffer) -> Float64 {
        let currentTimestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        let currentTime = CMTimeGetSeconds(CMTimeSubtract(currentTimestamp, startTime))
        return currentTime
    }
}
