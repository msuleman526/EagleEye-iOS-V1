//  PanaromaViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 2019/1/15.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJISDK
import DJIWidget
import AVFoundation

class ActiveTrackViewController: UIViewController, DJIFlightControllerDelegate{

    @IBOutlet weak var fpvView: UIView!
    var adapter: VideoPreviewerAdapter?
    var needToSetMode = false

    var alert: UIAlertController?
    var aircraft: DJIAircraft? = nil
    var flightController: DJIFlightController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        aircraft = DJISDKManager.product() as? DJIAircraft
        flightController = aircraft?.flightController
        
        flightController?.delegate = self
        
        let camera = fetchCamera()
        camera?.delegate = self
        
        needToSetMode = true

        DJIVideoPreviewer.instance()?.start()

        adapter = VideoPreviewerAdapter.init()
        adapter?.start()

        if camera?.displayName == DJICameraDisplayNameMavic2ZoomCamera ||
            camera?.displayName == DJICameraDisplayNameDJIMini2Camera ||
            camera?.displayName == DJICameraDisplayNameMavicAir2Camera ||
            camera?.displayName == DJICameraDisplayNameDJIAir2SCamera ||
            camera?.displayName == DJICameraDisplayNameMavic2ProCamera {
            adapter?.setupFrameControlHandler()
        }
        
    }

   func showAlertViewWithTitle(title: String, withMessage message: String) {
       let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction.init(title:"OK", style: .default, handler: nil)
       alert.addAction(okAction)
       self.present(alert, animated: true, completion: nil)
   }

    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DJIVideoPreviewer.instance()?.setView(fpvView)
        //DJIVideoPreviewer.instance()?.enableHardwareDecode
        //updateThermalCameraUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Call unSetView during exiting to release the memory.
        DJIVideoPreviewer.instance()?.unSetView()
        
        if adapter != nil {
            adapter?.stop()
            adapter = nil
        }
    }

}

/**
 *  DJICamera will send the live stream only when the mode is in DJICameraModeShootPhoto or DJICameraModeRecordVideo. Therefore, in order
 *  to demonstrate the FPV (first person view), we need to switch to mode to one of them.
 */
extension ActiveTrackViewController: DJICameraDelegate {
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        if systemState.mode != .recordVideo && systemState.mode != .shootPhoto {
            return
        }
        if needToSetMode == false {
            return
        }
        needToSetMode = false
        self.setCameraMode(cameraMode: .shootPhoto)

    }


    func camera(_ camera: DJICamera, didUpdateTemperatureData temperature: Float) {
        //tempLabel.text = String(format: "%f", temperature)
    }

}

extension ActiveTrackViewController {
    fileprivate func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }

        if product is DJIAircraft || product is DJIHandheld {
            return product.camera
        }
        return nil
    }

    fileprivate func setCameraMode(cameraMode: DJICameraMode = .shootPhoto) {
        var flatMode: DJIFlatCameraMode = .photoSingle
        let camera = self.fetchCamera()
        if camera?.isFlatCameraModeSupported() == true {
            NSLog("Flat camera mode detected")
            switch cameraMode {
            case .shootPhoto:
                flatMode = .photoSingle
            case .recordVideo:
                flatMode = .videoNormal
            default:
                flatMode = .photoSingle
            }
            camera?.setFlatMode(flatMode, withCompletion: { [weak self] (error: Error?) in
                if error != nil {
                    self?.needToSetMode = true
                    NSLog("Error set camera flat mode photo/video");
                }
            })
            } else {
                camera?.setMode(cameraMode, withCompletion: {[weak self] (error: Error?) in
                    if error != nil {
                        self?.needToSetMode = true
                        NSLog("Error set mode photo/video");
                    }
                })
            }
     }
}

