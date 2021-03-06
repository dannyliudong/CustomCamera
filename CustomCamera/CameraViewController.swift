//
//  ViewController.swift
//  CustomCamera
//
//  Created by liudong on 2017/11/27.
//  Copyright © 2017年 liudong. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    var captureSession = AVCaptureSession()
    
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    
    var captureDeviceInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var focalUI: UIView?
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
        
        createFocusUI()
        tapGestrue()
    }
    // setp 1
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // setp 2
    func setupDevice() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
                
            } else if device.position == AVCaptureDevice.Position.front{
                frontCamera = device
            }
        }
        currentCamera = backCamera
    }
    
    // setp 3
    func setupInputOutput(){
        do {
            captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput!)
            
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format:[AVVideoCodecKey:AVVideoCodecType.jpeg])], completionHandler: nil)
            
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // setp 4
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspect
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    // setp 5
    func startRunningCaptureSession() {
        captureSession.startRunning()
    }
    
    // 点击屏幕对焦手势
    func tapGestrue(){
        let foucussTap = UITapGestureRecognizer(target: self, action: #selector(CameraViewController.foucus(sender:)))
        self.view.addGestureRecognizer(foucussTap)
    }
    
    
    // 对焦
    @objc func foucus(sender: UITapGestureRecognizer) {
        if captureDeviceInput?.device.position == AVCaptureDevice.Position.front {
            return
        }
        
        if sender.state == .recognized {
            let location = sender.location(in: self.view)
            
            var pointOfInterest = CGPoint.zero
            let frameSize = self.view.bounds.size
            
            pointOfInterest = CGPoint(x: location.y/frameSize.height, y: 1.0-(location.x/frameSize.width))
            
            // 对焦
            if let device = currentCamera {
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
                    
                    do {
                        try device.lockForConfiguration()
                        if device.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance) {
                            device.whiteBalanceMode = AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance
                        }
                        
                        device.focusMode = AVCaptureDevice.FocusMode.autoFocus
                        device.focusPointOfInterest = pointOfInterest
                        
                        device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
                        device.exposurePointOfInterest = pointOfInterest
                        
                        device.unlockForConfiguration()
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    
                }
                
            }
            
            // 对焦动画
            focalUI?.center = location
            focalUI?.alpha = 0
            focalUI?.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.focalUI?.alpha = 1
            }, completion: { (ok) in
                UIView.animate(withDuration: 1.0, animations: {
                    self.focalUI?.alpha = 0
                })
            })
            
        }
        
        
//        if let camera = currentCamera {
//            var pointOfInterest = CGPoint.zero
//            let frameSize = self.view.bounds.size
//            let point = sender.location(in: self.view)
//
//            pointOfInterest = CGPoint(x: point.y / frameSize.height, y: 1.0 - (point.x / frameSize.width))
//
//
//            if camera.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus) {
//                camera.whiteBalanceMode = AVCaptureWhiteBalanceModeAuto
//
//                camera.focusMode = AVCaptureDevice.FocusMode.autoFocus
//                camera.focusPointOfInterest = pointOfInterest
//
//                camera.exposurePointOfInterest = pointOfInterest
//                camera.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
//
//                camera.unlockForConfiguration()
//            }
//        }
        
        
//        if let camera = currentCamera {
//            var pointOfInterest = CGPoint.zero
//
//            pointOfInterest = sender.location(in: self.view)//CGPoint(x: point.y / frameSize.height, y: 1.0 - (point.x / frameSize.width))
//
//            print(pointOfInterest)
//
//
//            do {
//                try camera.lockForConfiguration()
//                camera.focusPointOfInterest = pointOfInterest
//                camera.focusMode = AVCaptureDevice.FocusMode.autoFocus
//                camera.exposurePointOfInterest = pointOfInterest
//                camera.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
//                camera.unlockForConfiguration()
//
////                self.focusUI(location: location)
//
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
        
        
       
    }
    
    var focusView : UIView?
    // 焦点UI动画
    func createFocusUI() {
        
        print("focusing")

        focalUI = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        focalUI?.backgroundColor = UIColor.clear
        self.view.addSubview(focalUI!)

        let line1 = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 1))
        line1.backgroundColor = UIColor.white
        focalUI?.addSubview(line1)

        let line2 = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 60))
        line2.backgroundColor = UIColor.white
        focalUI?.addSubview(line2)
        
        let line3 = UIView(frame: CGRect(x: 0, y: 60, width: 60, height: 1))
        line3.backgroundColor = UIColor.white
        focalUI?.addSubview(line3)
        
        let line4 = UIView(frame: CGRect(x: 60, y: 0, width: 1, height: 60))
        line4.backgroundColor = UIColor.white
        focalUI?.addSubview(line4)
        

        focalUI?.isHidden = true

    }
    
    // 切换前后摄像头
    @IBAction func changeCamera(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified).devices
        if sender.isSelected {
            for device in devices {
                if device.position == AVCaptureDevice.Position.front {
                    frontCamera = device
                    captureSession.beginConfiguration()
                    captureSession.removeInput(captureDeviceInput!)
                    
                    do {
                        captureDeviceInput = try AVCaptureDeviceInput(device: frontCamera!)
                        captureSession.addInput(captureDeviceInput!)
                        captureSession.commitConfiguration()
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        } else {
            for device in devices {
                if device.position == AVCaptureDevice.Position.back {
                    backCamera = device
                    captureSession.beginConfiguration()
                    captureSession.removeInput(captureDeviceInput!)
                    
                    do {
                        captureDeviceInput = try AVCaptureDeviceInput(device: backCamera!)
                        captureSession.addInput(captureDeviceInput!)
                        captureSession.commitConfiguration()
                        
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    
    
    func takePicture() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .auto
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    @IBAction func cameraButtonTouchUpInside(_ sender: Any) {
//        performSegue(withIdentifier: "ShowPhotoSegue", sender: nil)
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPhotoSegue" {
            let previewVC = segue.destination as! PreviewViewController
            previewVC.image = self.image
        }
    }
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
//            print(imageData)
            image = UIImage(data: imageData)
            performSegue(withIdentifier: "ShowPhotoSegue", sender: nil)
        }
    }
    //    Use -captureOutput:didFinishProcessingPhoto:error: instead.
    
}













