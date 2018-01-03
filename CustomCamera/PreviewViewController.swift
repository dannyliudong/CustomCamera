//
//  PreviewViewController.swift
//  CustomCamera
//
//  Created by liudong on 2017/11/27.
//  Copyright © 2017年 liudong. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    
    var image: UIImage?
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = self.image {
            imageView.image = image
        }

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func saveButtonTouchUpInside(_ sender: Any) {
        if let photo = image {
            UIImageWriteToSavedPhotosAlbum(photo, nil, nil, nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
