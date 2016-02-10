//
//  Camera.swift
//  IoTizer
//
//  Created by Tanaka Tatsuya on 2016/02/10.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit
import AVFoundation

public protocol CameraDelegate {
    func detectMotion()
}


public class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate
{
    public static let shared = Camera()
    
    public var delegate: CameraDelegate?
    
    private var videoInput: AVCaptureDeviceInput?
    private var videoDataOutput: AVCaptureVideoDataOutput?
    private var session = AVCaptureSession()
    
    private override init() {
        super.init()
        
        // クオリティの設定
        session.sessionPreset = AVCaptureSessionPresetHigh
//        session.sessionPreset = AVCaptureSessionPresetPhoto
//        session.sessionPreset = AVCaptureSessionPresetHigh
//        session.sessionPreset = AVCaptureSessionPresetMedium
//        session.sessionPreset = AVCaptureSessionPresetLow
        
        var camera: AVCaptureDevice!
        for captureDevice: AnyObject in AVCaptureDevice.devices() {
            // 前面カメラ
            if captureDevice.position == AVCaptureDevicePosition.Front {
                camera = captureDevice as? AVCaptureDevice
            }
        }
        
        do {
            videoInput = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error as NSError {
            print(error)
        }
        
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        
        // AVCaptureStillImageOutput:静止画
        // AVCaptureMovieFileOutput:動画ファイル
        // AVCaptureAudioFileOutput:音声ファイル
        // AVCaptureVideoDataOutput:動画フレームデータ
        // AVCaptureAudioDataOutput:音声データ
        videoDataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(videoDataOutput) {
            session.addOutput(videoDataOutput)
        }
        
        videoDataOutput?.alwaysDiscardsLateVideoFrames = true;
        videoDataOutput?.setSampleBufferDelegate(self, queue: dispatch_get_main_queue())
        videoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey : Int(kCVPixelFormatType_32BGRA)]
        
        do {
            try camera.lockForConfiguration()
            // FPS: 2
            camera.activeVideoMinFrameDuration = CMTimeMake(1, 2)
            
            camera.unlockForConfiguration()
        } catch _ {
        }
    }
    
    public func start() {
        session.startRunning()
    }
    
    public func stop() {
        session.stopRunning()
    }
    
    private func captureImage(sampleBuffer:CMSampleBufferRef) -> UIImage {
        let imageBuffer:CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        
        let baseAddress:UnsafeMutablePointer<Void> = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0)
        
        let bytesPerRow:Int = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width:Int = CVPixelBufferGetWidth(imageBuffer)
        let height:Int = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace:CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        let newContext:CGContextRef = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace,  CGImageAlphaInfo.PremultipliedFirst.rawValue|CGBitmapInfo.ByteOrder32Little.rawValue)!
        
        let imageRef:CGImageRef = CGBitmapContextCreateImage(newContext)!
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
        
        return resultImage
    }
    
    private func convertToImagePtr(image: CGImage) -> UnsafePointer<UInt8> {
        let dataProvider = CGImageGetDataProvider(image)
        let dataRef = CGDataProviderCopyData(dataProvider)
        return CFDataGetBytePtr(dataRef)
    }
    
    private func detectMotion(currentImage: UIImage, previousImage: UIImage) -> Bool {
        let imageRef = currentImage.CGImage!
        let prevImageRef = previousImage.CGImage!
        let buffer = self.convertToImagePtr(imageRef)
        let prevBuffer = self.convertToImagePtr(prevImageRef)
        
        let bytesPerRow = 5120 // CGImageGetBytesPerRow(imageRef)
        let width = 1280 // CGImageGetWidth(imageRef)
        let height = 720 // CGImageGetHeight(imageRef)
        
        let thresholdPixelNum = 10000
        let thresholdBrightness = 30.0
        
        var counter = 0
        
        for var y = 0; y < height; y+=4 {
            for var x = 0; x < width; x+=4 {
                let pixelPtr = buffer + y * bytesPerRow + x * 4
                let prevPixelPtr = prevBuffer + y * bytesPerRow + x * 4
                
                let b = pixelPtr.memory
                let g = (pixelPtr + 1).memory
                let r = (pixelPtr + 2).memory
//                print("r:\(r), g:\(g), b:\(b)")
                let pb = prevPixelPtr.memory
                let pg = (prevPixelPtr + 1).memory
                let pr = (prevPixelPtr + 2).memory
//                print("pr:\(pr), pg:\(pg), pb:\(pb)")
                
                // RGB to YCbCr
                let y  =  0.29891 * Double(r) + 0.58661 * Double(g) + 0.11448 * Double(b)
                let prevY  =  0.29891 * Double(pr) + 0.58661 * Double(pg) + 0.11448 * Double(pb)
                
                if fabs(y - prevY) > thresholdBrightness {
//                    print(fabs(y - prevY))
                    counter++
                }
            }
        }
        
        return counter > thresholdPixelNum
    }
    
    var prevImage: UIImage?
    
// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    public func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        let image = self.captureImage(sampleBuffer)
        
        if let prevImage = prevImage {
            if self.detectMotion(image, previousImage: prevImage) {
                if let delegate = self.delegate {
                    delegate.detectMotion()
                }
            }
        }
        prevImage = image
    }
    

}