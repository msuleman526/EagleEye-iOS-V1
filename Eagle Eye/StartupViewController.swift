//
//  StartupViewController.swift
//  DJISDKSwiftDemo
//
//  Created by DJI on 11/13/15.
//  Copyright © 2015 DJI. All rights reserved.
//

import UIKit
import DJISDK
import Alamofire
import SwiftyJSON

class StartupViewController: UIViewController, DJIRemoteControllerDelegate, UITextFieldDelegate{

    weak var appDelegate: AppDelegate! = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var allProjectsView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var projectsTable: UITableView!
    
    @IBOutlet weak var sideBarView: UIView!
    @IBOutlet weak var fpvCameraBtn: UIButton!
    
    @IBOutlet weak var sideBarCloseView: UIView!
    @IBOutlet weak var openComponents: UIButton!
    @IBOutlet weak var bluetoothConnectorButton: UIButton!
    
    
    @IBOutlet weak var searchEdt: UITextField!
    @IBOutlet weak var droneBatteryLbl: UILabel!
    @IBOutlet weak var satteliteLbl: UILabel!
    @IBOutlet weak var remoteBatteryLbl: UILabel!
    @IBOutlet weak var remoteIndicatorImg: UIImageView!
    @IBOutlet weak var remoteSignalImg: UIImageView!
    @IBOutlet weak var remoteBatteryImg: UIImageView!
    @IBOutlet weak var sattelite_signal: UIImageView!
    @IBOutlet weak var droneBatteryImg: UIImageView!
    @IBOutlet weak var satteliteImg: UIImageView!

    @IBOutlet weak var droneNameView1: CustomView!
    @IBOutlet weak var droneNameView: CustomView!
    
    
    //New UI Components
    
    @IBOutlet weak var addNewView: CustomView!
    @IBOutlet weak var searchView: CustomView!
    @IBOutlet weak var logoutPopup: CustomView!
    @IBOutlet weak var startSurveyBtn: CustomView!
    @IBOutlet weak var surveyPopupView: UIView!
    @IBOutlet weak var connectionLbl: UILabel!
    @IBOutlet weak var bigDroneImageView: UIImageView!
    @IBOutlet weak var droneNameLbl: UILabel!
    @IBOutlet weak var dotImgView: UIImageView!
    @IBOutlet weak var droneImageView: UIImageView!
    @IBOutlet weak var surveyPopup: UIView!
    
    @IBOutlet weak var existingProjectBtn: CustomView!
    @IBOutlet weak var logoutView: CustomView!
    @IBOutlet weak var yesLogoutBtn: CustomView!
    @IBOutlet weak var noLogoutBtn: CustomView!
    
    var isDeviceConnected: Bool = false
    var sideBarOpen: Bool = false
    var allProjects: [Project] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.sideBarView.isHidden = true
        self.sideBarCloseView.isHidden = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.sideBarCloseView.addGestureRecognizer(tapGesture)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        self.setUpViews()
        
    }
    
    func setUpViews(){
        self.searchEdt.delegate = self
        
        let surveyPopupCloseGesture = UITapGestureRecognizer(target: self, action: #selector(closeSurveyPopup))
        self.surveyPopupView.addGestureRecognizer(surveyPopupCloseGesture)
        
        let surveyPopupOpenGesture = UITapGestureRecognizer(target: self, action: #selector(startSurveyClck))
        self.startSurveyBtn.addGestureRecognizer(surveyPopupOpenGesture)
        
        let logoutGesture = UITapGestureRecognizer(target: self, action: #selector(logoutBtnClick))
        self.logoutView.addGestureRecognizer(logoutGesture)
        
        let logoutNoGesture = UITapGestureRecognizer(target: self, action: #selector(closeSurveyPopup))
        self.noLogoutBtn.addGestureRecognizer(logoutNoGesture)
        
        let logoutYesGesture = UITapGestureRecognizer(target: self, action: #selector(yesLogoutClick))
        self.yesLogoutBtn.addGestureRecognizer(logoutYesGesture)
        
        let existingProjectGesture = UITapGestureRecognizer(target: self, action: #selector(showExistingProjects))
        self.existingProjectBtn.addGestureRecognizer(existingProjectGesture)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    @objc func showExistingProjects(){
        self.closeSurveyPopup()
        
        self.surveyPopupView.isHidden = false
        self.allProjectsView.isHidden = false
        
        self.surveyPopupView.alpha = 0.8
        self.allProjectsView.alpha = 1.0
        
        self.getAllProjects()
    }
    
    //This will Open the Survey Popup
    @objc func startSurveyClck() {
        self.surveyPopupView.isHidden = false
        self.surveyPopup.isHidden = false
        
        self.surveyPopupView.alpha = 0.8
        self.surveyPopup.alpha = 1.0
        
    }
    
    //This will close the Survey Popup
    @objc func closeSurveyPopup(){
        self.surveyPopupView.isHidden = true
        self.surveyPopup.isHidden = true
        self.logoutPopup.isHidden = true
        self.allProjectsView.isHidden = true
        
        self.surveyPopupView.alpha = 0.0
        self.surveyPopup.alpha = 0.0
        self.logoutPopup.alpha = 0.0
        self.allProjectsView.alpha = 0.0
        
    }
    
    @objc func logoutBtnClick() {
        self.surveyPopupView.isHidden = false
        self.logoutPopup.isHidden = false
        
        self.surveyPopupView.alpha = 0.8
        self.logoutPopup.alpha = 1.0
    }
    
   @objc func yesLogoutClick() {
        self.closeSurveyPopup()
        SessionUtils.userLogout()
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "login") as!
        LoginViewController
        self.navigationController?.pushViewController(nextViewController, animated: false)
    }
    
    
    //This method get all projects using API Call.
    func getAllProjects(){
        loadingView.isHidden = false
        projectsTable.isHidden = true
        searchView.isHidden = true
        addNewView.isHidden = true
        
        do{
            let header = [
                "Accept": "text/json",
                "Authorization": "Bearer \(SessionUtils.getUserToken())"
            ]
            
            let resourceString = "\(Constants.API_LINK)api/project/detailed-projects";
            
            Alamofire.request(resourceString, method: .post, parameters: nil, headers: header).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    if let httpURLResponse = response.response{
                        let response_code = httpURLResponse.statusCode;
                        if response_code == 200 {
                            self.loadingView.isHidden = true
                            self.projectsTable.isHidden = false
                            self.searchView.isHidden = false
                            self.addNewView.isHidden = false
                            do{
                                let json = JSON(value)
                                let str = String(describing: json);
                                let jsonData = str.data(using: .utf8)
                                let decoder = JSONDecoder();
                                let res = try decoder.decode([Project].self, from: jsonData!)
                                self.allProjects = res
                                self.projectsTable.reloadData()
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }else{
                            print(value)
                            self.loadingView.isHidden = true
                            self.projectsTable.isHidden = false
                            self.searchView.isHidden = false
                            self.addNewView.isHidden = false
                            Toast.show(message: "No Internet Connection/Server Issue", controller: self)
                        }
                    }
                case .failure(let error):
                    self.loadingView.isHidden = true
                    self.projectsTable.isHidden = false
                    self.searchView.isHidden = false
                    self.addNewView.isHidden = false
                    Toast.show(message: "There is Some Server Issue.", controller: self)
                    
                }
                
            })
        }
        
    }

    
    @objc func handleTap(){
        self.openAndCloseSidebar()
    }
    
    
    @IBAction func AllProjectBtnClick(_ sender: Any) {
        self.allProjectsView.isHidden = false
        getAllProjects()
    }
    
    func openAndCloseSidebar(){
        if sideBarOpen == false && self.allProjectsView.isHidden == true{
            sideBarOpen = true
            UIView.animate(withDuration: 0.2, animations: {
                self.sideBarView.isHidden = false
            })
            sideBarCloseView.isHidden = false
        }else{
            sideBarOpen = false
            UIView.animate(withDuration: 0.2, animations: {
                self.sideBarView.isHidden = true
            })
            sideBarCloseView.isHidden = true
            self.allProjectsView.isHidden = true
        }
    }
    
    @IBAction func goFlyBtnClick(_ sender: Any) {
        openAndCloseSidebar()
    }
    
    @IBAction func onPanaromaClick(_ sender: Any) {
        if(isDeviceConnected){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "PanaromaViewController") as! PanaromaViewController
            self.navigationController?.pushViewController(nextViewController, animated: false)
        }else{
            self.showPopup(message: "No Aircraft Connected")
        }
    }
    
    @IBAction func onMissionPlannerClick(_ sender: Any) {
        //if(isDeviceConnected){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "TimelineMissionViewController") as! TimelineMissionViewController
            self.navigationController?.pushViewController(nextViewController, animated: false)
        //}else{
           // self.showPopup(message: "No Aircraft Connected")
        //}
    }
    
    @IBAction func onFpvClick(_ sender: Any) {
        //if(isDeviceConnected){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "CameraFPVViewController") as! CameraFPVViewController
            self.navigationController?.pushViewController(nextViewController, animated: false)
        //}else{
          //  self.showPopup(message: "No Aircraft Connected")
        //}
    }
    
    @IBAction func onSettingsBtnClick(_ sender: Any) {
        //if(isDeviceConnected){
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let nextViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.navigationController?.pushViewController(nextViewController, animated: false)
        //}else{
        //    self.showPopup(message: "No Aircraft Connected")
        //}
    }
    
    func showPopup(message: String){
        let alertController = UIAlertController(title: "Connection Waiting", message: message, preferredStyle: .alert)
                
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        self.isDeviceConnected = false
        registerConnectionServices()
        registerTelemetryServices()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Environment.connectionService.stop()
        UIApplication.shared.isIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled
    }
    
    @IBAction func onMediaManagerClick(_ sender: Any) {
        //if(isDeviceConnected){
            let theme: DJIFileManagerTheme.Type = DJIFileManagerDarkTheme.self
            let mediaFilesViewController = DJIMediaFilesViewController(style: theme)
            navigationController?.pushViewController(mediaFilesViewController, animated: true)
            //self.view.window?.rootViewController = RootViewController()
        //}else{
          //  self.showPopup(message: "No Aircraft Connected")
        //}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    func showAlert(_ msg: String?) {
        // create the alert
        let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK : Product connection UI changes

    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func connectDrone(drone: String){
        self.droneNameView1.isHidden = false
        self.droneNameView.isHidden = true
        self.droneNameLbl.text = "\(drone)"
        self.bigDroneImageView.image = UIImage(named: "connected_drone")
        self.droneImageView.image = UIImage(named: "green_drone")
        self.dotImgView.image = UIImage(named: "green_dot")
        self.connectionLbl.text = "Connected"
    }
    
    func disconnectDrone(){
        self.droneNameView1.isHidden = true
        self.droneNameView.isHidden = false
        self.droneNameLbl.text = ""
        self.bigDroneImageView.image = UIImage(named: "disconnected_drone")
        self.droneImageView.image = UIImage(named: "red_drone")
        self.dotImgView.image = UIImage(named: "red_dot")
        self.connectionLbl.text = "Not Connected"
    }
    
}

extension StartupViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.projectsTable.dequeueReusableCell(withIdentifier: "StartProjectCell", for: indexPath) as! StartProjectCell
        
        let project = allProjects[indexPath.row]
        var urlStr = project.address_image
    
        let url = URL(string: urlStr!)
        
        // Create a data task to download the image from the URL
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Error loading image: \(error!)")
                return
            }
            
            // Create an image object from the downloaded data
            let image = UIImage(data: data!)
            
            // Update the UI on the main thread
            DispatchQueue.main.async {
                cell.addressImageView.image = image
            }
        }.resume()
        
        cell.addressNameLbl.text = project.name ?? "No Name"
        cell.addressLbl.text = project.address
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let project = allProjects[index]
        self.handleTap()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextViewController = storyboard.instantiateViewController(withIdentifier: "AddressInfoViewController") as! AddressInfoViewController
        nextViewController.project = project
        self.navigationController?.pushViewController(nextViewController, animated: false)
    }
    
}

class StartProjectCell: UITableViewCell{
    
    @IBOutlet weak var selectedImg: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var addressNameLbl: UILabel!
    @IBOutlet weak var addressImageView: UIImageView!
}

extension StartupViewController{
    func registerConnectionServices(){
        Environment.connectionService.start()
        
        Environment.connectionService.logConsole = { message, type in
            print("MESSAGE \(type) - \(message)")
        }
        
        Environment.connectionService.droneLog = { isConnected, type, drone in
            if(isConnected == true){
                self.connectDrone(drone: drone)
            }else{
                self.disconnectDrone()
            }
        }
    }
    
    func stopConnectionServices(){
        Environment.connectionService.stop()
    }
}

//Telemetery Data
//Extension for Telemetry View
extension StartupViewController{
    
    func registerTelemetryServices(){
        
        Environment.telemetryService.registerListeners()
        
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
    }
    
    func updateFlightMode(_ modeString: String?) {
        var txt = "N/A"
        if(modeString != nil && modeString != ""){
            txt = modeString!
        }
        //self.flightModelLabel.text = txt
    }

    func updateGpsSignalStatus(_ signalStatus: UInt?) {
        let defaultIndicator = UIImage(#imageLiteral(resourceName: "indicatorSignal0"))
        print("Signal Status \(signalStatus)")
        if let status = signalStatus {
            switch status {
            case 0:
                self.sattelite_signal.image = #imageLiteral(resourceName: "indicatorSignal1")
                self.satteliteImg.image = UIImage(named: "sattelite_0")
            case 1:
                self.sattelite_signal.image = #imageLiteral(resourceName: "indicatorSignal2")
                self.satteliteImg.image = UIImage(named: "sattelite_1")
            case 2:
                fallthrough
            case 3:
                self.sattelite_signal.image = #imageLiteral(resourceName: "indicatorSignal3")
                self.satteliteImg.image = UIImage(named: "sattelite_2")
            case 4:
                self.sattelite_signal.image = #imageLiteral(resourceName: "indicatorSignal4")
                self.satteliteImg.image = UIImage(named: "sattelite_2")
            case 5:
                self.sattelite_signal.image = #imageLiteral(resourceName: "indicatorSignal5")
                self.satteliteImg.image = UIImage(named: "sattelite_3")
            default:
                self.sattelite_signal.image = defaultIndicator
                self.satteliteImg.image = UIImage(named: "satellite_red")
            }
        } else {
            self.sattelite_signal.image = defaultIndicator
            self.satteliteImg.image = UIImage(named: "satellite_red")
        }
    }

    func updateGpsSatCount(_ satCount: UInt?) {
        var txt = "0"
        if(satCount != nil){
            txt = String(satCount!)
        }
        self.satteliteLbl.text = txt
    }

    func updateLinkSignalStrength(_ signalStrength: UInt?) {
        
        let defaultIndicator = UIImage(#imageLiteral(resourceName: "indicatorSignal0"))
        if let signalStrength = signalStrength {
            if signalStrength > 0 && signalStrength <= 25 {
                self.remoteIndicatorImg.image = #imageLiteral(resourceName: "indicatorSignal1")
                self.remoteSignalImg.image = UIImage(named: "remote_signal_1")
            } else if signalStrength > 25 && signalStrength <= 50 {
                self.remoteIndicatorImg.image = #imageLiteral(resourceName: "indicatorSignal2")
                self.remoteSignalImg.image = UIImage(named: "remote_signal_2")
            } else if signalStrength > 50 && signalStrength <= 75 {
                self.remoteIndicatorImg.image = #imageLiteral(resourceName: "indicatorSignal3")
                self.remoteSignalImg.image = UIImage(named: "remote_signal_3")
            } else if signalStrength > 75 && signalStrength <= 100 {
                self.remoteIndicatorImg.image = #imageLiteral(resourceName: "indicatorSignal5")
                self.remoteSignalImg.image = UIImage(named: "remote_signal_4")
            }
        } else {
            self.remoteIndicatorImg.image = defaultIndicator
            self.remoteSignalImg.image = UIImage(named: "remote_red")
        }
        
    }
    
    func updateBettery(_ batteryPercentage: UInt?) {
        if let batteryPercentage = batteryPercentage {
            self.droneBatteryLbl.text = String(batteryPercentage) + "%"
            if batteryPercentage > 0 && batteryPercentage <= 50 {
                self.droneBatteryLbl.textColor = Colors.error
                self.droneBatteryImg.image = #imageLiteral(resourceName: "indicatorBattery1")
            } else if batteryPercentage > 25 && batteryPercentage <= 50 {
                self.droneBatteryLbl.textColor = Colors.warning
                self.droneBatteryImg.image = #imageLiteral(resourceName: "indicatorBattery2")
            } else if batteryPercentage > 50 && batteryPercentage <= 75 {
                self.droneBatteryLbl.textColor = Colors.warning
                self.droneBatteryImg.image = UIImage(named: "indicatorBattery3")
            } else {
                self.droneBatteryLbl.textColor = Colors.success
                self.droneBatteryImg.image = UIImage(named: "indicatorBattery4")
            }
        } else {
            self.droneBatteryLbl.text = "0%"
            self.droneBatteryLbl.textColor = UIColor.white
            self.droneBatteryImg.image = UIImage(named: "indicatorBattery0")
        }
    }
}




