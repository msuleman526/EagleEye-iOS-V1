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

@available(iOS 13.0, *)
class PanaromaViewController: UIViewController, DJIFlightControllerDelegate{

    @IBOutlet weak var fpvView: UIView!
    @IBOutlet weak var assistantLabel: UILabel!
    @IBOutlet weak var takeOffLandBtn: UIButton!
    @IBOutlet weak var captureButton: UIButton!
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

    var isFlying: Bool? =  false

    var alert: UIAlertController?
    var aircraft: DJIAircraft? = nil
    var flightController: DJIFlightController? = nil
    
    var homeLocation: CLLocation? = nil
    
    let PHOTO_NUMBER: Int = 8
    let ROTATE_ANGLE: Float = 45.0
    var timer: Timer? = nil
    var isPanaromMode: Bool = false
    
    var lastHomeLocation: CLLocation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        aircraft = DJISDKManager.product() as? DJIAircraft
        flightController = aircraft?.flightController
        
        flightController?.delegate = self
        
        assistantLabel.text = "Panaroma Mode"
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        
        alert = UIAlertController(title: "", message: "Drone Flying", preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert!.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert

        needToSetMode = true

        
        let camera = fetchCamera()
        camera?.delegate = self
        
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
        
        })
        
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
    
    
    @IBAction func onBackPress(_ sender: Any) {
        
        if(isFlying == true){
            showAlertViewWithTitle(title: "Flying", withMessage: "Cannot Go Back aircraft is flying")
        }else if(isPanaromMode){
            showAlertViewWithTitle(title: "Panaroma Mode", withMessage: "Cannot Go Back aircraft is in Panaroma Mode")
        }else{
            self.navigationController?.popViewController(animated: true)
        }
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
        takeOffAndGoHome()
    }
    
    func takeOffAndGoHome(){
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

   func showAlertViewWithTitle(title: String, withMessage message: String) {
       let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction.init(title:"OK", style: .default, handler: nil)
       alert.addAction(okAction)
       self.present(alert, animated: true, completion: nil)
   }

    @IBAction func onCapturePhotoClick(_ sender: Any) {
        rotateDroneWithJoyStick()
    }
    
    func rotateDroneWithJoyStick(){
        if let aircraft = aircraft{
            if aircraft.model == DJIAircraftModelNameSpark{
                DJISDKManager.missionControl()?.activeTrackMissionOperator().setGestureModeEnabled(true, withCompletion: { error in
                    if let error = error{
                        self.showAlertViewWithTitle(title: "Mission Track", withMessage: error.localizedDescription)
                    }else{
                        self.setCameraModeToShootPhoto()
                    }
                })
            }else{
                self.setCameraModeToShootPhoto()
            }
        }
    }
    
    func cancelPanaroma(){
        self.isPanaromMode = false
        self.captureButton.setImage(UIImage(systemName: "pano.fill"), for: .normal)
        self.assistantLabel.text = "Panaroma Mode"
    }
    
    
    func setCameraModeToShootPhoto(){
        if(isPanaromMode == false){
            
            if isFlying == true{
            
                if let camera = fetchCamera(){
                    self.isPanaromMode = true
                    self.captureButton.setImage(UIImage(systemName: "autostartstop.slash"), for: .normal)
                    
                    self.assistantLabel.text = "Change Camera Mode to Shoot"
                    if(camera.isFlatCameraModeSupported()){
                        camera.getFlatMode(completion: {(mode: DJIFlatCameraMode?, error: Error?) in
                            if let error = error{
                                self.showAlertViewWithTitle(title: "Camera Mode", withMessage: error.localizedDescription)
                                self.cancelPanaroma()
                            }else{
                                if(mode == .photoSingle){
                                    self.enableVirtualStick()
                                }else{
                                    camera.setFlatMode(.photoSingle, withCompletion: {(error) in
                                        if let error = error{
                                            self.showAlertViewWithTitle(title: "Camera Mode.", withMessage: error.localizedDescription)
                                            self.cancelPanaroma()
                                        }else{
                                            self.enableVirtualStick()
                                        }
                                    })
                                }
                            }
                        })
                    }else{
                        camera.getModeWithCompletion({(mode: DJICameraMode?, error: Error?) in
                            if let error = error{
                                self.showAlertViewWithTitle(title: ".Camera Mode.", withMessage: error.localizedDescription)
                                self.cancelPanaroma()
                            }else{
                                if(mode == .shootPhoto){
                                    self.enableVirtualStick()
                                }else{
                                    camera.setMode(DJICameraMode.shootPhoto, withCompletion: {(error) in
                                        if let error = error{
                                            self.showAlertViewWithTitle(title: "Camera Mode", withMessage: error.localizedDescription)
                                            self.cancelPanaroma()
                                        }else{
                                            self.enableVirtualStick()
                                        }
                                    })
                                }
                            }
                        })
                    }
                }else{
                    self.showAlertViewWithTitle(title: "Flying Mode", withMessage: "Camera is not in flying state.")
                    self.cancelPanaroma()
                }
            }else{
                self.showAlertViewWithTitle(title: "No Camera", withMessage: "No Camera Detected")
                self.cancelPanaroma()
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func enableVirtualStick(){
        if let flightController = flightController {
            flightController.yawControlMode = .angle
            flightController.rollPitchCoordinateSystem = .ground
            
            self.assistantLabel.text = "Enabling Virtual Stick"
            flightController.setVirtualStickModeEnabled(true, withCompletion: { (error: Error?) in
                if let error = error{
                    self.showAlertViewWithTitle(title: "Virtual Stick", withMessage: error.localizedDescription)
                    self.cancelPanaroma()
                }else{
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.02){ [self] in
                        self.executeVirtualStickControl()
                    }
                }
            })
        }else{
            self.showAlertViewWithTitle(title: "Flight Controller", withMessage: "No Flight Controller Detected")
            self.cancelPanaroma()
        }
    }
    
    @objc private func rotateDrone(){
        if let data = timer?.userInfo as? [String: Any] {
            let angle = data["YawAngle"]
            let yawAngle = (angle as? Float) ?? 0.0

            if let flightController = flightController{
                let vsFlightCtrlData = DJIVirtualStickFlightControlData(pitch: 0, roll: 0, yaw: yawAngle, verticalThrottle: 0)
                flightController.isVirtualStickAdvancedModeEnabled = true
                flightController.send(vsFlightCtrlData, withCompletion: { error in
                    if let error = error {
                        self.showAlertViewWithTitle(title: "Flight Controller", withMessage: "Send FlightControl Data Failed \(error.localizedDescription)")
                        self.cancelPanaroma()
                    }else{
                        self.assistantLabel.text = "Successfully rotated at \(yawAngle) Degree"
                    }
                })
            }else{
                self.cancelPanaroma()
                showAlertViewWithTitle(title: "Flight Controller", withMessage: "No Flight Controller Found")
            }
        }
        else{
            self.cancelPanaroma()
            showAlertViewWithTitle(title: "Angle", withMessage: "No Angle Found")
        }
    }
    
    func executeVirtualStickControl(){
        self.assistantLabel.text = "Executing panaroma mode mission"
        if let camera = fetchCamera(){
            for i in (0 ..< PHOTO_NUMBER) {
                var yawAngle: Float = ROTATE_ANGLE*Float(i)
                
                if(yawAngle > 180){
                    yawAngle = yawAngle - 360
                }
                
                self.assistantLabel.text = "Trying to rotate at \(yawAngle) Degree"
                timer = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(rotateDrone), userInfo: [
                    "YawAngle": Float(yawAngle)
                ], repeats: true)
            
                timer!.fire()

                RunLoop.current.add(timer!, forMode: .default)
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 2))

                timer!.invalidate()
                timer = nil
                
                self.assistantLabel.text = "Shoot Photo at \(yawAngle) Degree"
                camera.startShootPhoto(completion: nil)
                sleep(2)
            }
            
            self.assistantLabel.text = "Turn off the Virtual Stick"
            flightController?.setVirtualStickModeEnabled(false, withCompletion: { error in
                if let error = error{
                    self.showAlertViewWithTitle(title: "Vitual Stick Mode", withMessage: error.localizedDescription)
                    self.flightController?.setVirtualStickModeEnabled(false, withCompletion: nil)
                }
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.02){ [self] in
                let alert = UIAlertController(title: "Panaroma", message: "Panaroma image capturing in finished", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .default) { _ in
                    alert.dismiss(animated: false)
                })
                alert.addAction(UIAlertAction(title: "Go Home", style: .default){ _ in
                    alert.dismiss(animated: false)
                    self.takeOffAndGoHome()
                })
                
                self.present(alert, animated: true, completion: nil)
                self.cancelPanaroma()
            }
            
        }else{
            self.showAlertViewWithTitle(title: "Camera", withMessage: "No Camera Detected")
            self.cancelPanaroma()
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        Environment.telemetryService.registerListeners()
        Environment.locationService.registerListeners()
        registerTelemetryServices()
        
        DJIVideoPreviewer.instance()?.setView(fpvView)
    
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

}

/**
 *  DJICamera will send the live stream only when the mode is in DJICameraModeShootPhoto or DJICameraModeRecordVideo. Therefore, in order
 *  to demonstrate the FPV (first person view), we need to switch to mode to one of them.
 */
@available(iOS 13.0, *)
extension PanaromaViewController: DJICameraDelegate {
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

@available(iOS 13.0, *)
extension PanaromaViewController {
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

@available(iOS 13.0, *)
extension PanaromaViewController{
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

