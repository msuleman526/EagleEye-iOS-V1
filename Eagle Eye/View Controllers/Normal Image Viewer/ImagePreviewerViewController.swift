//
//  ImagePreviewerViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 09/01/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit

class ImagePreviewerViewController: UIViewController {
    
    @IBOutlet weak var imagePreviewer: UIImageView!
    
    var data:Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if data != nil { // check nil here
            let image = UIImage(data: data!)
            DispatchQueue.main.async {
                self.imagePreviewer.image = image
            }
        }
        else{
            Toast.show(message: "No Image", controller: self)
        }
        
        //        self.imagePreviewer.isUserInteractionEnabled = true
        //        let pinchMethod = UIPinchGestureRecognizer(target: self, action: #selector(pinchImage(sender:)))
        //        self.imagePreviewer.addGestureRecognizer(pinchMethod)
        //
        //    }
        //
        //    @objc func pinchImage(sender: UIPinchGestureRecognizer) {
        //        guard let sender = sender.view else { return }
        //        if let scale = (sender.view?.transform.scaledBy(x: sender.scale, y: sender.scale)) {
        //            guard scale.a > 1.0 else { return }
        //            guard scale.d > 1.0 else { return }
        //            sender.view?.transform = scale
        //            sender.scale = 1.0
        //        }
        //    }
    }
    
}
