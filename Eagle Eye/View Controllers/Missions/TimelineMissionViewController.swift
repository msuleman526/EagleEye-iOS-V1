//
//  TimelineMissionViewController.swift
//  SDK Swift Sample
//
//  Created by Arnaud Thiercelin on 3/22/17.
//  Copyright © 2017 DJI. All rights reserved.
//

import UIKit
import os.log
import SwiftyJSON
import GoogleMaps
import Alamofire
import DJISDK
import iOSDropDown

enum TimelineElementKind: String {
    case takeOff = "Take Off"
    case goTo = "Go To"
    case goHome = "Go Home"
    case gimbalAttitude = "Gimbal Attitude"
    case singleShootPhoto = "Single Photo"
    case continuousShootPhoto = "Continuous Photo"
    case recordVideoDuration = "Record Duration"
    case recordVideoStart = "Start Record"
    case recordVideoStop = "Stop Record"
    case waypointMission = "Waypoint Mission"
    case hotpointMission = "Hotpoint Mission"
    case aircraftYaw = "Aircraft Yaw"
}

@available(iOS 13.0, *)
class TimelineMissionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DJICameraDelegate, DJIFlightControllerDelegate, DJIFlyZoneDelegate{
    
    //Mission Setting Components
    var missionSetting = MissionSetting()
    let finishActions: [DJIWaypointMissionFinishedAction] = [.noAction, .autoLand, .continueUntilStop, .goFirstWaypoint, .goHome]
    let headingMode: [DJIWaypointMissionHeadingMode] = [.auto, .controlledByRemoteController, .towardPointOfInterest, .usingInitialDirection, .usingWaypointHeading]
    let finishActionsTxts: [String] = ["No Action", "Auto Land", "Continue Util Stop", "Go First Waypoint", "Go Home"]
    let headModesTxts: [String] = ["Auto", "Control By Remote", "Towards POI", "Using Initial Direction", "Using Waypoint Heading"]

    @IBOutlet weak var projectsTableView: UITableView!
    
    @IBOutlet weak var commandStopBtn: UIButton!
    @IBOutlet weak var commandGoHomeBtn: UIButton!
    @IBOutlet weak var commandResumeBtn: UIButton!
    @IBOutlet weak var commandPauseBtn: UIButton!
    @IBOutlet weak var commandStartBtn: ProgressButton!
    @IBOutlet weak var commandView: UIView!
    
    @IBOutlet weak var showHelpViewBox: UIView!
    @IBOutlet weak var uploadMissionBtn: UIButton!
    
    @IBOutlet weak var uploadMissionAndStartBtn: UIButton!
    
    @IBOutlet weak var poiBar: UISlider!
    @IBOutlet weak var poiHeightLbl: UILabel!
    @IBOutlet weak var assistantLbl: UILabel!
    //Mission Setting Views
    @IBOutlet weak var missionSettingView: UIView!
    @IBOutlet weak var missionSettingLabel: UILabel!
    @IBOutlet weak var maxFlightSpeedPlusBtn: UIButton!
    @IBOutlet weak var maxFlightSpeedMinusBtn: UIButton!
    
    
    @IBOutlet weak var deleteWaypointBtn: UIButton!
    
    @IBOutlet weak var maxFlightSpeedBar: UISlider!
    @IBOutlet weak var maxFlightSpeedLbl: UILabel!
    @IBOutlet weak var autoSpeedLbl: UILabel!
    @IBOutlet weak var rotateGimbalBar: UISegmentedControl!
    @IBOutlet weak var connectionLoseBar: UISegmentedControl!
    @IBOutlet weak var autoSpeedBar: UISlider!
    @IBOutlet weak var repeatTimesLbl: UILabel!
    @IBOutlet weak var repeatTimesBar: UISlider!
    @IBOutlet weak var goToBar: UISegmentedControl!
    @IBOutlet weak var finishActionDropDown: DropDown!
    @IBOutlet weak var waypointPathBar: UISegmentedControl!
    @IBOutlet weak var headingModeDropdown: DropDown!
    
    //WayPoint Setting Views
    
    @IBOutlet weak var gimbalPitchBar: UISlider!
    @IBOutlet weak var gimbalPicthLbl: UILabel!
    @IBOutlet weak var turnModeBar: UISegmentedControl!
    @IBOutlet weak var cornerRadiusBar: UISlider!
    @IBOutlet weak var cornerRadiusLbl: UILabel!
    @IBOutlet weak var actionTimeoutBar: UISlider!
    @IBOutlet weak var actionTimoutLbl: UILabel!
    @IBOutlet weak var wayPointRepeatTimeBar: UISlider!
    @IBOutlet weak var wayPointRepeatTimeLbl: UILabel!
    @IBOutlet weak var headingBar: UISlider!
    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var altitudeBar: UISlider!
    @IBOutlet weak var altitudeLbl: UILabel!
    @IBOutlet weak var waypointSettingView: UIView!
    @IBOutlet weak var wayPointLabl: UILabel!
    var selectedWayPoint: Int = 0
    
    @IBOutlet weak var flyZoneInfoView: UIView!
    @IBOutlet weak var availableElementsView: UICollectionView!
    @IBOutlet weak var simulatorSwitch: UISwitch!
    
    @IBOutlet weak var googleMapView: GMSMapView!
    @IBOutlet weak var timelineView: UICollectionView!
    @IBOutlet weak var cameraFPVView: UIView!
    @IBOutlet weak var drawBtn: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var cameraContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cameraContainer: UIView!
    @IBOutlet weak var cameraBtn: UIButton!
    
    @IBOutlet weak var takeOffLandBtn: UIButton!
    
    @IBOutlet weak var connectionLbl: UILabel!
    @IBOutlet weak var homeDrawBtn: UIButton!
    
    @IBOutlet weak var flightModelLabel: UILabel!
    @IBOutlet weak var gpsImageView: UIImageView!
    
    @IBOutlet weak var remoteSignalImage: UIImageView!
    @IBOutlet weak var remoteImage: UIImageView!
    @IBOutlet weak var betteryLabel: UILabel!
    @IBOutlet weak var gpsSignalLabel: UILabel!
    @IBOutlet weak var betteryImageView: UIImageView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var vsSpeedLabel: UILabel!
    @IBOutlet weak var hsSpeedLabel: UILabel!
    
    @IBOutlet weak var deleteWaypointsSettings: UIButton!
    @IBOutlet weak var allWaypointsSettingsBtn: UIButton!
    @IBOutlet weak var missionSettingBtn: UIButton!
    @IBOutlet weak var waypointSettingBtn: UIButton!
    
    
    @IBOutlet weak var projectsListBtn: UIButton!
    
    
    @IBOutlet weak var obstacleSlider: UISlider!
    @IBOutlet weak var heightOFHouseSlider: UISlider!
    @IBOutlet weak var projectDetailView: UIView!
    @IBOutlet weak var heightOfHouseLbl: UILabel!
    @IBOutlet weak var maxObstacleLbl: UILabel!
    @IBOutlet weak var innerCircleLbl: UILabel!
    @IBOutlet weak var obstableWaypointLbl: UILabel!
    @IBOutlet weak var outerCircleLbl: UILabel!
    
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var projectLbl: UILabel!
    
    @IBOutlet weak var projectsListView: UIView!
    @IBOutlet weak var hideProjectsListBtn: UIButton!
    var availableElements = [TimelineElementKind]()
    var adapter: VideoPreviewerAdapter?
    
    var points: [GMSMarker] = []
    var waypointsList: [WaypointSetting] = []
    var allOverLays: [GMSOverlay] = []
    var polyline:GMSPolyline?
    
    var homeAnnotation = MovingObject(CLLocationCoordinate2D(), 0.0, .home)
    var aircraftAnnotation = MovingObject(CLLocationCoordinate2D(), 0.0, .aircraft)
    var userAnnotation = MovingObject(CLLocationCoordinate2D(), 0.0, .user)
    
    var aircraftAnnotationView: MovingObject!
    var droneLocation:CLLocation?
    var locationManager = CLLocationManager()
    var tapRecognizer = UILongPressGestureRecognizer()
    var panRecognizer = UIPanGestureRecognizer()
    
    // Computed properties
    var userLocation: CLLocationCoordinate2D? {
        return objectPresentOnMap(userAnnotation) ? userAnnotation.position : nil
    }
    
    var scheduledElements = [TimelineElementKind]()
    var isProductConnectd:Bool = false
    var isDrawing: Bool = false
    var isHomeDrawing: Bool = false
    var polygonDrawingCompleted: Bool = true
    var obsMarkers: [[GMSMarker]] = []
    var obsPolygonPaths: [GMSMutablePath] = []
    var obsPolygons: [GMSPolygon] = []
    
    fileprivate var _isSimulatorActive: Bool = false
    
    var allSurroundingPolygons: [DJIFlyZoneInformation] = []
    
    public var isSimulatorActive: Bool {
        get {
            return _isSimulatorActive
        }
        set {
            _isSimulatorActive = newValue
        }
    }
    
    @IBOutlet weak var flyZoneType: UILabel!
    @IBOutlet weak var flyZoneLevel: UILabel!
    @IBOutlet weak var flyZoneName: UILabel!
    @IBOutlet weak var flyZoneImage: UIImageView!
    
    
    var isFlying:Bool = false
    
    var isFullCamera: Bool = false
    var pointOfInterest: GMSMarker? = nil
    
    //Telemetry View
    var lastHomeLocation: CLLocation?
    
    fileprivate var started = false
    fileprivate var paused = false
    
    var aircraft: DJIAircraft? = nil
    var flightController: DJIFlightController? = nil
    
    var isSeprateWaypointSetting:Bool = false
    var allWaypointSetting: WaypointSetting? = nil
    
    @IBOutlet weak var previousWaypointBtn: UIButton!
    @IBOutlet weak var nextWaypointBtn: UIButton!
    
    var allProjects:[Project] = []
    var alert : UIAlertController?
    var selectProject: Project?
    var mustHeight = 0
    var selectedProject: Project?
    var isFlightContinue: Bool = false
    
    var djiFlyZoneManager: DJIFlyZoneManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.showHelpViewBox.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        initView()
        UIApplication.shared.isIdleTimerDisabled = true
        aircraft = DJISDKManager.product() as? DJIAircraft
        flightController = aircraft?.flightController
        selectProject = Project()
        alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        flightController?.delegate = self
    
        self.cameraBtn.isHidden = false
        self.connectionLbl.text = "Connected"
        self.connectionLbl.textColor = .green
        
        initFlyZone()
        
        self.commandStartBtn.actionCompletion = { [weak self] in
            self?.commandStartBtnClick()
        }
    }
    
    @objc func buttonPressed() {
        print("Press")
    }

    @objc func buttonLongPressed(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            print("Began")
        }
    }
    
    @IBAction func onFlyZoneInfoCloseClick(_ sender: Any) {
        self.flyZoneInfoView.isHidden = true
    }
    
    
    func initFlyZone(){
        print("Getting Fly Zone Info")
        
        djiFlyZoneManager =  DJISDKManager.flyZoneManager()
        djiFlyZoneManager!.delegate = self
        
        djiFlyZoneManager!.getFlyZonesInSurroundingArea(completion: { (flyZoneAreaInfo, error) in
            if let error = error{
                print("Error on FlyZone Manager \(error)")
            }else{
                self.allSurroundingPolygons = flyZoneAreaInfo!
                for i in (0 ..< flyZoneAreaInfo!.count) {
                    let info = flyZoneAreaInfo![i]
                    let location = info.center
                    let marker  = GMSMarker(position: location)
                    marker.map = self.googleMapView
                    
                    print("Reason \(info.reason)")
                    
                    let category = info.category
                    
                    let categoryData = Utils.getCategoryColors(category: category)
                    let fillColor: UIColor = categoryData["fillColor"] as! UIColor
                    let strokeColor: UIColor = categoryData["strokeColor"] as! UIColor
                    let categoryStr = categoryData["category"]

                    let subFlyZones = info.subFlyZones
                    for j in (0 ..< subFlyZones!.count) {
                        let subFlyZone = subFlyZones![j]
                        let vertices = subFlyZone.vertices
                        
                        let pa = GMSMutablePath()
                        
                        for point in vertices {
                            pa.add(point as! CLLocationCoordinate2D)
                        }
                        let polygon = GMSPolygon(path: pa)
                        polygon.title = "No Fly Zone:-\(info.flyZoneID)"
                        polygon.strokeColor = strokeColor
                        polygon.fillColor = fillColor
                        polygon.strokeWidth = 1
                        polygon.isTappable = true
                        polygon.map = self.googleMapView
                    }
                    
                }
            }
        })
    }
    
    
    
    func flyZoneManager(_ manager: DJIFlyZoneManager, didUpdate state: DJIFlyZoneState) {
        print("Calling FlyZone didUpdate")
    }
    
    func flyZoneManager(_ manager: DJIFlyZoneManager, didUpdateBasicDatabaseUpgradeProgress progress: Float, andError error: Error?) {
        print("Calling FlyZone didUpdateBasicDatabaseUpgradeProgress")
    }
    
    func flyZoneManager(_ manager: DJIFlyZoneManager, didUpdateFlyZoneNotification notification: DJIFlySafeNotification) {
        print("Calling FlyZone didUpdateFlyZoneNotification")
    }
    
    func initView(){
        self.setUpCamera()
        
        self.availableElementsView.delegate = self
        self.availableElementsView.dataSource = self
        
        self.timelineView.delegate = self
        self.timelineView.dataSource = self
        
        self.availableElements.append(contentsOf: [.takeOff, .goTo, .goHome, .gimbalAttitude, .singleShootPhoto, .continuousShootPhoto, .recordVideoDuration, .recordVideoStart, .recordVideoStop, .waypointMission, .hotpointMission, .aircraftYaw])
        
        googleMapView.delegate = self
        googleMapView.delegate = self
        googleMapView.mapType = .hybrid
    
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        
        
        registerTelemetryServices()
        registerListeners()
        registerCommandListeners()
        registerConsoleListeners()
        
        self.setUpMissionViewValues()
        self.setUpWaypointSettingViewValues()
        
        //Getting Drone State
        self.loadMissionData()
    
        weak var weakSelf = self
        if let isSimulatorActiveKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsSimulatorActive) {
            let simulatorActiveValue : DJIKeyedValue? = DJISDKManager.keyManager()?.getValueFor(isSimulatorActiveKey)
            if simulatorActiveValue != nil{
                weakSelf?.simulatorSwitch.isOn = (simulatorActiveValue?.boolValue)!
                weakSelf?._isSimulatorActive = (simulatorActiveValue?.boolValue)!
            }
            DJISDKManager.keyManager()?.startListeningForChanges(on: isSimulatorActiveKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
                if newValue?.boolValue != nil {
                    weakSelf?._isSimulatorActive = (newValue?.boolValue)!
                    weakSelf?.simulatorSwitch.isOn = (newValue?.boolValue)!
                }
            })
        }
    

    }
    
    func loadMissionData(){
        
        if let missionOperater = DJISDKManager.missionControl()?.waypointMissionOperator(){
            let currentState = missionOperater.currentState
            if currentState != nil {
                Environment.commandService.activeExecutionState = currentState
                switch currentState {
                    case .executing:
                        Environment.missionStateManager.state = .running
                    case .notSupported:
                        Environment.missionStateManager.state = .notSupported
                    case .executionPaused:
                        Environment.missionStateManager.state = .paused
                    case .readyToExecute:
                        Environment.missionStateManager.state = .uploaded
                    default:
                        break
                }
                
                let newState = Environment.missionStateManager.state
                if newState != .none && newState != .editing {
                    self.setControls(for: newState)
                    self.toggleShowView(show: true, delay: Animations.defaultDelay)
                } else {
                    self.uploadMissionAndStartBtn.isHidden = false
                    self.toggleShowView(show: false, delay: 0)
                }
                
            }else{
                Toast.show(message: "Unable to get Current State of Mission", controller: self)
            }
        }
        
        self.loadRunningWaypointsAndObstacles()
    
    }
    
    func loadRunningWaypointsAndObstacles(){
        //Load Point of Interest
        let poiLoc = SessionUtils.getPointOfInterest()
        if poiLoc.latitude != 0.0 && poiLoc.longitude != 0.0
        {
            self.projectsListView.isHidden = true
            
            if(pointOfInterest != nil){
                self.deleteWaypointsAndPOI()
            }
            
            //Draw New Waypoints
            pointOfInterest = GMSMarker()
            pointOfInterest = self.drawModifiedMarker(annotation: MovingObject(CLLocationCoordinate2D(latitude: poiLoc.latitude, longitude: poiLoc.longitude), 0.0, .point_of_interest))
            pointOfInterest!.title = "Point of Interest"
            pointOfInterest!.map = googleMapView
            
            SessionUtils.savePointOfInterest(location: CLLocationCoordinate2D(latitude: poiLoc.latitude, longitude: poiLoc.longitude))
            
            let newCamera = GMSCameraPosition.camera(withLatitude: poiLoc.latitude, longitude: poiLoc.longitude, zoom: 18.5)
            let update = GMSCameraUpdate.setCamera(newCamera)
            googleMapView.animate(with: update)
        }
        
        //Load All Waypoints
        waypointsList = SessionUtils.getWaypoints()
        for waypointSetting in waypointsList{
            
            let latitude = waypointSetting.latittude!
            let longitude = waypointSetting.longitude!
            
            var point = MovingObject(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), 0.0, .draw_point)
            point.title = "Waypoint -  \(points.count+1)"
            point = self.drawModifiedMarker(annotation: point)
            points.append(point)
            point.map = googleMapView
            
            connectPoints()
        }
        
        //Load All Obstacles
        removeAllObstacles()
        let obstacle_boundary = SessionUtils.getObstacles()
        if(obstacle_boundary != nil && obstacle_boundary != ""){
            let jsonData2 = obstacle_boundary.data(using: .utf8)!
            let decoder2 = JSONDecoder()
            let obstacleBoundary = try! decoder2.decode([[WaypointAddress]].self, from: jsonData2)
            
            for i in (0..<obstacleBoundary.count){
                self.polygonDrawingCompleted = true
                for j in (0..<obstacleBoundary[i].count){
                    self.drawOnMap(coordinate: CLLocationCoordinate2D(latitude: obstacleBoundary[i][j].lat!, longitude: obstacleBoundary[i][j].lng!), mapView: self.googleMapView)
                }
            }
        }
    }
    
    
    //All IBActions List
    @IBAction func projectFolderButtonClick(_ sender: Any) {
        if isFlightContinue == false{
            self.projectsListView.isHidden = false
            getAllProjects()
        }else{
            self.showAlertViewWithTitle(title: "Flight In Progress", withMessage: "You cannot perform this action during flight.")
        }
    }
    
    
    @IBAction func uploadMissionAndStart(_ sender: Any) {
        
        if(pointOfInterest == nil){
            self.showAlertViewWithTitle(title: "No POI", withMessage: "No POI found.")
        }else if(self.waypointsList.count == 0){
            self.showAlertViewWithTitle(title: "No Waypoint", withMessage: "Please draw waypoints for mission")
        }else{
            
            let alert = UIAlertController(title: "Start Mission", message: "Do you want to upload mission and start or just upload mission", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Upload", style: .default) { [self] _ in
                alert.dismiss(animated: false)
                
                let uploadAlert: UIAlertController?
                uploadAlert = UIAlertController(title: "Uploading Mission", message: "Mission is being uploaded.", preferredStyle: .alert)
                
                let activityIndicator = UIActivityIndicatorView(style: .medium)
                activityIndicator.color = UIColor.blue
                activityIndicator.startAnimating()
                
                // Add the activity indicator to the alert controller
                uploadAlert!.view.addSubview(activityIndicator)

                // Position the activity indicator
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                activityIndicator.centerXAnchor.constraint(equalTo: uploadAlert!.view.centerXAnchor).isActive = true
                activityIndicator.centerYAnchor.constraint(equalTo: uploadAlert!.view.centerYAnchor, constant: 28).isActive = true
                
                self.present(uploadAlert!, animated: true, completion: nil)
                
                if(Environment.commandService.setMissionCoordinatesWithPOI(self.waypointsList, missionSetting: self.missionSetting, poi: CLLocationCoordinate2D(latitude: (pointOfInterest?.position.latitude)!, longitude: (pointOfInterest?.position.longitude)!))){
                    Environment.commandService.executeMissionCommand(.upload)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        uploadAlert?.dismiss(animated: false)
                    }
                    
                }else{
                    uploadAlert?.dismiss(animated: false)
                }
            })
            
            alert.addAction(UIAlertAction(title: "Upload and Start", style: .default) { [self] _ in
                alert.dismiss(animated: false)
                
                let uploadAlert: UIAlertController?
                uploadAlert = UIAlertController(title: "Uploading Mission", message: "Mission is being uploaded.", preferredStyle: .alert)
                
                let activityIndicator = UIActivityIndicatorView(style: .medium)
                activityIndicator.color = UIColor.blue
                activityIndicator.startAnimating()
                
                // Add the activity indicator to the alert controller
                uploadAlert!.view.addSubview(activityIndicator)

                // Position the activity indicator
                activityIndicator.translatesAutoresizingMaskIntoConstraints = false
                activityIndicator.centerXAnchor.constraint(equalTo: uploadAlert!.view.centerXAnchor).isActive = true
                activityIndicator.centerYAnchor.constraint(equalTo: uploadAlert!.view.centerYAnchor, constant: 28).isActive = true

                self.present(uploadAlert!, animated: true, completion: nil)
                
                if(Environment.commandService.setMissionCoordinatesWithPOI(self.waypointsList, missionSetting: self.missionSetting, poi: CLLocationCoordinate2D(latitude: (self.pointOfInterest?.position.latitude)!, longitude: (self.pointOfInterest?.position.longitude)!))){
                
                    Environment.commandService.executeMissionCommand(.upload)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 7.0) {
                        Environment.commandService.executeMissionCommand(.start)
                        self.uploadMissionAndStartBtn.isHidden = true
                        uploadAlert?.dismiss(animated: false)
                    }
                    
                }else{
                    uploadAlert?.dismiss(animated: false)
                }
            })
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func showHelpView(_ sender: Any) {
        self.showHelpViewBox.isHidden = false
    }
    
    @IBAction func closeHelpView(_ sender: Any) {
        self.showHelpViewBox.isHidden = true
    }
    
    func getAllProjects(){
        present(alert!, animated: false, completion: nil)
        do{
            let header = [
                "Accept": "text/json",
                "Authorization": "Bearer \(SessionUtils.getUserToken())"
            ]
            
            let resourceString = "\(Constants.API_LINK)api/project/all";
            
            Alamofire.request(resourceString, method: .post, parameters: nil, headers: header).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    if let httpURLResponse = response.response{
                        let response_code = httpURLResponse.statusCode;
                        if response_code == 200 {
                            print(value)
                            self.alert?.dismiss(animated: false, completion: nil)
                            do{
                                let json = JSON(value)
                                let str = String(describing: json);
                                let jsonData = str.data(using: .utf8)
                                let decoder = JSONDecoder();
                                let res = try decoder.decode([Project].self, from: jsonData!)
                                print("Projects Length \(res.count)")
                                self.allProjects = res
                                self.projectsTableView.reloadData()
                            } catch let error {
                                print(error.localizedDescription)
                            }
                        }else{
                            print(value)
                            self.alert?.dismiss(animated: false, completion: nil)
                            Toast.show(message: "No Internet Connection/Server Issue", controller: self)
                        }
                    }
                case .failure(let error):
                    self.alert?.dismiss(animated: false, completion: nil)
                    Toast.show(message: "There is Some Server Issue.", controller: self)
                    
                }
                
            })
        }
        
    }

    @IBAction func onHideProjectsListClick(_ sender: Any) {
        self.projectsListView.isHidden = true
    }
    
    @IBAction func onAllWaypointSettingClick(_ sender: Any) {
        if isFlightContinue == false{
            self.nextWaypointBtn.isHidden = true
            self.previousWaypointBtn.isHidden = true
            isSeprateWaypointSetting = false
            if(waypointsList.count == 0){
                self.showAlertViewWithTitle(title: "No Waypoints", withMessage: "Please draw waypoints")
            }else{
                self.missionSettingView.isHidden = true
                self.waypointSettingView.isHidden = false
                self.setUpWaypointValues()
            }
        }else{
            self.showAlertViewWithTitle(title: "Flight In Progress", withMessage: "You cannot perform this action during flight.")
        }
    }
    
    
    @IBAction func onWaypointSettingBtnClick(_ sender: Any) {
        if isFlightContinue == false{
            self.nextWaypointBtn.isHidden = false
            self.previousWaypointBtn.isHidden = false
            isSeprateWaypointSetting = true
            if(waypointsList.count == 0){
                self.showAlertViewWithTitle(title: "No Waypoints", withMessage: "Please draw waypoints")
            }else{
                self.missionSettingView.isHidden = true
                self.waypointSettingView.isHidden = false
                self.setUpWaypointValues()
                
            }
        }else{
            self.showAlertViewWithTitle(title: "Flight In Progress", withMessage: "You cannot perform this action during flight.")
        }
    }
    
    
    @IBAction func onMissionSettingBtnClick(_ sender: Any) {
        if isFlightContinue == false{
            self.missionSettingView.isHidden = false
            self.waypointSettingView.isHidden = true
            self.setUpMissionValues()
        }else{
            self.showAlertViewWithTitle(title: "Flight In Progress", withMessage: "You cannot perform this action during flight.")
        }
    }
    
    @IBAction func onCloseMissionSettingClick(_ sender: Any) {
        self.missionSettingView.isHidden = true
    }
    
    @IBAction func onSaveMissionSettingClick(_ sender: Any) {
        
        missionSetting.maxFlightSpeed = Int(self.maxFlightSpeedBar.value)
        missionSetting.autoFlightSpeed = Int(self.autoSpeedBar.value)
        missionSetting.repeatTimes = Int(self.repeatTimesBar.value)
        missionSetting.poiHeight = Int(self.poiBar.value)
        
        if self.rotateGimbalBar.selectedSegmentIndex == 0{
            missionSetting.rotateGimblePitch = false
        }else{
            missionSetting.rotateGimblePitch = true
        }
        
        if self.connectionLoseBar.selectedSegmentIndex == 0{
            missionSetting.exitMissionOnRCSignalLost = false
        }else{
            missionSetting.exitMissionOnRCSignalLost = true
        }
        
        if self.goToBar.selectedSegmentIndex == 0{
            missionSetting.gotoFirstWaypointMode = .safely
        }else{
            missionSetting.gotoFirstWaypointMode = .pointToPoint
        }
        
        if self.waypointPathBar.selectedSegmentIndex == 0{
            missionSetting.flightPathMode = .normal
        }else{
            missionSetting.flightPathMode = .curved
        }
        
        missionSetting.finishAction = self.finishActions[self.finishActionDropDown.selectedIndex!]
        missionSetting.headingMode = self.headingMode[self.headingModeDropdown.selectedIndex!]
        
        
    }
    
    @IBAction func onSaveWaypointSetting(_ sender: Any) {
        
        if(isSeprateWaypointSetting == true){
            
            self.waypointsList[selectedWayPoint].altitude = Double(self.altitudeBar.value)
            self.waypointsList[selectedWayPoint].heading = Double(self.headingBar.value)
            self.waypointsList[selectedWayPoint].actionRepeatTimes = Int(self.wayPointRepeatTimeBar.value)
            self.waypointsList[selectedWayPoint].actionTimeoutInSeconds = Int(self.actionTimeoutBar.value)
            self.waypointsList[selectedWayPoint].cornerRadiusInMeters = Int(self.cornerRadiusBar.value)
            self.waypointsList[selectedWayPoint].gimbalPitch = Int(self.gimbalPitchBar.value)
            
            if self.turnModeBar.selectedSegmentIndex == 0{
                self.waypointsList[selectedWayPoint].turnMode = DJIWaypointTurnMode.clockwise.rawValue
            }else{
                self.waypointsList[selectedWayPoint].turnMode = DJIWaypointTurnMode.counterClockwise.rawValue
            }
            Toast.show(message: "Waypoint \(Int(selectedWayPoint) + 1) setting saved", controller: self)
        }else{
            for i in (0 ..< self.waypointsList.count) {
                self.waypointsList[i].altitude = Double(self.altitudeBar.value)
                self.waypointsList[i].heading = Double(self.headingBar.value)
                self.waypointsList[i].actionRepeatTimes = Int(self.wayPointRepeatTimeBar.value)
                self.waypointsList[i].actionTimeoutInSeconds = Int(self.actionTimeoutBar.value)
                self.waypointsList[i].cornerRadiusInMeters = Int(self.cornerRadiusBar.value)
                self.waypointsList[i].gimbalPitch = Int(self.gimbalPitchBar.value)
                
                if self.turnModeBar.selectedSegmentIndex == 0{
                    self.waypointsList[i].turnMode = DJIWaypointTurnMode.clockwise.rawValue
                }else{
                    self.waypointsList[i].turnMode = DJIWaypointTurnMode.counterClockwise.rawValue
                }
            }
            Toast.show(message: "All waypoint setting saved", controller: self)
        }
        
        SessionUtils.saveWaypoints(waypoints: waypointsList)
        
    }
    
    @IBAction func onPreviousWaypointClick(_ sender: Any) {
        if(selectedWayPoint != 0){
            selectedWayPoint = selectedWayPoint - 1
            self.setUpWaypointValues()
        }
    }
    
    @IBAction func onNextWayPointClick(_ sender: Any) {
        let length = waypointsList.count - 1
        if(selectedWayPoint != length){
            selectedWayPoint = selectedWayPoint + 1
            self.setUpWaypointValues()
        }
    }
    
    
    @IBAction func deleteWayPointClick(_ sender: Any){
        if(selectedWayPoint != -1){
            self.points[selectedWayPoint].map = nil
            self.points.remove(at: selectedWayPoint)
            self.waypointsList.remove(at: selectedWayPoint)
            
            for point in points{
                point.map = nil
            }
            self.points = []

            for (index, waypoint) in waypointsList.enumerated(){
                waypoint.name = "Waypoint - \(index+1)"
                var point = MovingObject(CLLocationCoordinate2D(latitude: waypoint.latittude!, longitude: waypoint.longitude!), 0.0, .draw_point)
                point.title = "Waypoint -  \(points.count+1)"
                point = self.drawModifiedMarker(annotation: point)
                points.append(point)
                point.map = googleMapView
            }
            
            connectPoints()
            
            let length = waypointsList.count - 1
            if(selectedWayPoint < length){
                selectedWayPoint = selectedWayPoint + 1
                self.setUpWaypointValues()
            }else{
                selectedWayPoint = selectedWayPoint - 1
                if(selectedWayPoint != -1){
                    self.setUpWaypointValues()
                }else{
                    self.waypointSettingView.isHidden = true
                }
            }
            
            SessionUtils.saveWaypoints(waypoints: waypointsList)
    
        }
        else{
            self.waypointSettingView.isHidden = true
        }
    }
    
    @IBAction func onCloseWaypointSetting(_ sender: Any) {
        self.waypointSettingView.isHidden = true
    }
    
    
    @IBAction func deleteAllClick(_ sender: Any) {
        if isFlightContinue == false{
            let alertController = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all way points.", preferredStyle: .alert)
            let action1 = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
                alertController.dismiss(animated: false)
            })
            let action2 = UIAlertAction(title: "Delete Waypoints", style: .default, handler: { (action) in
                self.deleteWaypoints()
            })
            let action3 = UIAlertAction(title: "Delete Waypoints & POI", style: .default, handler: { (action) in
                self.deleteWaypointsAndPOI()
            })
            alertController.addAction(action1)
            alertController.addAction(action2)
            alertController.addAction(action3)
            
            // Present the alert controller
            self.present(alertController, animated: true, completion: nil)
        }else{
            self.showAlertViewWithTitle(title: "Flight In Progress", withMessage: "You cannot perform this action during flight.")
        }
    }
    
    @IBAction func cameraHeightBtnClick(_ sender: Any) {
        if isFullCamera == true{
            isFullCamera = false
            UIView.animate(withDuration: 0.3) {
                self.cameraContainerWidthConstraint.constant = 190
                self.cameraContainerHeightConstraint.constant = 102
            }
            self.cameraBtn.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        }else{
            isFullCamera = true
            UIView.animate(withDuration: 0.3) {
                self.cameraContainerWidthConstraint.constant = 300
                self.cameraContainerHeightConstraint.constant = 180
            }
            self.cameraBtn.setImage(UIImage(systemName: "minus.circle"), for: .normal)
        }
        adapter?.stop()
        adapter = VideoPreviewerAdapter.init()
        adapter?.start()
    }
    
    
    @IBAction func startDrawing(_ sender: Any) {
        if isFlightContinue == false{
            isHomeDrawing = false
            homeDrawBtn.setImage(UIImage(named: "home"), for: .normal)
            
            if pointOfInterest == nil{
                isDrawing = false
                drawBtn.setImage(UIImage(named: "add"), for: .normal)
                self.showAlertViewWithTitle(title: "POI", withMessage: "Please draw point of interest before drawing waypoints")
            }else{
                if(isDrawing == true){
                    isDrawing = false
                    drawBtn.setImage(UIImage(named: "add"), for: .normal)
                }else{
                    isDrawing = true
                    drawBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
                }
            }
        }else{
            self.showAlertViewWithTitle(title: "Flight In Progress", withMessage: "You cannot perform this action during flight.")
        }
    }
    
    @IBAction func drawPointOfInterest(_ sender: Any) {
        if isFlightContinue == false{
            isDrawing = false
            drawBtn.setImage(UIImage(named: "add"), for: .normal)
            
            if(isHomeDrawing == true){
                isHomeDrawing = false
                homeDrawBtn.setImage(UIImage(named: "home"), for: .normal)
            }else{
                isHomeDrawing = true
                homeDrawBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
            }
        }else{
            self.showAlertViewWithTitle(title: "Flight In Progress", withMessage: "You cannot perform this action during flight.")
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let touchCoordinate = coordinate
        if(isDrawing == true && pointOfInterest != nil){
            // Add a point at the tapped location
            drawWaypoint(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude, project: selectProject!, height: mustHeight)
        }
        else if(isHomeDrawing == true){
            if(pointOfInterest == nil){
                pointOfInterest = GMSMarker()
                pointOfInterest = self.drawModifiedMarker(annotation: MovingObject(CLLocationCoordinate2D(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude), 0.0, .point_of_interest))
                pointOfInterest!.title = "Point of Interest"
                pointOfInterest!.map = googleMapView
                
                SessionUtils.savePointOfInterest(location: CLLocationCoordinate2D(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude))

            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        print("Tapped")
        if let tappedPolygon = overlay as? GMSPolygon{
            let title = tappedPolygon.title ?? ""
            if(title != "" && title.contains("No Fly Zone")){
                let titleData = title.components(separatedBy: ":-")
                let polygonID = Int(titleData[1])
                
                for info in allSurroundingPolygons {
                    if(info.flyZoneID == polygonID!){
                        let category = info.category
                        
                        let categoryData = Utils.getCategoryColors(category: category)
                        let fillColor: UIColor = categoryData["fillColor"] as! UIColor
                        let strokeColor: UIColor = categoryData["strokeColor"] as! UIColor
                        var categoryStr: String = categoryData["category"] as! String

                        self.flyZoneLevel.text = categoryStr
                        self.flyZoneName.text = info.name
                        self.flyZoneType.text = Utils.getFlyZoneReason(reason: info.reason)
                        self.flyZoneInfoView.isHidden = false
                        
                        self.flyZoneImage.image =  Utils.createCircleImage(size: CGSize(width: 40, height: 40), backgroundColor: fillColor, borderColor: strokeColor, borderWidth: 1.0)
                    }
                }
                
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let mar = marker as! MovingObject
        if(mar.type == .draw_point){
            let title = mar.title
            let data = title!.components(separatedBy: " - ")
            let wayp = data[1].replacingOccurrences(of: " ", with: "")
            selectedWayPoint = Int(wayp)!-1
            print(selectedWayPoint)
            self.waypointSettingView.isHidden = false
            isSeprateWaypointSetting = true
            self.setUpWaypointValues()
            
        }
        return true
    }
    
    
    @IBAction func playButtonAction(_ sender: Any) {
        if self.paused {
            print("Self.Pause")
            DJISDKManager.missionControl()?.resumeTimeline()
        } else if self.started {
            print("Self.Statertedause")
            DJISDKManager.missionControl()?.pauseTimeline()
        } else {
            print("Self.Start")
            DJISDKManager.missionControl()?.startTimeline()
        }
    }
    
    @IBAction func stopButtonAction(_ sender: Any) {
        print("Stop Button Click")
        DJISDKManager.missionControl()?.stopTimeline()
    }
    
    
    @IBAction func onSimulatorSwitchValueChanged(_ sender: UISwitch) {
        startSimulatorButtonAction()
    }
   
    func deleteWaypoints(){
        if(points.count == 0){
            self.showAlertViewWithTitle(title: "No Waypoints", withMessage: "No Waypoints deleted")
        }else{
            for point in points {
                point.map = nil
            }
            points = []
            waypointsList = []
            selectedWayPoint = 0
            reDrawAnnotations()
            for overl in allOverLays {
                overl.map = nil
            }
            allOverLays = []
            self.waypointSettingView.isHidden = true
        }
    }
    
    func deleteWaypointsAndPOI(){
        if(pointOfInterest != nil){
            pointOfInterest?.map = nil
            pointOfInterest = nil
            self.deleteWaypoints()
        }else{
            self.showAlertViewWithTitle(title: "No POI", withMessage: "No Point of Interest Found")
        }
    }
    
    func checkConnectivity() {
        guard let connectedKey = DJIProductKey(param: DJIParamConnection) else {
            NSLog("Error creating the connectedKey")
            isProductConnectd = false
            self.connectionLbl.text = "Disconnected"
            self.connectionLbl.textColor = .red
            hideElements()
            return;
        }
        
        print("Connecting Check")
        DJISDKManager.keyManager()?.startListeningForChanges(on: connectedKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
            if newValue != nil {
                if newValue!.boolValue {
                    // At this point, a product is connected so we can show it.
                    
                    // UI goes on MT.
                    DispatchQueue.main.async {
                        self.isProductConnectd = true
                        self.connectionLbl.text = "Connected"
                        self.connectionLbl.textColor = .green
                        self.showElements()
                        self.initView()
                    }
                }else{
                    self.isProductConnectd = false
                    self.connectionLbl.text = "Disconnected"
                    self.connectionLbl.textColor = .red
                    self.hideElements()
                }
            }
        })
        DJISDKManager.keyManager()?.getValueFor(connectedKey, withCompletion: { (value:DJIKeyedValue?, error:Error?) in
            if let unwrappedValue = value {
                if unwrappedValue.boolValue {
                    // UI goes on MT.
                    DispatchQueue.main.async {
                        self.isProductConnectd = true
                    }
                }else{
                    self.isProductConnectd = false
                    self.connectionLbl.text = "Disconnected"
                    self.connectionLbl.textColor = .red
                    self.hideElements()
                }
            }
        })
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.checkConnectivity()
        }
    }
    
    
    func drawWaypoint(latitude: Double, longitude: Double, project: Project, height: Int){
        
        let waypointSetting = WaypointSetting()
        waypointSetting.name = "Waypoint -  \(points.count+1)"
        
        var point = MovingObject(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), 0.0, .draw_point)
        
        point.title = "Waypoint -  \(points.count+1)"
        point = self.drawModifiedMarker(annotation: point)
        points.append(point)
        point.map = googleMapView
        
        waypointSetting.latittude = latitude
        waypointSetting.longitude = longitude
        
        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
        let pointOfInterestLocation = CLLocation(latitude: (pointOfInterest?.position.latitude)!, longitude: (pointOfInterest?.position.longitude)!)
        
        let angle = ImageUtils.getAngleBetweenPoints(point1: currentLocation, point2: pointOfInterestLocation)
        
        waypointSetting.heading = angle
        
        if(waypointsList.count == 0){
            waypointSetting.gimbalPitch = 0
        }
        else{
            let index = waypointsList.count - 1
            if(waypointsList[index].gimbalPitch == 0){
                waypointSetting.gimbalPitch = -90
            }else{
                waypointSetting.gimbalPitch = 0
            }
        }
        
        if(project.id != nil && project.id != 0 && height != 0){
            waypointSetting.altitude = Double(height)*0.3048
        }
        
        waypointsList.append(waypointSetting)
        
        SessionUtils.saveWaypoints(waypoints: waypointsList)
        
        connectPoints()
    }
    
    
    
    //Back Button Click
    @IBAction func backButtonClick(_ sender: Any) {
        if isFlightContinue == false{
            navigationController?.popViewController(animated: true)
        }else{
            self.showAlertViewWithTitle(title: "Flight In Progress", withMessage: "You cannot perform this action during flight.")
        }
    }
    
    //this method calls after drag and drop points and draw points
    func connectPoints() {
        let pointCount = points.count
        if pointCount < 2 { return }
        
        if let polyline = polyline{
            polyline.map = nil
        }
        let path = GMSMutablePath()
        for point in points {
            path.add(CLLocationCoordinate2D(latitude: point.position.latitude, longitude: point.position.longitude))
        }
        polyline = GMSPolyline(path: path)
        polyline?.strokeWidth = 1.5
        polyline?.strokeColor = .orange
        polyline?.map = googleMapView
    }
    
    //This will redraw Annotations
    func reDrawAnnotations(){
        for (index, point) in (points).enumerated(){
            point.title = "Waypoint -  \(index+1)"
            point.map = googleMapView
        }
    }
    
    
    func setUpCamera(){
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
            
    }
    
    func showElements(){
        self.cameraBtn.isHidden = false
    }
    
    func hideElements(){
        self.cameraBtn.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        Environment.telemetryService.stopListeners()
        Environment.locationService.stopListeners()
        
        // Call unSetView during exiting to release the memory.
        DJIVideoPreviewer.instance()?.unSetView()
        
        if adapter != nil {
            adapter?.stop()
            adapter = nil
        }
    }
    
    func showAlertViewWithTitle(title: String, withMessage message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title:"OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        DJIVideoPreviewer.instance()?.setView(cameraFPVView)
        
        Environment.telemetryService.registerListeners()
        Environment.locationService.registerListeners()
        registerTelemetryServices()
        
        DJIVideoPreviewer.instance()?.setView(cameraFPVView)
    
        if let camera = fetchCamera(){
            camera.delegate = self
            if camera.isFlatCameraModeSupported() == true {
                camera.setFlatMode(.photoSingle, withCompletion: {(error: Error?) in
                    if error != nil {
                        print("Error set camera flat mode photo/video \(String(describing: error?.localizedDescription))");
                    }
                })
                } else {
                    camera.setMode(.shootPhoto, withCompletion: {(error: Error?) in
                        if error != nil {
                            print("Error set mode photo/video \(String(describing: error?.localizedDescription))");
                        }
                    })
                }
         }
         if adapter == nil{
            DJIVideoPreviewer.instance()?.start()
            adapter = VideoPreviewerAdapter.init()
            adapter?.start()
        }
        
        DJISDKManager.missionControl()?.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
            
            if let error = error{
                print("Error - \(error)")
            }
            
            switch event {
                case .started:
                    self.didStart()
                case .stopped:
                    self.didStop()
                case .paused:
                    self.didPause()
                case .resumed:
                    self.didResume()
                default:
                    break
            }
        })
        
        self.aircraftAnnotation = self.drawModifiedMarker(annotation: aircraftAnnotation)
        self.aircraftAnnotation.map = googleMapView
        self.homeAnnotation = self.drawModifiedMarker(annotation: homeAnnotation)
        self.homeAnnotation.map = googleMapView
        
        if let aircarftLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)  {
            DJISDKManager.keyManager()?.startListeningForChanges(on: aircarftLocationKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if newValue != nil {
                    let newLocationValue = newValue!.value as! CLLocation
                    
                    if CLLocationCoordinate2DIsValid(newLocationValue.coordinate) {
                        self.aircraftAnnotation.position = newLocationValue.coordinate
                    }
                }
            }
        }
        
        
        if let aircraftHeadingKey = DJIFlightControllerKey(param: DJIFlightControllerParamCompassHeading) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: aircraftHeadingKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if (newValue != nil) {
                    self.aircraftAnnotation.heading = newValue!.doubleValue
                    self.aircraftAnnotation.rotation = CLLocationDegrees(exactly: newValue!.intValue)!
                    if (self.aircraftAnnotationView != nil) {
//                        self.aircraftAnnotationView.heading = CGAffineTransform(rotationAngle: CGFloat(self.degreesToRadians(Double(self.aircraftAnnotation.heading))))
                        self.aircraftAnnotationView.heading = self.degreesToRadians(Double(self.aircraftAnnotation.heading))
                    }
                }
            }
        }
        
        if let homeLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamHomeLocation) {
            DJISDKManager.keyManager()?.startListeningForChanges(on: homeLocationKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
                if (newValue != nil) {
                    let newLocationValue = newValue!.value as! CLLocation
                    
                    if CLLocationCoordinate2DIsValid(newLocationValue.coordinate) {
                        self.homeAnnotation.position = newLocationValue.coordinate
                    }
                }
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        DJIVideoPreviewer.instance()?.unSetView()

        if adapter != nil {
            adapter?.stop()
            adapter = nil
        }
        
        DJISDKManager.missionControl()?.removeListener(self)
        DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)

        UIApplication.shared.isIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func startSimulatorButtonAction() {
        weak var weakSelf = self
        
        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            DJIAlert.show(title: "", msg: "No Drone Location Detected" , fromVC: weakSelf! as UIViewController)
            return
        }
        
        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
            DJIAlert.show(title: "", msg: "No Drone Location Detected" , fromVC: weakSelf! as UIViewController)
            return
        }
        
        let droneLocation = droneLocationValue.value as! CLLocation
        
        let location = CLLocationCoordinate2DMake(droneLocation.coordinate.latitude, droneLocation.coordinate.longitude);
        if let aircraft = DJISDKManager.product() as? DJIAircraft {
            if _isSimulatorActive {
                aircraft.flightController?.simulator?.stop(completion: nil)
            } else {
                aircraft.flightController?.simulator?.start(withLocation: location,
                                                                      updateFrequency: 30,
                                                                      gpsSatellitesNumber: 12,
                                                                      withCompletion: { (error) in
                    if (error != nil) {
                        weakSelf?.simulatorSwitch.isOn = false
                        DJIAlert.show(title: "", msg: "start simulator failed:" + (error?.localizedDescription)!, fromVC: weakSelf! as UIViewController)
                        NSLog("Start Simulator Error: \(error.debugDescription)")
                    }else{
                        DJIAlert.show(title: "", msg: "start simulator Successful!" , fromVC: weakSelf! as UIViewController)
                                                                        }
                })
            }
        }
    }
    
    func didStart() {
        self.started = true
        DispatchQueue.main.async {
            self.stopButton.isEnabled = true
            self.playButton.setTitle("⏸", for: .normal)
        }
    }
    
    func didPause() {
        self.paused = true
        DispatchQueue.main.async {
            self.playButton.setTitle("▶️", for: .normal)
        }
    }
    
    func didResume() {
        self.paused = false
        DispatchQueue.main.async {
            self.playButton.setTitle("⏸", for: .normal)
        }
    }
    
    func didStop() {
        print("Did Stopped")
        self.started = false
        DispatchQueue.main.async {
            self.stopButton.isEnabled = false
            self.playButton.setTitle("▶️", for: .normal)
        }
    }
    
    //MARK: OutlineView Delegate & Datasource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.availableElementsView {
            return self.availableElements.count
        } else if collectionView == self.timelineView {
            return self.scheduledElements.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "elementCell", for: indexPath) as! TimelineElementCollectionViewCell
        
        if collectionView == self.availableElementsView {
            cell.label.text = self.availableElements[indexPath.row].rawValue
        } else if collectionView == self.timelineView {
            cell.label.text = self.scheduledElements[indexPath.row].rawValue
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.isEqual(self.availableElementsView) {
            let elementKind = self.availableElements[indexPath.row]
            
            guard let element = self.timelineElementForKind(kind: elementKind) else {
                return;
            }
            let error = DJISDKManager.missionControl()?.scheduleElement(element)
            
            if error != nil {
                NSLog("Error scheduling element \(String(describing: error))")
                return;
            }
            
            self.scheduledElements.append(elementKind)
            DispatchQueue.main.async {
                self.timelineView.reloadData()
            }
        } else if collectionView.isEqual(self.timelineView) {
            if self.started == false {
                DJISDKManager.missionControl()?.unscheduleElement(at: UInt(indexPath.row))
                self.scheduledElements.remove(at: indexPath.row)
                DispatchQueue.main.async {
                    self.timelineView.reloadData()
                }
            }
        }
    }
    
    // MARK : Timeline Element 
    
    func timelineElementForKind(kind: TimelineElementKind) -> DJIMissionControlTimelineElement? {
        switch kind {
            case .takeOff:
                return DJITakeOffAction()
            case .goTo:
                return DJIGoToAction(altitude: 30)
            case .goHome:
                return DJIGoHomeAction()
            case .gimbalAttitude:
                return self.defaultGimbalAttitudeAction()
            case .singleShootPhoto:
                return DJIShootPhotoAction(singleShootPhoto: ())
            case .continuousShootPhoto:
                return DJIShootPhotoAction(photoCount: 10, timeInterval: 3.0, waitUntilFinish: false)
            case .recordVideoDuration:
                return DJIRecordVideoAction(duration: 10)
            case .recordVideoStart:
                return DJIRecordVideoAction(startRecordVideo: ())
            case .recordVideoStop:
                return DJIRecordVideoAction(stopRecordVideo: ())
            case .waypointMission:
                return self.defaultWaypointMission()
            case .hotpointMission:
                return self.defaultHotPointAction()
            case .aircraftYaw:
                return DJIAircraftYawAction(relativeAngle: 36, andAngularVelocity: 30)
        }
    }
    
    
    func defaultGimbalAttitudeAction() -> DJIGimbalAttitudeAction? {
        let attitude = DJIGimbalAttitude(pitch: 30.0, roll: 0.0, yaw: 0.0)
        
        return DJIGimbalAttitudeAction(attitude: attitude)
    }
    
    func defaultWaypointMission() -> DJIWaypointMission? {
        let mission = DJIMutableWaypointMission()
        
        mission.maxFlightSpeed = 15
        mission.autoFlightSpeed = 8
        mission.finishedAction = .noAction
        mission.headingMode = .auto
        mission.flightPathMode = .normal
        mission.rotateGimbalPitch = true
        mission.exitMissionOnRCSignalLost = true
        mission.gotoFirstWaypointMode = .pointToPoint
        mission.repeatTimes = 1
        
        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            Toast.show(message: "Invalid Location Key", controller: self)
            return nil
        }
        
        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
            Toast.show(message: "Invalid Location", controller: self)
            return nil
        }
        
        let droneLocation = droneLocationValue.value as! CLLocation
        let droneCoordinates = droneLocation.coordinate
        
        if !CLLocationCoordinate2DIsValid(droneCoordinates) {
            return nil
        }

        mission.pointOfInterest = droneCoordinates
        let offset = 0.0000899322
        
        
        let loc1 = CLLocationCoordinate2DMake(droneCoordinates.latitude + offset, droneCoordinates.longitude)
        drawWaypoint(latitude: loc1.latitude, longitude: loc1.longitude, project: selectProject!, height: mustHeight)
        let waypoint1 = DJIWaypoint(coordinate: loc1)
        waypoint1.altitude = 25
        waypoint1.heading = 0
        waypoint1.actionRepeatTimes = 1
        waypoint1.actionTimeoutInSeconds = 60
        waypoint1.cornerRadiusInMeters = 5
        waypoint1.turnMode = .clockwise
        waypoint1.gimbalPitch = 0
        
        let loc2 = CLLocationCoordinate2DMake(droneCoordinates.latitude, droneCoordinates.longitude + offset)
        drawWaypoint(latitude: loc2.latitude, longitude: loc2.longitude, project: selectProject!, height: mustHeight)
        let waypoint2 = DJIWaypoint(coordinate: loc2)
        waypoint2.altitude = 26
        waypoint2.heading = 0
        waypoint2.actionRepeatTimes = 1
        waypoint2.actionTimeoutInSeconds = 60
        waypoint2.cornerRadiusInMeters = 5
        waypoint2.turnMode = .clockwise
        waypoint2.gimbalPitch = -90
        
        let loc3 = CLLocationCoordinate2DMake(droneCoordinates.latitude - offset, droneCoordinates.longitude)
        drawWaypoint(latitude: loc3.latitude, longitude: loc3.longitude, project: selectProject!, height: mustHeight)
        let waypoint3 = DJIWaypoint(coordinate: loc3)
        waypoint3.altitude = 27
        waypoint3.heading = 0
        waypoint3.actionRepeatTimes = 1
        waypoint3.actionTimeoutInSeconds = 60
        waypoint3.cornerRadiusInMeters = 5
        waypoint3.turnMode = .clockwise
        waypoint3.gimbalPitch = 0
        //waypoint3.waypointActions = DJIWaypointA
        
        
        let loc4 = CLLocationCoordinate2DMake(droneCoordinates.latitude, droneCoordinates.longitude - offset)
        drawWaypoint(latitude: loc4.latitude, longitude: loc4.longitude, project: selectProject!, height: mustHeight)
        let waypoint4 = DJIWaypoint(coordinate: loc4)
        waypoint4.altitude = 28
        waypoint4.heading = 0
        waypoint4.actionRepeatTimes = 1
        waypoint4.actionTimeoutInSeconds = 60
        waypoint4.cornerRadiusInMeters = 5
        waypoint4.turnMode = .clockwise
        waypoint4.gimbalPitch = -90
        
        let waypoint5 = DJIWaypoint(coordinate: loc1)
        drawWaypoint(latitude: loc1.latitude, longitude: loc1.longitude, project: selectProject!, height: mustHeight)
        waypoint5.altitude = 29
        waypoint5.heading = 0
        waypoint5.actionRepeatTimes = 1
        waypoint5.actionTimeoutInSeconds = 60
        waypoint5.cornerRadiusInMeters = 5
        waypoint5.turnMode = .clockwise
        waypoint5.gimbalPitch = 0
        
        mission.add(waypoint1)
        mission.add(waypoint2)
        mission.add(waypoint3)
        mission.add(waypoint4)
        mission.add(waypoint5)
        
        return DJIWaypointMission(mission: mission)
    }
    
    
    
    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
//        if(state.isFlying == true){
//            self.isFlying = true
//            self.takeOffLandBtn.setImage(UIImage(named: "buttonCommandGoHome"), for: .normal)
//        }else{
//            self.isFlying = false
//            self.takeOffLandBtn.setImage(UIImage(named: "buttonCommandStart"), for: .normal)
//
        
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
    
    func defaultHotPointAction() -> DJIHotpointAction? {
        let mission = DJIHotpointMission()
        
        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
            Toast.show(message: "Invalid Location Key", controller: self)
            return nil
        }
        
        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
            Toast.show(message: "Invalid Location", controller: self)
            return nil
        }
        
        let droneLocation = droneLocationValue.value as! CLLocation
        let droneCoordinates = droneLocation.coordinate
        
        if !CLLocationCoordinate2DIsValid(droneCoordinates) {
            return nil
        }

        let offset = 0.0000899322

        mission.hotpoint = CLLocationCoordinate2DMake(droneCoordinates.latitude + offset, droneCoordinates.longitude)
        mission.altitude = 15
        mission.radius = 15
        DJIHotpointMissionOperator.getMaxAngularVelocity(forRadius: Double(mission.radius), withCompletion: {(velocity:Float, error:Error?) in
            mission.angularVelocity = velocity
        })
        mission.startPoint = .nearest
        mission.heading = .alongCircleLookingForward
        
        return DJIHotpointAction(mission: mission, surroundingAngle: 180)
    }
    
    // MARK: - Convenience
    
    func degreesToRadians(_ degrees: Double) -> Double {
        return Double.pi / 180 * degrees
    }
    
    //Mission Listeners
    @IBAction func onMaxSpeedChangeListener(_ sender: Any) {
        self.maxFlightSpeedBar.value = Float(Int(self.maxFlightSpeedBar.value))
        self.maxFlightSpeedLbl.text = "\(self.maxFlightSpeedBar.value) m/s"
    }
    
    @IBAction func onMaxPlusClick(_ sender: Any) {
        self.maxFlightSpeedBar.value = self.maxFlightSpeedBar.value + 1
        self.maxFlightSpeedLbl.text = "\(self.maxFlightSpeedBar.value) m/s"
    }
    
    @IBAction func onMaxMinusClick(_ sender: Any) {
        self.maxFlightSpeedBar.value = self.maxFlightSpeedBar.value - 1
        self.maxFlightSpeedLbl.text = "\(self.maxFlightSpeedBar.value) m/s"
    }
    
    @IBAction func autoSpeedPlusClick(_ sender: Any) {
        self.autoSpeedBar.value = self.autoSpeedBar.value + 1
        self.autoSpeedLbl.text = "\(self.autoSpeedBar.value) m/s"
    }
    
    @IBAction func autoSpeedMinusClick(_ sender: Any) {
        self.autoSpeedBar.value = self.autoSpeedBar.value - 1
        self.autoSpeedLbl.text = "\(self.autoSpeedBar.value) m/s"
    }
    
    @IBAction func autoSpeedChangeListener(_ sender: Any) {
        self.autoSpeedBar.value = Float(Int(self.autoSpeedBar.value))
        self.autoSpeedLbl.text = "\(self.autoSpeedBar.value) m/s"
    }
    
    @IBAction func rotateGimbleListener(_ sender: Any) {
    }
    
    @IBAction func connectionLoseListener(_ sender: Any) {
    }
    
    @IBAction func gotToListener(_ sender: Any) {
    }
    
    @IBAction func pathModeListener(_ sender: Any) {
    }
    
    @IBAction func repeatTimeMinusClick(_ sender: Any) {
        DJISDKManager.product()
        self.repeatTimesBar.value = self.repeatTimesBar.value - 1
        self.repeatTimesLbl.text = "\(self.repeatTimesBar.value)"
    }
    
    @IBAction func repeatTimePlusClick(_ sender: Any) {
        self.repeatTimesBar.value = self.repeatTimesBar.value + 1
        self.repeatTimesLbl.text = "\(self.repeatTimesBar.value)"
    }
    
    @IBAction func repeatTimeBarListener(_ sender: Any) {
        self.repeatTimesBar.value = Float(Int(self.repeatTimesBar.value))
        self.repeatTimesLbl.text = "\(self.repeatTimesBar.value)"
    }
    
    //Waypoint Value Change Listeners
    
    @IBAction func onAltitudeChange(_ sender: Any) {
        self.altitudeBar.value = Float(Int(self.altitudeBar.value))
        self.altitudeLbl.text = "\(self.altitudeBar.value)m"
    }
    
    @IBAction func onAltitudePlusClick(_ sender: Any) {
        self.altitudeBar.value = Float(Int(self.altitudeBar.value + 1))
        self.altitudeLbl.text = "\(self.altitudeBar.value)"
    }
    
    @IBAction func onAltitudeMinus(_ sender: Any) {
        self.altitudeBar.value = Float(Int(self.altitudeBar.value - 1))
        self.altitudeLbl.text = "\(self.altitudeBar.value)"
    }
    
    
    @IBAction func onHeadingChange(_ sender: Any) {
        self.headingBar.value = Float(Int(self.headingBar.value))
        self.headingLbl.text = "\(self.headingBar.value)°"
    }
    
    @IBAction func onHeadingPlusClick(_ sender: Any) {
        self.headingBar.value = Float(Int(self.headingBar.value + 1))
        self.headingLbl.text = "\(self.headingBar.value)"
    }
    
    @IBAction func onHeadingMinusClick(_ sender: Any) {
        self.headingBar.value = Float(Int(self.headingBar.value - 1))
        self.headingLbl.text = "\(self.headingBar.value)"
    }
    
    @IBAction func onWaypointRepeatChange(_ sender: Any) {
        self.wayPointRepeatTimeBar.value = Float(Int(self.wayPointRepeatTimeBar.value))
        self.wayPointRepeatTimeLbl.text = "\(self.wayPointRepeatTimeBar.value)"
    }
    
    @IBAction func onWaypointPlusClick(_ sender: Any) {
        self.wayPointRepeatTimeBar.value = Float(Int(self.wayPointRepeatTimeBar.value + 1))
        self.wayPointRepeatTimeLbl.text = "\(self.wayPointRepeatTimeBar.value)"
    }
    
    @IBAction func onWaypointRepeatMinusClick(_ sender: Any) {
        self.wayPointRepeatTimeBar.value = Float(Int(self.wayPointRepeatTimeBar.value - 1))
        self.wayPointRepeatTimeLbl.text = "\(self.wayPointRepeatTimeBar.value)"
    }
    
    @IBAction func onActiontimeoutChange(_ sender: Any) {
        self.actionTimeoutBar.value = Float(Int(self.actionTimeoutBar.value))
        self.actionTimoutLbl.text = "\(self.actionTimeoutBar.value)s"
    }
    
    @IBAction func onTimeoutActionPlusClick(_ sender: Any) {
        self.actionTimeoutBar.value = Float(Int(self.actionTimeoutBar.value + 100))
        self.actionTimoutLbl.text = "\(self.actionTimeoutBar.value)"
    }
    
    @IBAction func onTimeoutMinusClick(_ sender: Any) {
        self.actionTimeoutBar.value = Float(Int(self.actionTimeoutBar.value - 100))
        self.actionTimoutLbl.text = "\(self.actionTimeoutBar.value)"
    }
    
    @IBAction func onCornerRadiusChange(_ sender: Any) {
        self.cornerRadiusBar.value = Float(self.cornerRadiusBar.value)
        self.cornerRadiusLbl.text = "\(self.cornerRadiusBar.value)m"
    }
    
    @IBAction func onCornerRadiusPlusClick(_ sender: Any) {
        self.cornerRadiusBar.value = Float(Int(self.cornerRadiusBar.value + 1))
        self.cornerRadiusLbl.text = "\(self.cornerRadiusBar.value)"
    }
    
    @IBAction func onCornerRadiusMinusClick(_ sender: Any) {
        self.cornerRadiusBar.value = Float(Int(self.cornerRadiusBar.value - 1))
        self.cornerRadiusLbl.text = "\(self.cornerRadiusBar.value)"
    }
    
    @IBAction func gimbalPitchOnChange(_ sender: Any) {
        self.gimbalPitchBar.value = Float(Int(self.gimbalPitchBar.value))
        self.gimbalPicthLbl.text = "\(self.gimbalPitchBar.value)°"
    }
    
    
    @IBAction func poiHeightValueChange(_ sender: Any) {
        self.poiBar.value = Float(Int(self.poiBar.value))
        self.poiHeightLbl.text = "\(self.poiBar.value)m"
    }
    
    @IBAction func onGimbalPitchPlusClick(_ sender: Any) {
        self.gimbalPitchBar.value = Float(Int(self.gimbalPitchBar.value + 1))
        self.gimbalPicthLbl.text = "\(self.gimbalPitchBar.value)"
    }
    
    
    @IBAction func onGimbalPitchMinusClick(_ sender: Any) {
        self.gimbalPitchBar.value = Float(Int(self.gimbalPitchBar.value - 1))
        self.gimbalPicthLbl.text = "\(self.gimbalPitchBar.value)"
    }
    
    @IBAction func onPOIPlusClick(_ sender: Any) {
        self.poiBar.value = Float(Int(self.poiBar.value + 1))
        self.poiHeightLbl.text = "\(self.poiBar.value)m"
    }
    
    
    @IBAction func onPOIMinusClick(_ sender: Any) {
        self.poiBar.value = Float(Int(self.poiBar.value - 1))
        self.poiHeightLbl.text = "\(self.poiBar.value)m"
    }
    
    func commandStartBtnClick() {
        Environment.commandService.executeMissionCommand(.start)
    }
    
    @IBAction func commandPauseBtnClick(_ sender: Any) {
        Environment.commandService.executeMissionCommand(.pause)
    }
    
    @IBAction func commandResumeBtnClick(_ sender: Any) {
        Environment.commandService.executeMissionCommand(.resume)
    }
    
    @IBAction func commandGoHomeBtn(_ sender: Any) {
        Environment.commandService.executeMissionCommand(.goHome)
    }
    
    @IBAction func commandStopBtnClick(_ sender: Any) {

        Environment.commandService.executeMissionCommand(.goHome)
        self.showAlertViewWithTitle(title: "Mission Abort", withMessage: "Mission stopped and aircraft going to home location.")
        
    }
    
    @IBAction func onProjectDetailSelect(_ sender: Any) {
        self.projectDetailView.isHidden = true
        self.projectsListView.isHidden = true
        selectProject(project: selectedProject!)
    }
    
    @IBAction func onProjectDetailViewClose(_ sender: Any) {
        self.projectsListView.isHidden = false
        getAllProjects()
        self.projectDetailView.isHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func projectDetailChange(){
        let heightOfHouseIntFeet: Int = Int(self.heightOFHouseSlider.value)
        print(heightOfHouseIntFeet)
        let heightOfHouseIntMeter: Double = Double(heightOfHouseIntFeet)*0.3048
        self.heightOfHouseLbl.text = "\(String(format:"%.2f", heightOfHouseIntMeter)) m/\(heightOfHouseIntFeet) feet"
        self.heightOFHouseSlider.value = Float(heightOfHouseIntFeet)
        self.selectedProject?.height_of_house = heightOfHouseIntFeet
        
        let obstacleIntFeet: Int = Int(self.obstacleSlider.value)
        let obstacleIntMeter: Double = Double(obstacleIntFeet)*0.3048
        self.maxObstacleLbl.text = "\(String(format:"%.2f", obstacleIntMeter)) m/\(obstacleIntFeet) feet"
        self.obstacleSlider.value = Float(obstacleIntFeet)
        self.selectedProject?.must_height = obstacleIntFeet
        
        let outerCircleFeetHeight = obstacleIntFeet + 10
        let outerCircleMeterHeight = Double(outerCircleFeetHeight)*0.3048
        
        let innerCircleFeetHeight = heightOfHouseIntFeet + 10
        let innerCircleMeterHeight = Double(innerCircleFeetHeight)*0.3048
        
        let obstacleFeetHeight = obstacleIntFeet + 5
        let obstacleMeterHeight = Double(obstacleFeetHeight)*0.3048
        
        self.outerCircleLbl.text = "\(String(format:"%.2f", outerCircleMeterHeight)) m/\(outerCircleFeetHeight) feet"
        self.innerCircleLbl.text = "\(String(format:"%.2f", innerCircleMeterHeight)) m/\(innerCircleFeetHeight) feet"
        self.obstableWaypointLbl.text = "\(String(format:"%.2f", obstacleMeterHeight)) m/\(obstacleFeetHeight) feet"
    }
    
    @IBAction func heightOfHousePlusClick(_ sender: Any) {
        self.heightOFHouseSlider.value = self.heightOFHouseSlider.value + 1
        self.projectDetailChange()
    }
    
    @IBAction func heightOfHouseNegativeClick(_ sender: Any) {
        self.heightOFHouseSlider.value = self.heightOFHouseSlider.value - 1
        self.projectDetailChange()
    }
    
    @IBAction func heightOfHouseSliderChange(_ sender: Any) {
        self.heightOFHouseSlider.value = self.heightOFHouseSlider.value
        self.projectDetailChange()
    }
    
    @IBAction func obstaclePlusClick(_ sender: Any) {
        self.obstacleSlider.value = self.obstacleSlider.value + 1
        self.projectDetailChange()
    }
    
    @IBAction func obstacleNegativeClick(_ sender: Any) {
        self.obstacleSlider.value = self.obstacleSlider.value - 1
        self.projectDetailChange()
    }
    
    @IBAction func obstacleSliderChange(_ sender: Any) {
        self.obstacleSlider.value = self.obstacleSlider.value
        self.projectDetailChange()
    }
    
}

// Private methods
extension TimelineMissionViewController {
    private func registerListeners() {
        Environment.locationService.aircraftLocationListeners.append({ location in
            self.showObject(self.aircraftAnnotation, location)
        })
        Environment.locationService.aircraftHeadingChanged = { heading in
            if (heading != nil) {
                self.aircraftAnnotation.heading = heading!
            }
        }
        Environment.locationService.homeLocationListeners.append({ location in
            self.showObject(self.homeAnnotation, location)
        })
    
    }

//    private func enableMissionPolygonInteration(_ enable: Bool) {
//        if enable {
//            mapView.addGestureRecognizer(tapRecognizer)
//            mapView.addGestureRecognizer(panRecognizer)
//        } else {
//            mapView.removeGestureRecognizer(tapRecognizer)
//            mapView.removeGestureRecognizer(panRecognizer)
//        }
//    }
//
//    private func enableMapInteraction(_ enable: Bool) {
//        mapView.isScrollEnabled = enable
//        mapView.isZoomEnabled = enable
//        mapView.isUserInteractionEnabled = enable
//    }

    private func objectPresentOnMap(_ object: MovingObject) -> Bool {
        
        var check: Bool = false
        if(object.map == nil){
            check = false
        }else{
            check = true
        }
        return check
//
//        return google.annotations.contains(where: { annotation in
//            return annotation as? MovingObject == object
//        })
    }

    private func showObject(_ object: MovingObject, _ location: CLLocation?) {
        if location != nil {
            object.position = location!.coordinate
            if !objectPresentOnMap(object) {
                object.map = googleMapView
            }
        } else if objectPresentOnMap(object) {
            object.map = nil
        }
    }

    private func trackObject(_ object: MovingObject, _ enable: Bool) -> Bool {
        if objectPresentOnMap(object) {
            object.isTracked = enable
            if enable {
                focusOnCoordinate(object.position)
                object.coordinateChanged = { coordinate in
                    self.focusOnCoordinate(coordinate)
                }
            } else {
                object.coordinateChanged = nil
            }
            return true
        } else {
            return false
        }
    }

    private func focusOnCoordinate(_ coordinate: CLLocationCoordinate2D) {
//        let distanceSpan: CLLocationDistance = 5
//        let mapCoordinates = MKCoordinateRegion(center: coordinate, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
//        mapView.setRegion(mapCoordinates, animated: true)
//
        let newCamera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 19.0)
        let update = GMSCameraUpdate.setCamera(newCamera)
        googleMapView.animate(with: update)
    }


//    private func movingObjectView(for movingObject: MovingObject, on mapView: GMSMapView) -> MovingObjectView? {
//        let movingObjectView = googleMapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(MovingObject.self), for: movingObject) as? MovingObjectView
//        if movingObjectView != nil {
//            switch movingObject.type {
//                case .user:
//                    movingObject.headingChanged = { heading in
//                        movingObjectView!.onHeadingChanged(heading)
//                    }
//                    let image = #imageLiteral(resourceName: "placemarkUser")
//                    movingObjectView!.image = image //.color(Colors.user)
//                case .aircraft:
//                    movingObject.headingChanged = { heading in
//                        movingObjectView!.onHeadingChanged(heading)
//                    }
//                    let image = #imageLiteral(resourceName: "placemarkAircraft")
//                    movingObjectView!.image = image //.color(Colors.aircraft)
//                case .draw_point:
//                    let image = #imageLiteral(resourceName: "point")
//                    movingObjectView!.image = image //.color(Colors.aircraft)
//                case .point_of_interest:
//                    let image = #imageLiteral(resourceName: "placemarkUser")
//                    movingObjectView!.image = image //.color(Colors.aircraft)
//                case .home:
//                    movingObjectView!.image = #imageLiteral(resourceName: "placamarkHome")
//            }
//        }
//        return movingObjectView
//    }
    
    func drawModifiedMarker (annotation: MovingObject) -> MovingObject {
        var image: UIImage!

        var imageAnnotation: MovingObject? = nil
        imageAnnotation = annotation
        if annotation.isEqual(self.aircraftAnnotation) {
            image = #imageLiteral(resourceName: "placemarkAircraft")
        } else if annotation.isEqual(self.homeAnnotation) {
            image = #imageLiteral(resourceName: "buttonLocatorHome")
        }else if annotation.isEqual(self.userAnnotation){
            image = #imageLiteral(resourceName: "placemarkUser")
        }
        else if(annotation.type == .draw_point){
            let title = annotation.title
            let data = title!.components(separatedBy: " - ")
            let waypoint = data[1]
            

            let currentLocation = CLLocation(latitude: annotation.position.latitude, longitude: annotation.position.longitude)
            let pointOfInterestLocation = CLLocation(latitude: (pointOfInterest?.position.latitude)!, longitude: (pointOfInterest?.position.longitude)!)

            let angle = ImageUtils.getBearingBetweenTwoPoints(point1: currentLocation, point2: pointOfInterestLocation)
            let backgroundImage = UIImage(named: "paper_plane")?.rotateImage(radians: Float(angle))
            let forGroundImage = ImageUtils.drawWayPointImage(waypoint: waypoint)
            //image = ImageUtils.drawWayPointWithPointOfInterest(backgroundImage: backgroundImage!, foregroundImage: forGroundImage)
            image = forGroundImage
            
        }
        else if (annotation.type == .point_of_interest){
            image = #imageLiteral(resourceName: "home_location")
        }
        else{
            image = #imageLiteral(resourceName: "point")
        }


        imageAnnotation?.icon = image

        if annotation.isEqual(self.aircraftAnnotation) {
            if imageAnnotation != nil {
                self.aircraftAnnotationView = imageAnnotation!
            }
        }

        return imageAnnotation!
    }
    
}

// Public methods
extension TimelineMissionViewController {
    func trackUser(_ enable: Bool) -> Bool {
        let _ = trackObject(aircraftAnnotation, false)
        return trackObject(userAnnotation, enable)
    }

    func trackAircraft(_ enable: Bool) -> Bool {
        let _ = trackObject(userAnnotation, false)
        return trackObject(aircraftAnnotation, enable)
    }

    func locateHome() {
        if objectPresentOnMap(homeAnnotation) {
            focusOnCoordinate(homeAnnotation.position)
        }
    }
}

// Display annotations and renderers
extension TimelineMissionViewController : GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        for point in points{
            point.map = nil
        }
        reDrawAnnotations()
        connectPoints()
    }

    
}

// Handle custom gestures
extension TimelineMissionViewController : UIGestureRecognizerDelegate {
    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// Handle user location and heading updates
extension TimelineMissionViewController : CLLocationManagerDelegate {
    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newCoordinate = locations[0].coordinate
        if (objectPresentOnMap(userAnnotation)) {
            userAnnotation.position = newCoordinate
        } else {
            userAnnotation = MovingObject(newCoordinate, 200.0, .user)
            userAnnotation = self.drawModifiedMarker(annotation: userAnnotation)
            userAnnotation.map = googleMapView
            focusOnCoordinate(userAnnotation.position)
        }
    
    }

    internal func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if (objectPresentOnMap(userAnnotation)) {
            let h  = Double(round(1 * newHeading.trueHeading) / 1)
            userAnnotation.rotation = CLLocationDegrees(exactly: h)!
        }
    }
}

extension TimelineMissionViewController {
    fileprivate func fetchCamera() -> DJICamera? {
        guard let product = DJISDKManager.product() else {
            return nil
        }
        
        if product is DJIAircraft || product is DJIHandheld {
            return product.camera
        }
        return nil
    }
}

//Extension for Telemetry View
extension TimelineMissionViewController{
    
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
        
        Environment.telemetryService.horizontalVelocityChanged = { horizontalVelocity in
            let value = horizontalVelocity != nil ? String(format: "%.1f", horizontalVelocity!) : nil
            self.hsSpeedLabel.text = "\(value ?? "0.0") m/s"
        }
        Environment.telemetryService.verticalVelocityChanged = { verticalVelocity in
            let value = verticalVelocity != nil ? String(format: "%.1f", Utils.trimToZeroAndInvert(verticalVelocity!)) : nil
            self.vsSpeedLabel.text = "\(value ?? "0.0") m/s"
        }
        Environment.telemetryService.altitudeChanged = { altitude in
            var value = altitude != nil ? Double(altitude!) : 0.0
            value = Double(value*3.28084).rounded(toPlaces: 1)
            self.altitudeLabel.text = "\(value) f"
        }
        
        Environment.locationService.aircraftLocationListeners.append({ location in
            if location != nil && self.lastHomeLocation != nil {
                var value = location!.distance(from: self.lastHomeLocation!)
                value = Double(value*3.28084).rounded(toPlaces: 1)
                self.distanceLabel.text = "\(String(format: "%.0f", value)) f"
            } else {
                self.distanceLabel.text = "N/A"
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
        let defaultIndicator = UIImage(#imageLiteral(resourceName: "indicatorSignal0"))
        if let signalStrength = signalStrength {
            if signalStrength > 0 && signalStrength <= 25 {
                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal1")
            } else if signalStrength > 25 && signalStrength <= 50 {
                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal2")
            } else if signalStrength > 50 && signalStrength <= 75 {
                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal3")
            } else if signalStrength > 75 && signalStrength <= 100 {
                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal5")
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


//Mission Setting Extension
extension TimelineMissionViewController{
    
    func setUpMissionViewValues(){
        
        let mark = GMSMarker()
        
        self.maxFlightSpeedBar.minimumValue = 2
        self.maxFlightSpeedBar.maximumValue = 15
        
        self.poiBar.minimumValue = 1
        self.poiBar.maximumValue = 20
        
        self.autoSpeedBar.minimumValue = 2
        self.autoSpeedBar.maximumValue = 15
        
        self.repeatTimesBar.minimumValue = 1
        self.repeatTimesBar.maximumValue = 5
        
        self.finishActionDropDown.optionArray = finishActionsTxts
        self.headingModeDropdown.optionArray = headModesTxts
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissHeadingKeyboard))
            tap.cancelsTouchesInView = false
        self.headingModeDropdown.addGestureRecognizer(tap)
        
        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissActionsKeyboard))
            tap1.cancelsTouchesInView = false
        self.finishActionDropDown.addGestureRecognizer(tap1)
        
    }

    @objc func dismissHeadingKeyboard() {
        view.endEditing(true)
        self.headingModeDropdown.showList()
    }
    
    @objc func dismissActionsKeyboard() {
        view.endEditing(true)
        self.finishActionDropDown.showList()
    }
    
    func setUpMissionValues(){
        self.maxFlightSpeedBar.value = Float(missionSetting.maxFlightSpeed)
        self.maxFlightSpeedLbl.text = "\(Float(missionSetting.maxFlightSpeed)) m/s"
        
        self.poiBar.value = Float(missionSetting.poiHeight)
        self.poiHeightLbl.text = "\(Float(missionSetting.poiHeight)) m"
        
        self.autoSpeedBar.value = Float(missionSetting.autoFlightSpeed)
        self.autoSpeedLbl.text = "\(Float(missionSetting.autoFlightSpeed)) m/s"
        
        self.repeatTimesBar.value = Float(missionSetting.repeatTimes)
        self.repeatTimesLbl.text = "\(Float(missionSetting.repeatTimes))"
        
        if(missionSetting.rotateGimblePitch){
            self.rotateGimbalBar.selectedSegmentIndex = 1
        }else{
            self.rotateGimbalBar.selectedSegmentIndex = 0
        }
        
        if(missionSetting.exitMissionOnRCSignalLost){
            self.connectionLoseBar.selectedSegmentIndex = 1
        }else{
            self.connectionLoseBar.selectedSegmentIndex = 0
        }
        
        if(missionSetting.flightPathMode == .normal){
            self.waypointPathBar.selectedSegmentIndex = 0
        }else{
            self.waypointPathBar.selectedSegmentIndex = 1
        }
        
        if(missionSetting.gotoFirstWaypointMode == .safely){
            self.goToBar.selectedSegmentIndex = 0
        }else{
            self.goToBar.selectedSegmentIndex = 1
        }
        
        let headingModeIndex = self.headingMode.firstIndex(of: missionSetting.headingMode)
        let finishActionIndex = self.finishActions.firstIndex(of: missionSetting.finishAction)
        self.headingModeDropdown.selectedIndex = headingModeIndex
        self.finishActionDropDown.selectedIndex = finishActionIndex
        self.headingModeDropdown.text = self.headModesTxts[headingModeIndex!]
        self.finishActionDropDown.text = self.finishActionsTxts[finishActionIndex!]
        
    }
    
    
    func setUpWaypointSettingViewValues(){
        
        self.headingBar.minimumValue = -180
        self.headingBar.maximumValue = 180
        
        self.gimbalPitchBar.minimumValue = -90
        self.gimbalPitchBar.maximumValue = 30
        
        self.cornerRadiusBar.minimumValue = 0.2
        self.cornerRadiusBar.maximumValue = 1000
        
        self.actionTimeoutBar.minimumValue = 0
        self.actionTimeoutBar.maximumValue = 999
        
        self.wayPointRepeatTimeBar.minimumValue = 0
        self.wayPointRepeatTimeBar.maximumValue = Float(DJIMaxActionRepeatTimes)
        
        self.altitudeBar.minimumValue = 2
        self.altitudeBar.maximumValue = 100
    }
    
    func setUpWaypointValues(){
        
        var setting = waypointsList[selectedWayPoint]
        
        if(isSeprateWaypointSetting == false){
            if(allWaypointSetting == nil){
                allWaypointSetting = WaypointSetting()
            }
            setting = allWaypointSetting!
            self.wayPointLabl.text = "All Waypoints"
        }else{
            self.wayPointLabl.text = setting.name
            let newCamera = GMSCameraPosition.camera(withLatitude: setting.latittude!, longitude: setting.longitude!, zoom: 22.0)
            let update = GMSCameraUpdate.setCamera(newCamera)
            googleMapView.moveCamera(update)
        }
        
        self.headingBar.value = Float(setting.heading)
        self.gimbalPitchBar.value = Float(setting.gimbalPitch)
        self.cornerRadiusBar.value = Float(setting.cornerRadiusInMeters)
        self.actionTimeoutBar.value = Float(setting.actionTimeoutInSeconds)
        self.wayPointRepeatTimeBar.value = Float(setting.actionRepeatTimes)
        self.altitudeBar.value = Float(setting.altitude)
        
        self.headingLbl.text = "\(self.headingBar.value)°"
        self.gimbalPicthLbl.text = "\(self.gimbalPitchBar.value)°"
        self.cornerRadiusLbl.text = "\(self.cornerRadiusBar.value)m"
        self.actionTimoutLbl.text = "\(self.actionTimeoutBar.value)s"
        self.wayPointRepeatTimeLbl.text = "\(self.wayPointRepeatTimeBar.value)"
        self.altitudeLbl.text = "\(self.altitudeBar.value) m"
        
        if setting.turnMode == DJIWaypointTurnMode.clockwise.rawValue{
            self.turnModeBar.selectedSegmentIndex = 0
        }
        else{
            self.turnModeBar.selectedSegmentIndex = 1
        }
    }
    
    func selectProjectByIndex(index: Int){
        
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let nextViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
//        self.navigationController?.pushViewController(nextViewController, animated: false)
        
        let project = allProjects[index]
        selectedProject = project
        
        if(project.highest_can != nil && project.obstacle_boundary != nil && project.obstacle_boundary != "" && project.obstacle_boundary != "[]" && project.flight_path != nil && project.flight_path != "" && project.flight_path != "[]"){
            
            self.projectsListView.isHidden = true
            
            self.obstacleSlider.minimumValue = 10
            self.obstacleSlider.maximumValue = Float(project.highest_can!)
            self.obstacleSlider.value = Float(project.must_height!)
            
            self.heightOFHouseSlider.minimumValue = 10
            self.heightOFHouseSlider.maximumValue = Float(100)
            self.heightOFHouseSlider.value = Float(project.height_of_house!)
            
            self.projectDetailView.isHidden = false
           
            self.projectDetailChange()
            
            self.projectLbl.text = project.name!
            self.addressLbl.text = project.address!
            
            
            let alert = UIAlertController(title: "Verify Setting", message: "Do you want to verify aircraft settings before planning the mission", preferredStyle: .alert)
        
            alert.addAction(UIAlertAction(title: "No", style: .default) { [self] _ in
                alert.dismiss(animated: false)
            })
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default) { [self] _ in
                alert.dismiss(animated: false)
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let nextViewController = storyboard.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
                self.navigationController?.pushViewController(nextViewController, animated: false)
            })
            self.present(alert, animated: true, completion: nil)
            
        }else{
            Toast.show(message: "Project Information is not completed", controller: self)
        }

        
    }
    
    func selectProject(project: Project){
        
        let latitu = Double(project.lat!)
        let longitu = Double(project.lng!)
        //Hidding View and Deleting the Existing Waypoints and POIƒ
        self.projectsListView.isHidden = true
        if(pointOfInterest != nil){
            self.deleteWaypointsAndPOI()
        }
        
        //Draw New Waypoints
        pointOfInterest = GMSMarker()
        pointOfInterest = self.drawModifiedMarker(annotation: MovingObject(CLLocationCoordinate2D(latitude: latitu!, longitude: longitu!), 0.0, .point_of_interest))
        pointOfInterest!.title = "Point of Interest"
        pointOfInterest!.map = googleMapView
        
        SessionUtils.savePointOfInterest(location: CLLocationCoordinate2D(latitude: latitu!, longitude: longitu!))
        
        let newCamera = GMSCameraPosition.camera(withLatitude: latitu!, longitude: longitu!, zoom: 18.5)
        let update = GMSCameraUpdate.setCamera(newCamera)
        googleMapView.animate(with: update)
        
        //Drawing Waypoints
        self.selectedWayPoint = 0
        do{
            //This will encode the flight waypoints to array.
            let jsonData = project.flight_path!.data(using: .utf8)!
            let decoder = JSONDecoder()
            let waypointsList = try! decoder.decode([WaypointAddress].self, from: jsonData)
            
            //This will encode the flight setting
            let jsonData1 = project.flight_setting!.data(using: .utf8)!
            let decoder1 = JSONDecoder()
            let projectSetting = try! decoder1.decode(ProjectSetting.self, from: jsonData1)
            
            let jsonData2 = project.obstacle_boundary!.data(using: .utf8)!
            let decoder2 = JSONDecoder()
            let obstacleBoundry = try! decoder2.decode([[Obstacle]].self, from: jsonData2)
            
            let isInsideWaypoint = false
            var isAltitudeChanged = "Flying"
            
            for i in (0..<waypointsList.count){
                var height = 0
                let count = i+1
                var changedAltitude: Int = 0
                
                if(count <= projectSetting.circleOnePoints!){
                    height = project.must_height! + 10
                }else{
                    height = project.height_of_house! + 10
                }
                
                changedAltitude = project.must_height! + 5
                
                if i < waypointsList.count - 1 {
                    let nextWaypoint = waypointsList[i + 1]
                    
                    let isNextWaypointInObstacle = Utils.checkWaypointInObstacle(latitude: nextWaypoint.lat!, longitude: nextWaypoint.lng!, obstacle_boundary: obstacleBoundry)

                    switch isAltitudeChanged {
                        case "Flying":
                            if isNextWaypointInObstacle && count >= projectSetting.circleOnePoints! {
                                isAltitudeChanged = "Going Inside"
                            }
                        case "Going Inside", "Inside":
                            if isNextWaypointInObstacle {
                                isAltitudeChanged = "Inside"
                            } else {
                                isAltitudeChanged = "Outside"
                            }
                        default:
                            isAltitudeChanged = "Flying"
                    }
                } else {
                    isAltitudeChanged = "Flying"
                }
                
                if(Utils.checkWaypointInObstacle(latitude: waypointsList[i].lat!, longitude: waypointsList[i].lng!, obstacle_boundary: obstacleBoundry)){
                    if(count <= projectSetting.circleOnePoints!){
                        height = project.must_height! + 10
                    }else{
                        height = project.must_height! + 5
                    }
                }
                
                drawWaypoint(latitude: waypointsList[i].lat!, longitude: waypointsList[i].lng!, project: project, height: height)
                
                
                if(isAltitudeChanged == "Going Inside" && count >= projectSetting.circleOnePoints!){
                    drawWaypoint(latitude: waypointsList[i].lat!, longitude: waypointsList[i].lng!, project: project, height: changedAltitude)
                }else if(isAltitudeChanged == "Outside" && i < waypointsList.count - 1 && count >= projectSetting.circleOnePoints!){
                    drawWaypoint(latitude: waypointsList[i+1].lat!, longitude: waypointsList[i+1].lng!, project: project, height: changedAltitude)
                    isAltitudeChanged = "Flying"
                }else{
                    if count == projectSetting.circleOnePoints!{
                        drawWaypoint(latitude: waypointsList[i+1].lat!, longitude: waypointsList[i+1].lng!, project: project, height: height)
                    }
                }
            }
        }catch let error as Error{
            print("Error - \(error.localizedDescription)")
        }
        
        removeAllObstacles()
        if(project.obstacle_boundary != nil && project.obstacle_boundary != ""){
            SessionUtils.saveObstacles(obstacle: project.obstacle_boundary!)
            let jsonData2 = project.obstacle_boundary!.data(using: .utf8)!
            let decoder2 = JSONDecoder()
            let obstacleBoundary = try! decoder2.decode([[WaypointAddress]].self, from: jsonData2)
            
            for i in (0..<obstacleBoundary.count){
                self.polygonDrawingCompleted = true
                for j in (0..<obstacleBoundary[i].count){
                    self.drawOnMap(coordinate: CLLocationCoordinate2D(latitude: obstacleBoundary[i][j].lat!, longitude: obstacleBoundary[i][j].lng!), mapView: self.googleMapView)
                }
            }
        }
        
        SessionUtils.saveLatestProject(project: project)
    }
    
    func drawOnMap (coordinate: CLLocationCoordinate2D, mapView: GMSMapView){
        let marker = GMSMarker(position: coordinate)
        marker.icon = UIImage(named: "rec")
        marker.map = mapView
        
        if polygonDrawingCompleted {
            var arr: [GMSMarker] = []
            arr.append(marker)
            obsMarkers.append(arr)
        }else{
            let markerIndex = obsMarkers.endIndex - 1
            obsMarkers[markerIndex].append(marker)
        }
        
        if polygonDrawingCompleted {
            polygonDrawingCompleted = false
            let path = GMSMutablePath()
            path.add(coordinate)
            obsPolygonPaths.append(path)
            
            let pathIndex = obsPolygonPaths.endIndex - 1
            
            let currentPlogyon = GMSPolygon(path: obsPolygonPaths[pathIndex])
            obsPolygons.append(currentPlogyon)
            
            let index = obsPolygons.endIndex - 1
            obsPolygons[index].strokeWidth = 1.5
            obsPolygons[index].fillColor = UIColor.red.withAlphaComponent(0.3)
            obsPolygons[index].strokeColor = .red
            obsPolygons[index].isTappable = true
            obsPolygons[index].map = mapView
            
        }else{
            let pathIndex = obsPolygonPaths.endIndex - 1
            let index = obsPolygons.endIndex - 1
            obsPolygonPaths[pathIndex].add(coordinate)
            obsPolygons[index].path = obsPolygonPaths[pathIndex]
        }
    }
    
    func removeAllObstacles(){
        self.polygonDrawingCompleted = true
        for marker in obsMarkers{
            for mark in marker{
                mark.map = nil
            }
        }
        obsMarkers.removeAll()
        obsMarkers = []
        
        obsPolygonPaths.removeAll()
        obsPolygonPaths = []
        
        for polygon in obsPolygons{
            if(polygon != nil){
                polygon.map = nil
            }
        }
        
        obsPolygons.removeAll()
        obsPolygons = []
        
    }
    
}

//Command View Controller Extension to Fly the Mission
extension TimelineMissionViewController{
    private func registerCommandListeners() {
        Environment.commandService.commandResponseListeners.append({ id, success in
            print("Comand Service commandResponseListeners \(success) \(id)")
            if success {
                switch id {
                    case .stop:
                        Environment.missionStateManager.state = .none
                    default:
                        break
                }
            }
        })
        Environment.commandService.missionFinished = { success in
            print("Comand Service missionFinished \(success)")
            self.assistantLbl.text = "Mission is completed."
            Environment.missionStateManager.state = .none
        }
        
        Environment.missionStateManager.stateListeners.append({ _, newState in
            print("Comand Service stateListeners \(newState)")
            if newState != .none && newState != .editing {
                self.setControls(for: newState)
                self.toggleShowView(show: true, delay: Animations.defaultDelay)
            } else {
                self.uploadMissionAndStartBtn.isHidden = false
                self.toggleShowView(show: false, delay: 0)
            }
        })
    }
    
    func setControls(for state: MissionState) {
        switch state {
            case .uploaded:
                self.commandStartBtn.isHidden = false
                self.commandPauseBtn.isHidden = true
                self.commandResumeBtn.isHidden = true
                self.commandStopBtn.isHidden = true
                self.commandGoHomeBtn.isHidden = true
                self.uploadMissionAndStartBtn.isHidden = true
            case .paused:
                self.commandStartBtn.isHidden = true
                self.commandPauseBtn.isHidden = true
                self.commandResumeBtn.isHidden = false
                self.commandStopBtn.isHidden = false
                self.commandGoHomeBtn.isHidden = false
                self.uploadMissionAndStartBtn.isHidden = true
            case .running:
                self.commandStartBtn.isHidden = true
                self.commandPauseBtn.isHidden = false
                self.commandResumeBtn.isHidden = true
                self.commandGoHomeBtn.isHidden = false
                self.commandStopBtn.isHidden = false
                self.isFlightContinue = true
                self.uploadMissionAndStartBtn.isHidden = true
            default:
                break
        }
    }
    
    func toggleShow(_ show: Bool) {
        self.commandView.layer.opacity = show ? 1 : 0
    }


    private func toggleShowView(show: Bool, delay: TimeInterval) {
        if show {
            self.commandView.isHidden = false
            self.uploadMissionAndStartBtn.isHidden = true
            self.isFlightContinue = true
            //self.takeOffLandBtn.isHidden = true
        }else{
            self.uploadMissionAndStartBtn.isHidden = false
            self.isFlightContinue = false
        }
        
        UIView.animate(
            withDuration: Animations.defaultDuration,
            delay: delay,
            options: [],
            animations: {
                self.toggleShow(show)
            },
            completion: { _ in
                if !show {
                    self.commandView.isHidden = true
                    //self.takeOffLandBtn.isHidden = false
                }else{
                    self.commandView.isHidden = false
                }
            }
        )
    }
}

//Console View Controller
extension TimelineMissionViewController{
    private func registerConsoleListeners() {
        Environment.commandService.logConsole = { message, type in
            self.logConsole(message, type)
        }
//        Environment.mapViewController.logConsole = { message, type in
//            self.logConsole(message, type)
//        }
//        Environment.missionViewController.logConsole = { message, type in
//            self.logConsole(message, type)
//        }
        Environment.simulatorService.logConsole = { message, type in
            self.logConsole(message, type)
        }
        Environment.connectionService.logConsole = { message, type in
            self.logConsole(message, type)
        }
        Environment.missionStorage.logConsole = { message, type in
            self.logConsole(message, type)
        }
        Environment.missionStateManager.logConsole = {message, type in
            self.logConsole(message, type)
        }
    }


    func currentDateString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }

    private func logConsole(_ message: String, _ type: OSLogType) {
        os_log("%@", type: type, message)
        var color = UIColor.white
        let attributedString = NSMutableAttributedString(string: message)
        if(message.contains("Heading to waypoint:")){
            color = UIColor.orange
            self.disableButtons()
        }
        else if(message.contains("Mission is completed.")){
            color = UIColor.green
            self.enableButtons()
        }else{
            self.enableButtons()
        }
        
        
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange(location: 0, length: message.count))
        self.assistantLbl.attributedText = attributedString
    }
    
    func disableButtons(){
        self.waypointSettingBtn.isEnabled = false
        self.homeDrawBtn.isEnabled = false
        self.drawBtn.isEnabled = false
        self.projectsListBtn.isEnabled = false
        self.allWaypointsSettingsBtn.isEnabled = false
        self.missionSettingBtn.isEnabled = false
    }
    
    func enableButtons(){
        self.waypointSettingBtn.isEnabled = true
        self.homeDrawBtn.isEnabled = true
        self.drawBtn.isEnabled = true
        self.projectsListBtn.isEnabled = true
        self.allWaypointsSettingsBtn.isEnabled = true
        self.missionSettingBtn.isEnabled = true
    }
}

extension TimelineMissionViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allProjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.projectsTableView.dequeueReusableCell(withIdentifier: "project_cell", for: indexPath) as! ProjectCell
        cell.projectNamelbl.text = allProjects[indexPath.row].name
        cell.projectAddressLbl.text = allProjects[indexPath.row].address
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        selectProjectByIndex(index: index)
    }
    
}

class ProjectCell: UITableViewCell{
    @IBOutlet weak var projectAddressLbl: UILabel!
    @IBOutlet weak var projectNamelbl: UILabel!
}

extension Double {
    func rounded(toPlaces places: Int) -> Double{
        let advisor = pow(10.0, Double(places))
        return (self*advisor).rounded() / advisor
    }
}
