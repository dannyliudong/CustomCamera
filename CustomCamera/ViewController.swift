//
//  ViewController.swift
//  CustomCamera
//
//  Created by liudong on 2017/11/27.
//  Copyright © 2017年 liudong. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        startRunningCaptureSession()
    }
    
    func setupCaptureSession() {
        
    }
    
    func setupDevice() {
        
    }
    
    func setupInputOutput(){
        
    }
    
    func setupPreviewLayer(){
        
    }
    
    func startRunningCaptureSession() {
        
    }
    
    @IBAction func cameraButtonTouchUpInside(_ sender: Any) {
        performSegue(withIdentifier: "ShowPhotoSegue", sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

