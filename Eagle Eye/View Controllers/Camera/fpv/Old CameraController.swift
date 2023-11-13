//
//
//import UIKit
//import DJISDK
//
//class CameraFPVViewController: UIViewController, DJIVideoFeedListener {
//
//    //@IBOutlet weak var decodeModeSeg: UISegmentedControl!
//    @IBOutlet weak var recordTimeLabel: UILabel!
//    @IBOutlet weak var modeSwitch: UISwitch!
//    //@IBOutlet weak var tempLabel: UILabel!
//    @IBOutlet weak var fpvView: UIView!
//
//    @IBOutlet weak var captureButton: UIButton!
//    @IBOutlet weak var recordButton: UIButton!
//
//    var needToSetMode = false
//    var isRecording : Bool!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        recordTimeLabel.isHidden = true
//        
//        if let camera = fetchCamera() {
//            camera.delegate = self
//        }
//        self.setupVideoPreviewer()
//
//    }
//    
//    func formatSeconds(seconds: UInt) -> String {
//           let date = Date(timeIntervalSince1970: TimeInterval(seconds))
//           
//           let dateFormatter = DateFormatter()
//           dateFormatter.dateFormat = "mm:ss"
//           return(dateFormatter.string(from: date))
//    }
//       
//    func showAlertViewWithTitle(title: String, withMessage message: String) {
//       let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
//       let okAction = UIAlertAction.init(title:"OK", style: .default, handler: nil)
//       alert.addAction(okAction)
//       self.present(alert, animated: true, completion: nil)
//    }
//    
//    func setupVideoPreviewer() {
//        print("Started")
//            DJIVideoPreviewer.instance().setView(self.fpvView)
//            let product = DJISDKManager.product();
//            
//            //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
//            if ((product?.model == DJIAircraftModelNameA3)
//                || (product?.model == DJIAircraftModelNameN3)
//                || (product?.model == DJIAircraftModelNameMatrice600)
//                || (product?.model == DJIAircraftModelNameMatrice600Pro)) {
//                DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
//            } else {
//                DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
//            }
//            DJIVideoPreviewer.instance().start()
//        }
//
//        func resetVideoPreview() {
//            DJIVideoPreviewer.instance().unSetView()
//            let product = DJISDKManager.product();
//            
//            //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
//            if ((product?.model == DJIAircraftModelNameA3)
//                || (product?.model == DJIAircraftModelNameN3)
//                || (product?.model == DJIAircraftModelNameMatrice600)
//                || (product?.model == DJIAircraftModelNameMatrice600Pro)) {
//                DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
//            } else {
//                DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
//            }
//        }
//
//    @IBAction func onCapturePhotoClick(_ sender: Any) {
//
//        if let camera = fetchCamera(){
//            camera.setMode(DJICameraMode.shootPhoto, withCompletion: {(error) in
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){ [self] in
//                    camera.startShootPhoto(completion: { (error) in
//                        if let _ = error {
//                            Toast.show(message: "Error " + String(describing: error), controller: self)
//                        }
//                        else{
//                            Toast.show(message: "Image Captured", controller: self)
//                        }
//                    })
//                }
//            })
//        }
//
//    }
//    
//    @IBAction func onRecordClick(_ sender: Any) {
//        
//        if let camera = fetchCamera(){
//            if (self.isRecording) {
//                camera.stopRecordVideo(completion: {(error) in
//                    if let _ = error {
//                        NSLog("Stop Record Video Error: " + String(describing: error))
//                    }else{
//                        Toast.show(message: "Recording Stopped", controller: self)
//                    }
//                })
//            } else {
//                camera.startRecordVideo(completion: {(error) in
//                    if let _ = error {
//                        NSLog("Stop Record Video Error: " + String(describing: error))
//                    }else{
//                        Toast.show(message: "Recording Started", controller: self)
//                    }
//                })
//            }
//        }
//        
//    }
//    
//    @IBAction func onModeChangeListener(_ sender: Any) {
//        
//        if(camera == nil){
//            return
//        }
//        if (self.modeSwitch.isOn == false) {
//            self.setCameraMode(cameraMode: .shootPhoto)
//            captureButton.isHidden = false
//            recordButton.isHidden = true
//       } else if (self.modeSwitch.isOn == true) {
//           self.setCameraMode(cameraMode: .recordVideo)
//           captureButton.isHidden = true
//           recordButton.isHidden = false
//       }
//        
//    }
//    
//    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
//        let videoData = rawData as NSData
//        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
//        videoData.getBytes(videoBuffer, length: videoData.length)
//        DJIVideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        if let camera = fetchCamera(), let delegate = camera.delegate, delegate.isEqual(self) {
//            camera.delegate = nil
//        }
//        
//        self.resetVideoPreview()
//        
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//
//    }
//
//}
//
///**
// *  DJICamera will send the live stream only when the mode is in DJICameraModeShootPhoto or DJICameraModeRecordVideo. Therefore, in order
// *  to demonstrate the FPV (first person view), we need to switch to mode to one of them.
// */
//extension CameraFPVViewController: DJICameraDelegate {
//    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
//        self.isRecording = systemState.isRecording
//        self.recordTimeLabel.isHidden = !self.isRecording
//        
//        self.recordTimeLabel.text = formatSeconds(seconds: systemState.currentVideoRecordingTimeInSeconds)
//        
//        if (self.isRecording == true) {
//            if #available(iOS 13.0, *) {
//                self.recordButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
//            }
//            self.modeSwitch.isHidden = true
//        } else {
//            if #available(iOS 13.0, *) {
//                self.recordButton.setImage(UIImage(systemName: "record.circle"), for: .normal)
//            }
//            self.modeSwitch.isHidden = false
//        }
//                
//        //Update UISegmented Control's State
//        if (systemState.mode == DJICameraMode.shootPhoto) {
//            self.modeSwitch.setOn(false, animated: true)
//        } else {
//            self.modeSwitch.setOn(true, animated: true)
//        }
//        
//        
//        if systemState.mode != .recordVideo && systemState.mode != .shootPhoto {
//            return
//        }
//        if needToSetMode == false {
//            return
//        }
//        needToSetMode = false
//        self.setCameraMode(cameraMode: .shootPhoto)
//
//    }
//    
//}
//
//extension CameraFPVViewController {
//    fileprivate func fetchCamera() -> DJICamera? {
//        guard let product = DJISDKManager.product() else {
//            return nil
//        }
//
//        if product is DJIAircraft || product is DJIHandheld {
//            return product.camera
//        }
//        return nil
//    }
//
//    fileprivate func setCameraMode(cameraMode: DJICameraMode = .shootPhoto) {
//        var flatMode: DJIFlatCameraMode = .photoSingle
//        let camera = self.fetchCamera()
//        if camera?.isFlatCameraModeSupported() == true {
//            NSLog("Flat camera mode detected")
//            switch cameraMode {
//            case .shootPhoto:
//                flatMode = .photoSingle
//            case .recordVideo:
//                flatMode = .videoNormal
//            default:
//                flatMode = .photoSingle
//            }
//            camera?.setFlatMode(flatMode, withCompletion: { [weak self] (error: Error?) in
//                if error != nil {
//                    self?.needToSetMode = true
//                    NSLog("Error set camera flat mode photo/video");
//                }
//            })
//            } else {
//                camera?.setMode(cameraMode, withCompletion: {[weak self] (error: Error?) in
//                    if error != nil {
//                        self?.needToSetMode = true
//                        NSLog("Error set mode photo/video");
//                    }
//                })
//            }
//     }
//}
