//
//  SettingsViewController.swift
//  Eagle Eye
//
//  Created by Mohsin Sherin on 26/07/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate, DJICameraDelegate {
    
    var aircraft: DJIAircraft? = nil
    var flightController: DJIFlightController? = nil
    var remoteController: DJIRemoteController? = nil
    var gimbal: DJIGimbal? = nil
    var camera: DJICamera? = nil
    var isStorageDataAvailable: Bool = false
    
    @IBOutlet weak var flightSerialNumberLbl: UILabel!
    @IBOutlet weak var flightFirmwareLbl: UILabel!
    @IBOutlet weak var smartHomeSwitch: UISwitch!
    @IBOutlet weak var visionSwitch: UISwitch!
    @IBOutlet weak var espBeepSwitch: UISwitch!
    @IBOutlet weak var imuCountLbl: UILabel!
    @IBOutlet weak var seriousLowBatteryEdt: UITextField!
    @IBOutlet weak var lowBatteryEdt: UITextField!
    @IBOutlet weak var goHomeHeightEdt: UITextField!
    @IBOutlet weak var multipleFlightModesSwitch: UISwitch!
    @IBOutlet weak var maximumFlightHeightEdt: UITextField!
    @IBOutlet weak var overAllStatusLbl: UILabel!
    @IBOutlet weak var backBtn: UIImageView!
    
    var maxFlightHeight = 0
    var goHomeHeight = 0
    var lowBetteryThreshhold = 0
    var seriousLowBattery = 0
    
    @IBOutlet weak var remainingStorageLbl: UILabel!
    @IBOutlet weak var totalStorageLbl: UILabel!
    @IBOutlet weak var flatCameraSupported: UILabel!
    @IBOutlet weak var storageLocationLbl: UILabel!
    @IBOutlet weak var isoLbl: UILabel!
    @IBOutlet weak var internalStorageSupportedLbl: UILabel!
    @IBOutlet weak var isDownloadSupported: UILabel!
    @IBOutlet weak var shutterPrioLbl: UILabel!
    @IBOutlet weak var cameraModelLbl: UILabel!
    @IBOutlet weak var cameraDisplayName: UILabel!
    @IBOutlet weak var yawSFESwitch: UISwitch!
    @IBOutlet weak var motorSwitch: UISwitch!
    @IBOutlet weak var remoteVersionLbl: UILabel!
    @IBOutlet weak var gimbleFirmwareVersionLbl: UILabel!
    @IBOutlet weak var aircraftNameLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(goBack))
        backBtn.isUserInteractionEnabled = true
        backBtn.addGestureRecognizer(tapGestureRecognizer)
        
        self.maximumFlightHeightEdt.delegate = self
        self.goHomeHeightEdt.delegate = self
        self.lowBatteryEdt.delegate = self
        self.seriousLowBatteryEdt.delegate = self
        
        self.addDoneButtonToKeyboard(textField: self.maximumFlightHeightEdt, myAction: #selector(doneMaxFlightPath))
        self.addDoneButtonToKeyboard(textField: self.goHomeHeightEdt, myAction: #selector(doneGoHome))
        self.addDoneButtonToKeyboard(textField: self.lowBatteryEdt, myAction: #selector(doneLowBattery))
        self.addDoneButtonToKeyboard(textField: self.seriousLowBatteryEdt, myAction: #selector(doneSeriousLowBattery))
        
        aircraft = DJISDKManager.product() as? DJIAircraft
        flightController = aircraft?.flightController
        remoteController = aircraft?.remoteController
        gimbal = aircraft?.gimbal
        camera = aircraft?.camera

        getDetails()
    }
    
    func addDoneButtonToKeyboard(textField: UITextField, myAction: Selector?){
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.barStyle = UIBarStyle.default

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: myAction)

        var items = [UIBarButtonItem]()
        items.append(flexibleSpace)
        items.append(doneButton)

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        textField.inputAccessoryView = doneToolbar
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func onDoneClick(_ sender: Any) {
        self.goBack()
    }
    
    @objc func goBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func getDetails(){
        aircraftInformation()
        getFlightInformation()
        getRemoteInformation()
        getGimbalInformation()
        //getCameraInformation()
    }
    
    func getCameraInformation(){
        
        camera?.delegate = self
        
        let isSupportAutoISO = camera?.isSupportAutoISO
        self.isoLbl.text = (isSupportAutoISO!) ? "Yes" : "No"
        let isSupportShutterPriority = camera?.isSupportShutterPriority
        self.shutterPrioLbl.text = (isSupportShutterPriority!) ? "Yes" : "No"
        let cameraMode = getCameraMode(mode: DJICameraMode(rawValue: (camera?.mode.rawValue)!)!)
        self.cameraModelLbl.text = cameraMode
        let isMediaDownloadModeSupported = camera?.isMediaDownloadModeSupported()
        self.isDownloadSupported.text = (isMediaDownloadModeSupported!) ? "Yes" : "No"
        let cameraDisplayName = camera?.displayName
        self.cameraDisplayName.text = cameraDisplayName
        let isInternalStorageSupported = camera!.isInternalStorageSupported()
        self.internalStorageSupportedLbl.text = (isInternalStorageSupported) ? "Yes" : "No"
        let isFlatCameraModeSupported = camera!.isFlatCameraModeSupported()
        self.flatCameraSupported.text = (isFlatCameraModeSupported) ? "Yes" : "No"
      
        camera?.getStorageLocation().done({ location in
            if location == .internalStorage{
                self.storageLocationLbl.text = "Internal Storage"
            }else if location == .sdCard{
                self.storageLocationLbl.text = "SD Card"
            }else{
                self.storageLocationLbl.text = "Unknown"
            }
        })
        
    }
    
    func camera(_ camera: DJICamera, didUpdate storageState: DJICameraStorageState) {
        if !isStorageDataAvailable{
            print("Full Storage \(storageState.isFull)")
            print("IsFormating \(storageState.isFormatting)")
            print("Total Size \(storageState.totalSpaceInMB) MB")
            print("Remaining Size \(storageState.remainingSpaceInMB) MB")
            self.totalStorageLbl.text = "\(storageState.totalSpaceInMB) MB"
            self.remainingStorageLbl.text = "\(storageState.remainingSpaceInMB) MB"
            isStorageDataAvailable = true
        }
    }
    
    func getCameraMode (mode: DJICameraMode) -> String{
        if(mode == .broadcast){
            return "BroadCast"
        }else if(mode == .mediaDownload){
            return "Media Download"
        }else if(mode == .playback){
            return "Playback"
        }else if(mode == .recordVideo){
            return "Record Video"
        }else if(mode == .shootPhoto){
            return "Shoot Photo"
        }else{
            return "Unknown"
        }
    }
    
    func aircraftInformation(){
        //Get Aircraft Firmware Version
        aircraft?.getFirmwarePackageVersion(completion: {(value, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                var detail = "Update Firmware - \(value!)"
                if ((value?.hasSuffix("NORMAL")) != nil) {
                    detail = "Normal (Latest Firmware - v\(value!))"
                }
                self.overAllStatusLbl.text = detail
            }
        })
        
        aircraft?.getNameWithCompletion({(value, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.aircraftNameLbl.text = value
            }
        })
    }
    
    func getGimbalInformation(){
        //Get Gimbal Firmware Version
        gimbal?.getFirmwareVersion(completion: {(value, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.gimbleFirmwareVersionLbl.text = String(describing: value!)
            }
        })
        
        gimbal?.getMotorEnabled(completion: {(value, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.motorSwitch.isOn = value
            }
        })
        
        gimbal?.getYawSimultaneousFollowEnabled(completion: {(value, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.yawSFESwitch.isOn = value
            }
        })
        
        
    }
    
    func getFlightInformation(){
        //Get Maximum Flight Height
        flightController?.getMaxFlightHeight(completion: {(value, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.maxFlightHeight = Int(value)
                self.maximumFlightHeightEdt.text = "\(value)"
            }
        })
        
        //Get Multiple Flight Modes
        flightController?.getMultipleFlightModeEnabled(completion: {(value, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.multipleFlightModesSwitch.isOn = value
            }
        })
        
        //Get Low Battery Warning threshold
        flightController?.getLowBatteryWarningThreshold(completion: {(bettery, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.lowBetteryThreshhold = Int(bettery)
                self.lowBatteryEdt.text = "\(bettery)"
            }
        })
        
        //Get Serious Low Battery Warning threshold
        flightController?.getSeriousLowBatteryWarningThreshold(completion: {(bettery, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.seriousLowBattery = Int(bettery)
                self.seriousLowBatteryEdt.text = "\(bettery)"
            }
        })
        
        //Get Go Home Height in meters
        flightController?.getGoHomeHeightInMeters(completion: {(altitude, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.goHomeHeight = Int(altitude)
                self.goHomeHeightEdt.text = "\(altitude)"
            }
        })
        
        //Get ESP Beep Enabled or Disabled
        flightController?.getESCBeepEnabled(completion: {(value, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.espBeepSwitch.isOn = value
            }
        })
        
        //Get Connection Fail Safe Behaviour
        flightController?.getConnectionFailSafeBehavior(completion: {(behaviour, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                print("Fail Safe Behaviour \(behaviour.rawValue)")
            }
        })
        
        //Get Flight Controller Firmware Version
        flightController?.getFirmwareVersion(completion: {(version, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                self.flightFirmwareLbl.text = "v\(String(describing: version!))"
            }
        })
        
        
        let imuCounts = flightController?.imuCount
        self.imuCountLbl.text = "\(String(describing: imuCounts ?? 0))"
        
        flightController?.getVisionAssistedPositioningEnabled(completion: {(vision, error) in
            if let error = error{
                print("Vision Error - \(error)")
            }else{
                self.visionSwitch.isOn = vision
            }
        })
            
        flightController?.getSerialNumber(completion: {(serial, error) in
            if let error = error{
                print("Flight Controller Error - \(error)")
            }else{
                self.flightSerialNumberLbl.text = "\(serial!)"
            }
        })
        
        flightController?.getSmartReturnToHomeEnabled(completion: {(smart, error) in
            if let error = error{
                print("Smart RTH Error - \(error)")
            }else{
                self.smartHomeSwitch.isOn = smart
            }
        })
    
        
    }
    
    func getRemoteInformation(){
        //Get Remote Controller Version
        remoteController?.getFirmwareVersion(completion: { (version, error) in
            if let error = error{
                print(" Error - \(error)")
            }else{
                print("Remote Controller Version \(version!)")
                self.remoteVersionLbl.text = version
            }
        })
        
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @IBAction func changeMultipleModeEnabled(_ sender: Any) {
        flightController?.setMultipleFlightModeEnabled(self.multipleFlightModesSwitch.isOn)
    }
    
    @IBAction func changeYawEnabled(_ sender: Any) {
        gimbal?.setYawSimultaneousFollowEnabled(self.yawSFESwitch.isOn)
    }
    
    @IBAction func changeMotorEnabled(_ sender: Any) {
        gimbal?.setMotorEnabled(self.motorSwitch.isOn)
    }
    
    @IBAction func changeESPBeep(_ sender: Any) {
        flightController?.setESCBeepEnabled(self.espBeepSwitch.isOn)
    }

    @IBAction func changeVisionPositioning(_ sender: Any) {
        flightController?.setVisionAssistedPositioningEnabled(self.visionSwitch.isOn)
    }
    
    @IBAction func changeSmarthome(_ sender: Any) {
        flightController?.setSmartReturnToHomeEnabled(self.smartHomeSwitch.isOn)
    }
    
    @objc func doneMaxFlightPath(){
        self.view.endEditing(true)
        if let text = self.maximumFlightHeightEdt.text, let numberValue = Int(text) {
            if(numberValue < 10 || numberValue > 200){
                self.maximumFlightHeightEdt.text = "\(maxFlightHeight)"
                Toast.show(message: "Max Flight Altitude Range - 10~200", controller: self)
            }else{
                self.maxFlightHeight = numberValue
                flightController?.setMaxFlightHeight(UInt(numberValue))
            }
        } else {
            self.maximumFlightHeightEdt.text = "\(maxFlightHeight)"
            Toast.show(message: "Invalid Input Value, Only Contain Numbers", controller: self)
        }
    }
    
    @objc func doneGoHome(){
        self.view.endEditing(true)
        if let text = self.goHomeHeightEdt.text, let numberValue = Int(text) {
            if(numberValue < 5 || numberValue > 50){
                self.goHomeHeightEdt.text = "\(goHomeHeight)"
                Toast.show(message: "Go Home Height Range - 5~50", controller: self)
            }else{
                self.goHomeHeight = numberValue
                flightController?.setGoHomeHeightInMeters(UInt(numberValue))
            }
        } else {
            self.goHomeHeightEdt.text = "\(goHomeHeight)"
            Toast.show(message: "Invalid Input Value, Only Contain Numbers", controller: self)
        }
    }
    
    @objc func doneLowBattery(){
        self.view.endEditing(true)
        if let text = self.lowBatteryEdt.text, let numberValue = Int(text) {
            if(numberValue < 15 || numberValue > 50){
                self.lowBatteryEdt.text = "\(self.lowBetteryThreshhold)"
                Toast.show(message: "Low Battery Warning Threshold - 15~50", controller: self)
            }else{
                self.lowBetteryThreshhold = numberValue
                flightController?.setLowBatteryWarningThreshold(UInt8(numberValue))
            }
        } else {
            self.lowBatteryEdt.text = "\(lowBetteryThreshhold)"
            Toast.show(message: "Invalid Input Value, Only Contain Numbers", controller: self)
        }
    }
    
    @objc func doneSeriousLowBattery(){
        self.view.endEditing(true)
        if let text = self.seriousLowBatteryEdt.text, let numberValue = Int(text) {
            if(numberValue < 10 || numberValue > 15){
                self.seriousLowBatteryEdt.text = "\(self.seriousLowBattery)"
                Toast.show(message: "Serious Low Battery Warning Threshold - 10~15", controller: self)
            }else{
                self.seriousLowBattery = numberValue
                flightController?.setSeriousLowBatteryWarningThreshold(UInt8(numberValue))
            }
        } else {
            self.seriousLowBatteryEdt.text = "\(seriousLowBattery)"
            Toast.show(message: "Invalid Input Value, Only Contain Numbers", controller: self)
        }
    }
    
    
}
