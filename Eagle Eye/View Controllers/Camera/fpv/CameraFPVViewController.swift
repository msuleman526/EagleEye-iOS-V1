//  CameraFPVViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 2019/1/15.
//  Copyright © 2019 DJI. All rights reserved.
//

import UIKit
import DJIWidget
import AVFoundation

class CameraFPVViewController: UIViewController, DJIFlightControllerDelegate{

    var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var recordTimeLabel: UILabel!
    @IBOutlet weak var modeSwitch: UISwitch!
    @IBOutlet weak var fpvView: UIView!

    @IBOutlet weak var takeOffLandBtn: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var hsSpeedTxt: UILabel!
    @IBOutlet weak var distanceTxt: UILabel!
    @IBOutlet weak var altitudeTxt: UILabel!
    @IBOutlet weak var vsSpeedTxt: UILabel!
    @IBOutlet weak var remoteSignalImage: UIImageView!
    @IBOutlet weak var remoteImage: UIImageView!
    @IBOutlet weak var betteryLabel: UILabel!
    @IBOutlet weak var gpsSignalLabel: UILabel!
    @IBOutlet weak var betteryImageView: UIImageView!
    @IBOutlet weak var flightModelLabel: UILabel!
    @IBOutlet weak var gpsImageView: UIImageView!

    var adapter: VideoPreviewerAdapter?
    var needToSetMode = false

    var isRecording : Bool!
    var isFlying: Bool? =  false

    var alert: UIAlertController?
    var aircraft: DJIAircraft? = nil
    var flightController: DJIFlightController? = nil
    
    var homeLocation: CLLocation? = nil
    var lastHomeLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        aircraft = DJISDKManager.product() as? DJIAircraft
        flightController = aircraft?.flightController
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        flightController?.delegate = self
        
        alert = UIAlertController(title: "", message: "Drone Flying", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert!.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        
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
        
        DJISDKManager.missionControl()?.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            if let error = error{
                self.showAlertViewWithTitle(title: "TimeLine", withMessage: error.localizedDescription)
            }
            
//            switch event {
//                case .started
//                    self.didStart()
//                case .stopped:
//                    self.didStop()
//                case .paused:
//                    self.didPause()
//                case .resumed:
//                    self.didResume()
//                default:
//                    break
//            }
        })
        
    }
    
    @IBAction func onBackClick(_ sender: Any) {
        if(isFlying == true){
            showAlertViewWithTitle(title: "Flying", withMessage: "Cannot Go Back aircraft is flying")
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
        if(state.isFlying == true){
            self.isFlying = true
            self.takeOffLandBtn.setImage(UIImage(named: "buttonCommandGoHome"), for: .normal)
        }else{
            self.isFlying = false
            self.takeOffLandBtn.setImage(UIImage(named: "buttonCommandStart"), for: .normal)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    @IBAction func onMissionPlannerClick(_ sender: Any) {
        //self.view.window?.rootViewController = RootViewController()
    }
    
    @IBAction func onMediaLibary(_ sender: Any) {
        
        let theme: DJIFileManagerTheme.Type = DJIFileManagerDarkTheme.self
        let mediaFilesViewController = DJIMediaFilesViewController(style: theme)
        navigationController?.pushViewController(mediaFilesViewController, animated: true)
        
    }

    @IBAction func onTakeOffAndLandBtn(_ sender: Any) {
        DJISDKManager.missionControl()?.unscheduleEverything()
        if isFlying == true{
            let goHomeAction = DJIGoHomeAction()
            goHomeAction.autoConfirmLandingEnabled = false
            DJISDKManager.missionControl()?.scheduleElement(goHomeAction)
        } else {
            DJISDKManager.missionControl()?.scheduleElement(DJITakeOffAction())
        }
        DJISDKManager.missionControl()?.startTimeline()
    }

    func formatSeconds(seconds: UInt) -> String {
           let date = Date(timeIntervalSince1970: TimeInterval(seconds))

           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "mm:ss"
           return(dateFormatter.string(from: date))
       }

       func showAlertViewWithTitle(title: String, withMessage message: String) {
           let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
           let okAction = UIAlertAction.init(title:"OK", style: .default, handler: nil)
           alert.addAction(okAction)
           self.present(alert, animated: true, completion: nil)
       }

    @IBAction func onCapturePhotoClick(_ sender: Any) {
        
        if let camera = fetchCamera(){
            if(camera.isFlatCameraModeSupported()){
                print("Flattt Modee")
                camera.setFlatMode(.photoSingle, withCompletion: {(error) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){ [self] in
                        camera.startShootPhoto(completion: { (error) in
                            if let _ = error {
                                Toast.show(message: "Error " + String(describing: error), controller: self)
                            }
                            else{
                                let pathToSound = Bundle.main.path(forResource: "camera", ofType: "mp3")!
                                let url = URL(fileURLWithPath: pathToSound)
                                
                                do{
                                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                                    self.audioPlayer?.play()
                                }catch{
                                    print("Error while playing camera audio")
                                }
                            }
                        })
                    }
                })
            }else{
                print("Flattt No Modee")
                camera.setMode(DJICameraMode.shootPhoto, withCompletion: {(error) in
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){ [self] in
                        camera.startShootPhoto(completion: { (error) in
                            if let _ = error {
                                Toast.show(message: "Error " + String(describing: error), controller: self)
                            }
                            else{
                                let pathToSound = Bundle.main.path(forResource: "camera", ofType: "mp3")!
                                let url = URL(fileURLWithPath: pathToSound)
                                
                                Toast.show(message: "Picture Captured", controller: self)
                                
                                do{
                                    self.audioPlayer = try AVAudioPlayer(contentsOf: url)
                                    self.audioPlayer?.play()
                                }catch{
                                    print("Error while playing camera audio")
                                }
                            }
                        })
                    }
                })
            }
        }

    }

    @IBAction func onRecordClick(_ sender: Any) {

        if let camera = fetchCamera(){
            print("Recording \(String(describing: self.isRecording))")
            if (self.isRecording) {
                camera.stopRecordVideo(completion: {(error) in
                    if let _ = error {
                        NSLog("Stop Record Video Error: " + String(describing: error))
                    }else{
                        Toast.show(message: "Recording Stopped", controller: self)
                    }
                })
            } else {
                camera.startRecordVideo(completion: {(error) in
                    if let _ = error {
                        NSLog("Stop Record Video Error: " + String(describing: error))
                    }else{
                        Toast.show(message: "Recording Started", controller: self)
                    }
                })
            }
        }

    }

    @IBAction func onModeChangeListener(_ sender: Any) {

        if (self.modeSwitch.isOn == false) {
            self.setCameraMode(cameraMode: .shootPhoto)
            captureButton.isHidden = false
            recordButton.isHidden = true
        } else if (self.modeSwitch.isOn == true) {
            self.setCameraMode(cameraMode: .recordVideo)
            captureButton.isHidden = true
            recordButton.isHidden = false
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DJIVideoPreviewer.instance()?.setView(fpvView)
        navigationController?.setNavigationBarHidden(true, animated: true)
        Environment.telemetryService.registerListeners()
        Environment.locationService.registerListeners()
        registerTelemetryServices()
        
        
        if let camera = fetchCamera(){
            camera.delegate = self
            if camera.isFlatCameraModeSupported() == true {
                camera.setFlatMode(.photoSingle, withCompletion: { [weak self] (error: Error?) in
                    if error != nil {
                        self?.needToSetMode = true
                        print("Error set camera flat mode photo/video \(error)");
                    }
                })
                } else {
                    camera.setMode(.shootPhoto, withCompletion: {[weak self] (error: Error?) in
                        if error != nil {
                            self?.needToSetMode = true
                            print("Error set mode photo/video \(error)");
                        }
                    })
                }
         }
         if adapter == nil{
            DJIVideoPreviewer.instance()?.start()
            adapter = VideoPreviewerAdapter.init()
            adapter?.start()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        Environment.telemetryService.stopListeners()
        Environment.locationService.stopListeners()
        
        // Call unSetView during exiting to release the memory.
        DJIVideoPreviewer.instance()?.unSetView()

        if adapter != nil {
            adapter?.stop()
            adapter = nil
        }
        
        UIApplication.shared.isIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled

    }

    @IBAction func onSwitchValueChanged(_ sender: UISwitch) {
        guard let camera = fetchCamera() else { return }

        let mode: DJICameraThermalMeasurementMode = sender.isOn ? .spotMetering : .disabled
        camera.setThermalMeasurementMode(mode) { [weak self] (error) in
            if error != nil {
               // self?.tempSwitch.setOn(false, animated: true)

                let alert = UIAlertController(title: nil, message: String(format: "Failed to set the measurement mode: %@", error?.localizedDescription ?? "unknown"), preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))

                self?.present(alert, animated: true)
            }
        }

    }

    /**
     *  DJIVideoPreviewer is used to decode the video data and display the decoded frame on the view. DJIVideoPreviewer provides both software
     *  decoding and hardware decoding. When using hardware decoding, for different products, the decoding protocols are different and the hardware decoding is only supported by some products.
     */
    @IBAction func onSegmentControlValueChanged(_ sender: UISegmentedControl) {
        DJIVideoPreviewer.instance()?.enableHardwareDecode = sender.selectedSegmentIndex == 1
    }

    fileprivate func updateThermalCameraUI() {
        guard let camera = fetchCamera(),
        camera.isThermalCamera()
        else {
            //tempSwitch.setOn(false, animated: false)
            return
        }

        camera.getThermalMeasurementMode { [weak self] (mode, error) in
            if error != nil {
                let alert = UIAlertController(title: nil, message: String(format: "Failed to set the measurement mode: %@", error?.localizedDescription ?? "unknown"), preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))

                self?.present(alert, animated: true)

            } else {
                let enabled = mode != .disabled
                //self?.tempSwitch.setOn(enabled, animated: true)

            }
        }
    }
}

/**
 *  DJICamera will send the live stream only when the mode is in DJICameraModeShootPhoto or DJICameraModeRecordVideo. Therefore, in order
 *  to demonstrate the FPV (first person view), we need to switch to mode to one of them.
 */
extension CameraFPVViewController: DJICameraDelegate {
    func camera(_ camera: DJICamera, didUpdate systemState: DJICameraSystemState) {
        self.isRecording = systemState.isRecording
        self.recordTimeLabel.isHidden = !self.isRecording

        self.recordTimeLabel.text = formatSeconds(seconds: systemState.currentVideoRecordingTimeInSeconds)

        if (self.isRecording == true) {
            if #available(iOS 13.0, *) {
                self.recordButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            }
            self.modeSwitch.isHidden = true
        } else {
            if #available(iOS 13.0, *) {
                self.recordButton.setImage(UIImage(systemName: "video"), for: .normal)
            }
            self.modeSwitch.isHidden = false
        }

        //Update UISegmented Control's State
        if (systemState.mode == DJICameraMode.shootPhoto) {
            self.modeSwitch.setOn(false, animated: true)
        } else {
            self.modeSwitch.setOn(true, animated: true)
        }


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

extension CameraFPVViewController {
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

extension CameraFPVViewController{
    func registerTelemetryServices(){
        
        Environment.telemetryService.flightModeChanged = { modeString in
            self.updateFlightMode(modeString)
        }
        Environment.telemetryService.gpsSignalStatusChanged = { signalStatus in
            self.updateGpsSignalStatus(signalStatus)
        }
        Environment.telemetryService.gpsSatCountChanged = { satCount in
            self.updateGpsSatCount(satCount)
        }
        Environment.telemetryService.linkSignalQualityChanged = { signalStrength in
            self.updateLinkSignalStrength(signalStrength)
        }
        Environment.telemetryService.batteryChargeChanged = { batteryPercentage in
            self.updateBettery(batteryPercentage)
        }
        
        Environment.telemetryService.horizontalVelocityChanged = { horizontalVelocity in
            let value = horizontalVelocity != nil ? String(format: "%.1f", horizontalVelocity!) : nil
            self.hsSpeedTxt.text = "\(value ?? "0.0") m/s"
        }
        Environment.telemetryService.verticalVelocityChanged = { verticalVelocity in
            let value = verticalVelocity != nil ? String(format: "%.1f", Utils.trimToZeroAndInvert(verticalVelocity!)) : nil
            self.vsSpeedTxt.text = "\(value ?? "0.0") m/s"
        }
        Environment.telemetryService.altitudeChanged = { altitude in
            var value = altitude != nil ? Double(altitude!) : 0.0
            value = Double(value*3.28084).rounded(toPlaces: 1)
            self.altitudeTxt.text = "\(value) f"
        }
        
        Environment.locationService.aircraftLocationListeners.append({ location in
            if location != nil && self.lastHomeLocation != nil {
                var value = location!.distance(from: self.lastHomeLocation!)
                value = Double(value*3.28084).rounded(toPlaces: 1)
                self.distanceTxt.text = "\(String(format: "%.0f", value)) f"
            } else {
                self.distanceTxt.text = "N/A"
            }
        })
    }
    
    func registerLocationServices(){
        Environment.locationService.aircraftLocationListeners.append({ location in
            if location != nil && self.lastHomeLocation != nil {
                let value = location!.distance(from: self.lastHomeLocation!)
                self.distanceTxt.text = "\(String(format: "%.0f", value)) m"
            } else {
                self.distanceTxt.text = "N/A"
            }
        })
        Environment.locationService.homeLocationListeners.append({ location in
            self.lastHomeLocation = location
        })
    }
    
    func updateFlightMode(_ modeString: String?) {
        var txt = "N/A"
        if(modeString != nil && modeString != ""){
            txt = modeString!
        }
        self.flightModelLabel.text = txt
    }

    func updateGpsSignalStatus(_ signalStatus: UInt?) {
        let defaultIndicator = UIImage(#imageLiteral(resourceName: "indicatorSignal0"))
        if let status = signalStatus {
            switch status {
            case 0:
                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal1")
            case 1:
                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal2")
            case 2:
                fallthrough
            case 3:
                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal3")
            case 4:
                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal4")
            case 5:
                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal5")
            default:
                gpsImageView.image = defaultIndicator
            }
        } else {
            gpsImageView.image = defaultIndicator
        }
    }

    func updateGpsSatCount(_ satCount: UInt?) {
        var txt = "0"
        if(satCount != nil){
            txt = String(satCount!)
        }
        gpsSignalLabel.text = txt
    }

    func updateLinkSignalStrength(_ signalStrength: UInt?) {
        let defaultIndicator = UIImage(named: "remote_red")
        if let signalStrength = signalStrength {
            if signalStrength > 0 && signalStrength <= 25 {
                remoteSignalImage.image = UIImage(named: "remote_signal_1")
            } else if signalStrength > 25 && signalStrength <= 50 {
                remoteSignalImage.image = UIImage(named: "remote_signal_2")
            } else if signalStrength > 50 && signalStrength <= 75 {
                remoteSignalImage.image = UIImage(named: "remote_signal_3")
            } else if signalStrength > 75 && signalStrength <= 100 {
                remoteSignalImage.image = UIImage(named: "remote_signal_4")
            }
        } else {
            remoteSignalImage.image = defaultIndicator
        }
        
    }
    
    func updateBettery(_ batteryPercentage: UInt?) {
        if let batteryPercentage = batteryPercentage {
            self.betteryLabel.text = String(batteryPercentage) + "%"
            if batteryPercentage > 0 && batteryPercentage <= 50 {
                self.betteryLabel.textColor = Colors.error
                self.betteryImageView.image = #imageLiteral(resourceName: "indicatorBattery1")
            } else if batteryPercentage > 25 && batteryPercentage <= 50 {
                self.betteryLabel.textColor = Colors.warning
                self.betteryImageView.image = UIImage(named: "indicatorBattery3")
            } else if batteryPercentage > 50 && batteryPercentage <= 75 {
                self.betteryLabel.textColor = Colors.warning
                self.betteryImageView.image = UIImage(named: "indicatorBattery3")
            } else {
                self.betteryLabel.textColor = Colors.success
                self.betteryImageView.image = UIImage(named: "indicatorBattery4")
            }
        } else {
            self.betteryLabel.text = "0%"
            self.betteryLabel.textColor = UIColor.white
            self.betteryImageView.image = UIImage(named: "indicatorBattery0")
        }
    }
}
