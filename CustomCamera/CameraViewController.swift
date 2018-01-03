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
    
    var photoOutput: AVCapturePhotoOutput?
    
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
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
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            
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
        
        
        if let camera = currentCamera {
            var pointOfInterest = CGPoint.zero

            pointOfInterest = sender.location(in: self.view)//CGPoint(x: point.y / frameSize.height, y: 1.0 - (point.x / frameSize.width))
            
            print(pointOfInterest)
            
            do {
                try camera.lockForConfiguration()
                camera.focusPointOfInterest = pointOfInterest
                camera.focusMode = AVCaptureDevice.FocusMode.autoFocus
                camera.exposurePointOfInterest = pointOfInterest
                camera.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
                camera.unlockForConfiguration()

//                self.focusUI(location: location)

            } catch {
                print(error.localizedDescription)
            }
        }
        
        
       
    }
    
    var focusView : UIView?
    // 焦点UI动画
    func focusUI(location: CGPoint) {
        
        print("focusing")
        
        focusView = UIView(frame: CGRect(x: location.x, y: location.y, width: 20, height: 20))
        focusView?.backgroundColor = UIColor.white
        self.view.addSubview(focusView!)
        
        
//        let focalReticule = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
//        focalReticule.backgroundColor = UIColor.clear
//
//        let line1 = UIView(frame: CGRect(x: 0, y: 29.5, width: 60, height: 1))
//        line1.backgroundColor = UIColor.white
//        focalReticule.addSubview(line1)
//
//        let line2 = UIView(frame: CGRect(x: 29.5, y: 0, width: 1, height: 60))
//        line2.backgroundColor = UIColor.white
//        focalReticule.addSubview(line2)
        
        
//        focalReticule.isHidden = true
        
        UIView.animate(withDuration: 1, animations: {
            self.focusView?.isHidden = false
        }) { (ok) in
            self.focusView?.isHidden = true
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













