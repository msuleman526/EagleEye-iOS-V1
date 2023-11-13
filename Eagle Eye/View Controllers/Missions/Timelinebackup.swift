////
////  TimelineMissionViewController.swift
////  SDK Swift Sample
////
////  Created by Arnaud Thiercelin on 3/22/17.
////  Copyright © 2017 DJI. All rights reserved.
////
//
//import UIKit
//import os.log
//import DJISDK
//import iOSDropDown
//
//enum TimelineElementKind: String {
//    case takeOff = "Take Off"
//    case goTo = "Go To"
//    case goHome = "Go Home"
//    case gimbalAttitude = "Gimbal Attitude"
//    case singleShootPhoto = "Single Photo"
//    case continuousShootPhoto = "Continuous Photo"
//    case recordVideoDuration = "Record Duration"
//    case recordVideoStart = "Start Record"
//    case recordVideoStop = "Stop Record"
//    case waypointMission = "Waypoint Mission"
//    case hotpointMission = "Hotpoint Mission"
//    case aircraftYaw = "Aircraft Yaw"
//}
//
//class TimelineMissionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, DJICameraDelegate, DJIFlightControllerDelegate{
//
//    //Mission Setting Components
//    var missionSetting = MissionSetting()
//    let finishActions: [DJIWaypointMissionFinishedAction] = [.noAction, .autoLand, .continueUntilStop, .goFirstWaypoint, .goHome]
//    let headingMode: [DJIWaypointMissionHeadingMode] = [.auto, .controlledByRemoteController, .towardPointOfInterest, .usingInitialDirection, .usingWaypointHeading]
//    let finishActionsTxts: [String] = ["No Action", "Auto Land", "Continue Util Stop", "Go First Waypoint", "Go Home"]
//    let headModesTxts: [String] = ["Auto", "Control By Remote", "Towards POI", "Using Initial Direction", "Using Waypoint Heading"]
//
//
//
//    @IBOutlet weak var commandStopBtn: UIButton!
//    @IBOutlet weak var commandGoHomeBtn: UIButton!
//    @IBOutlet weak var commandResumeBtn: UIButton!
//    @IBOutlet weak var commandPauseBtn: UIButton!
//    @IBOutlet weak var commandStartBtn: UIButton!
//    @IBOutlet weak var commandView: UIView!
//
//    @IBOutlet weak var uploadMissionBtn: UIButton!
//
//
//    @IBOutlet weak var poiBar: UISlider!
//    @IBOutlet weak var poiHeightLbl: UILabel!
//    @IBOutlet weak var assistantLbl: UILabel!
//    //Mission Setting Views
//    @IBOutlet weak var settingBtnsView: UIView!
//    @IBOutlet weak var missionSettingView: UIView!
//    @IBOutlet weak var missionSettingLabel: UILabel!
//    @IBOutlet weak var maxFlightSpeedPlusBtn: UIButton!
//    @IBOutlet weak var maxFlightSpeedMinusBtn: UIButton!
//    @IBOutlet weak var maxFlightSpeedBar: UISlider!
//    @IBOutlet weak var maxFlightSpeedLbl: UILabel!
//    @IBOutlet weak var autoSpeedLbl: UILabel!
//    @IBOutlet weak var rotateGimbalBar: UISegmentedControl!
//    @IBOutlet weak var connectionLoseBar: UISegmentedControl!
//    @IBOutlet weak var autoSpeedBar: UISlider!
//    @IBOutlet weak var repeatTimesLbl: UILabel!
//    @IBOutlet weak var repeatTimesBar: UISlider!
//    @IBOutlet weak var goToBar: UISegmentedControl!
//    @IBOutlet weak var finishActionDropDown: DropDown!
//    @IBOutlet weak var waypointPathBar: UISegmentedControl!
//    @IBOutlet weak var headingModeDropdown: DropDown!
//
//    //WayPoint Setting Views
//
//    @IBOutlet weak var gimbalPitchBar: UISlider!
//    @IBOutlet weak var gimbalPicthLbl: UILabel!
//    @IBOutlet weak var turnModeBar: UISegmentedControl!
//    @IBOutlet weak var cornerRadiusBar: UISlider!
//    @IBOutlet weak var cornerRadiusLbl: UILabel!
//    @IBOutlet weak var actionTimeoutBar: UISlider!
//    @IBOutlet weak var actionTimoutLbl: UILabel!
//    @IBOutlet weak var wayPointRepeatTimeBar: UISlider!
//    @IBOutlet weak var wayPointRepeatTimeLbl: UILabel!
//    @IBOutlet weak var headingBar: UISlider!
//    @IBOutlet weak var headingLbl: UILabel!
//    @IBOutlet weak var altitudeBar: UISlider!
//    @IBOutlet weak var altitudeLbl: UILabel!
//    @IBOutlet weak var waypointSettingView: UIView!
//    @IBOutlet weak var wayPointLabl: UILabel!
//    var selectedWayPoint: Int = 0
//
//    @IBOutlet weak var availableElementsView: UICollectionView!
//    @IBOutlet weak var simulatorSwitch: UISwitch!
//    @IBOutlet weak var mapView: MKMapView!
//    @IBOutlet weak var timelineView: UICollectionView!
//    @IBOutlet weak var cameraFPVView: UIView!
//    @IBOutlet weak var drawBtn: UIButton!
//    @IBOutlet weak var playButton: UIButton!
//    @IBOutlet weak var stopButton: UIButton!
//
//    @IBOutlet weak var cameraContainerWidthConstraint: NSLayoutConstraint!
//    @IBOutlet weak var cameraContainerHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var cameraContainer: UIView!
//    @IBOutlet weak var cameraBtn: UIButton!
//
//    @IBOutlet weak var takeOffLandBtn: UIButton!
//
//    @IBOutlet weak var connectionLbl: UILabel!
//    @IBOutlet weak var homeDrawBtn: UIButton!
//
//    @IBOutlet weak var flightModelLabel: UILabel!
//    @IBOutlet weak var gpsImageView: UIImageView!
//
//    @IBOutlet weak var remoteSignalImage: UIImageView!
//    @IBOutlet weak var remoteImage: UIImageView!
//    @IBOutlet weak var betteryLabel: UILabel!
//    @IBOutlet weak var gpsSignalLabel: UILabel!
//    @IBOutlet weak var betteryImageView: UIImageView!
//    @IBOutlet weak var settingsButtonsView: UIView!
//    @IBOutlet weak var informationView: UIView!
//    @IBOutlet weak var distanceLabel: UILabel!
//    @IBOutlet weak var altitudeLabel: UILabel!
//    @IBOutlet weak var vsSpeedLabel: UILabel!
//    @IBOutlet weak var hsSpeedLabel: UILabel!
//
//    var availableElements = [TimelineElementKind]()
//    var adapter: VideoPreviewerAdapter?
//
//    var points: [MKPointAnnotation] = []
//    var waypointsList: [WaypointSetting] = []
//    var allOverLays: [MKOverlay] = []
//    var polyline:MKPolyline?
//
//    var homeAnnotation = MovingObject(CLLocationCoordinate2D(), 0.0, .home)
//    var aircraftAnnotation = MovingObject(CLLocationCoordinate2D(), 0.0, .aircraft)
//    var userAnnotation = MovingObject(CLLocationCoordinate2D(), 0.0, .user)
//
//    var aircraftAnnotationView: MKAnnotationView!
//    var droneLocation:CLLocation?
//    var locationManager = CLLocationManager()
//    var tapRecognizer = UILongPressGestureRecognizer()
//    var panRecognizer = UIPanGestureRecognizer()
//
//    // Computed properties
//    var userLocation: CLLocationCoordinate2D? {
//        return objectPresentOnMap(userAnnotation) ? userAnnotation.coordinate : nil
//    }
//
//    var scheduledElements = [TimelineElementKind]()
//    var isProductConnectd:Bool = false
//    var isDrawing: Bool = false
//    var isHomeDrawing: Bool = false
//
//    fileprivate var _isSimulatorActive: Bool = false
//
//    public var isSimulatorActive: Bool {
//        get {
//            return _isSimulatorActive
//        }
//        set {
//            _isSimulatorActive = newValue
//        }
//    }
//
//    var isFlying:Bool = false
//
//    var isFullCamera: Bool = false
//    var pointOfInterest: MKPointAnnotation? = nil
//
//    //Telemetry View
//    var lastHomeLocation: CLLocation?
//
//    fileprivate var started = false
//    fileprivate var paused = false
//
//    var aircraft: DJIAircraft? = nil
//    var flightController: DJIFlightController? = nil
//
//    var isSeprateWaypointSetting:Bool = false
//    var allWaypointSetting: WaypointSetting? = nil
//
//
//    @IBOutlet weak var previousWaypointBtn: UIButton!
//    @IBOutlet weak var nextWaypointBtn: UIButton!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        navigationController?.setNavigationBarHidden(true, animated: true)
//        initView()
//        aircraft = DJISDKManager.product() as? DJIAircraft
//        flightController = aircraft?.flightController
//
//        flightController?.delegate = self
//
//        self.cameraBtn.isHidden = false
//        self.connectionLbl.text = "Connected"
//        self.connectionLbl.textColor = .green
//        //checkConnectivity()
//        showSettingsButtonsView()
//    }
//
//    func initView(){
//        self.setUpCamera()
//
//        self.availableElementsView.delegate = self
//        self.availableElementsView.dataSource = self
//
//        self.timelineView.delegate = self
//        self.timelineView.dataSource = self
//
//        self.availableElements.append(contentsOf: [.takeOff, .goTo, .goHome, .gimbalAttitude, .singleShootPhoto, .continuousShootPhoto, .recordVideoDuration, .recordVideoStart, .recordVideoStop, .waypointMission, .hotpointMission, .aircraftYaw])
//
//        mapView.delegate = self
//        mapView.delegate = self
//        mapView.register(MovingObjectView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(MovingObject.self))
//        mapView.mapType = .hybrid
//        mapView.isZoomEnabled = true
//
//
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        locationManager.delegate = self;
//        locationManager.requestAlwaysAuthorization()
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.startUpdatingHeading()
//
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
//        self.mapView.addGestureRecognizer(tapGesture)
//
////        panRecognizer.delegate = self
////        panRecognizer.minimumNumberOfTouches = 1
////        panRecognizer.maximumNumberOfTouches = 1
////        panRecognizer.addTarget(self, action: #selector(handlePolygonDrag(sender:)))
//
//        registerTelemetryServices()
//        registerListeners()
//        registerCommandListeners()
//        registerConsoleListeners()
//
//        self.setUpMissionViewValues()
//        self.setUpWaypointSettingViewValues()
//
//        weak var weakSelf = self
//        if let isSimulatorActiveKey = DJIFlightControllerKey(param: DJIFlightControllerParamIsSimulatorActive) {
//            let simulatorActiveValue : DJIKeyedValue? = DJISDKManager.keyManager()?.getValueFor(isSimulatorActiveKey)
//            if simulatorActiveValue != nil{
//                weakSelf?.simulatorSwitch.isOn = (simulatorActiveValue?.boolValue)!
//                weakSelf?._isSimulatorActive = (simulatorActiveValue?.boolValue)!
//            }
//            DJISDKManager.keyManager()?.startListeningForChanges(on: isSimulatorActiveKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
//                if newValue?.boolValue != nil {
//                    weakSelf?._isSimulatorActive = (newValue?.boolValue)!
//                    weakSelf?.simulatorSwitch.isOn = (newValue?.boolValue)!
//                }
//            })
//        }
//
//
//    }
//
//    //This Will Setup the View on Buttons
//    func showSettingsButtonsView(){
//        var border = CAShapeLayer()
//        border.cornerRadius = 12
//        border.strokeColor = UIColor.white.cgColor
//        border.lineDashPattern = [10,5]
//        border.frame = settingsButtonsView.bounds
//        border.fillColor = nil
//        border.path = UIBezierPath(rect: settingsButtonsView.bounds).cgPath
//        border.lineWidth = 2
//
//        settingsButtonsView.layer.addSublayer(border)
//
//        border = CAShapeLayer()
//        border.cornerRadius = 12
//        border.strokeColor = UIColor.white.cgColor
//        border.lineDashPattern = [10,5]
//        border.frame = settingsButtonsView.bounds
//        border.fillColor = nil
//        border.path = UIBezierPath(rect: settingBtnsView.bounds).cgPath
//        border.lineWidth = 2
//
//        settingBtnsView.layer.addSublayer(border)
//    }
//
//
//    //All IBActions List
//    @IBAction func settingButtonClick(_ sender: Any) {
//        self.startSetting()
//    }
//
//
//    @IBAction func saveDefaultMissionSetting(_ sender: Any) {
//
//    }
//
//    @IBAction func onAllWaypointSettingClick(_ sender: Any) {
//        self.nextWaypointBtn.isHidden = true
//        self.previousWaypointBtn.isHidden = true
//        isSeprateWaypointSetting = false
//        if(waypointsList.count == 0){
//            self.showAlertViewWithTitle(title: "No Waypoints", withMessage: "Please draw waypoints")
//        }else{
//            self.missionSettingView.isHidden = true
//            self.waypointSettingView.isHidden = false
//            self.setUpWaypointValues()
//        }
//    }
//
//
//    @IBAction func onWaypointSettingBtnClick(_ sender: Any) {
//        self.nextWaypointBtn.isHidden = false
//        self.previousWaypointBtn.isHidden = false
//        isSeprateWaypointSetting = true
//        if(waypointsList.count == 0){
//            self.showAlertViewWithTitle(title: "No Waypoints", withMessage: "Please draw waypoints")
//        }else{
//            self.missionSettingView.isHidden = true
//            self.waypointSettingView.isHidden = false
//            self.setUpWaypointValues()
//
//        }
//    }
//
//    @IBAction func onMissionUploadClick(_ sender: Any) {
//
//        if(pointOfInterest == nil){
//            self.showAlertViewWithTitle(title: "No POI", withMessage: "No POI found.")
//        }else if(self.waypointsList.count == 0){
//            self.showAlertViewWithTitle(title: "No Waypoint", withMessage: "Please draw waypoints for mission")
//        }else{
//            if(Environment.commandService.setMissionCoordinatesWithPOI(waypointsList, missionSetting: missionSetting, poi: CLLocationCoordinate2D(latitude: (pointOfInterest?.coordinate.latitude)!, longitude: (pointOfInterest?.coordinate.longitude)!))){
//                Environment.commandService.executeMissionCommand(.upload)
//            }
//        }
//
//    }
//
//
//    @IBAction func onMissionSettingBtnClick(_ sender: Any) {
//        self.missionSettingView.isHidden = false
//        self.waypointSettingView.isHidden = true
//        self.setUpMissionValues()
//    }
//
//    @IBAction func onCloseMissionSettingClick(_ sender: Any) {
//        self.missionSettingView.isHidden = true
//    }
//
//    @IBAction func onSaveMissionSettingClick(_ sender: Any) {
//
//        missionSetting.maxFlightSpeed = Int(self.maxFlightSpeedBar.value)
//        missionSetting.autoFlightSpeed = Int(self.autoSpeedBar.value)
//        missionSetting.repeatTimes = Int(self.repeatTimesBar.value)
//        missionSetting.poiHeight = Int(self.poiBar.value)
//
//        if self.rotateGimbalBar.selectedSegmentIndex == 0{
//            missionSetting.rotateGimblePitch = false
//        }else{
//            missionSetting.rotateGimblePitch = true
//        }
//
//        if self.connectionLoseBar.selectedSegmentIndex == 0{
//            missionSetting.exitMissionOnRCSignalLost = false
//        }else{
//            missionSetting.exitMissionOnRCSignalLost = true
//        }
//
//        if self.goToBar.selectedSegmentIndex == 0{
//            missionSetting.gotoFirstWaypointMode = .safely
//        }else{
//            missionSetting.gotoFirstWaypointMode = .pointToPoint
//        }
//
//        if self.waypointPathBar.selectedSegmentIndex == 0{
//            missionSetting.flightPathMode = .normal
//        }else{
//            missionSetting.flightPathMode = .curved
//        }
//
//        missionSetting.finishAction = self.finishActions[self.finishActionDropDown.selectedIndex!]
//        missionSetting.headingMode = self.headingMode[self.headingModeDropdown.selectedIndex!]
//
//
//    }
//
//    @IBAction func onSaveWaypointSetting(_ sender: Any) {
//
//        if(isSeprateWaypointSetting == true){
//
//            self.waypointsList[selectedWayPoint].altitude = Int(self.altitudeBar.value)
//            self.waypointsList[selectedWayPoint].heading = Double(self.headingBar.value)
//            self.waypointsList[selectedWayPoint].actionRepeatTimes = Int(self.wayPointRepeatTimeBar.value)
//            self.waypointsList[selectedWayPoint].actionTimeoutInSeconds = Int(self.actionTimeoutBar.value)
//            self.waypointsList[selectedWayPoint].cornerRadiusInMeters = Int(self.cornerRadiusBar.value)
//            self.waypointsList[selectedWayPoint].gimbalPitch = Int(self.gimbalPitchBar.value)
//
//            if self.turnModeBar.selectedSegmentIndex == 0{
//                self.waypointsList[selectedWayPoint].turnMode = .clockwise
//            }else{
//                self.waypointsList[selectedWayPoint].turnMode = .counterClockwise
//            }
//            Toast.show(message: "Waypoint \(Int(selectedWayPoint) + 1) setting saved", controller: self)
//        }else{
//            for i in (0 ..< self.waypointsList.count) {
//                self.waypointsList[i].altitude = Int(self.altitudeBar.value)
//                self.waypointsList[i].heading = Double(self.headingBar.value)
//                self.waypointsList[i].actionRepeatTimes = Int(self.wayPointRepeatTimeBar.value)
//                self.waypointsList[i].actionTimeoutInSeconds = Int(self.actionTimeoutBar.value)
//                self.waypointsList[i].cornerRadiusInMeters = Int(self.cornerRadiusBar.value)
//                self.waypointsList[i].gimbalPitch = Int(self.gimbalPitchBar.value)
//
//                if self.turnModeBar.selectedSegmentIndex == 0{
//                    self.waypointsList[i].turnMode = .clockwise
//                }else{
//                    self.waypointsList[i].turnMode = .counterClockwise
//                }
//            }
//            Toast.show(message: "All waypoint setting saved", controller: self)
//        }
//
//    }
//
//    @IBAction func onPreviousWaypointClick(_ sender: Any) {
//        if(selectedWayPoint != 0){
//            selectedWayPoint = selectedWayPoint - 1
//            self.setUpWaypointValues()
//        }
//    }
//
//    @IBAction func onNextWayPointClick(_ sender: Any) {
//        let length = waypointsList.count - 1
//        if(selectedWayPoint != length){
//            selectedWayPoint = selectedWayPoint + 1
//            self.setUpWaypointValues()
//        }
//    }
//
//    @IBAction func onCloseWaypointSetting(_ sender: Any) {
//        self.waypointSettingView.isHidden = true
//    }
//
//
//    @IBAction func deleteAllClick(_ sender: Any) {
//        let alertController = UIAlertController(title: "Delete All", message: "Are you sure you want to delete all way points.", preferredStyle: .alert)
//        let action1 = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
//            alertController.dismiss(animated: false)
//        })
//        let action2 = UIAlertAction(title: "Delete Waypoints", style: .default, handler: { (action) in
//            self.deleteWaypoints()
//        })
//        let action3 = UIAlertAction(title: "Delete Waypoints & POI", style: .default, handler: { (action) in
//            self.deleteWaypointsAndPOI()
//        })
//        alertController.addAction(action1)
//        alertController.addAction(action2)
//        alertController.addAction(action3)
//
//        // Present the alert controller
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    @IBAction func onCancelSettingClick(_ sender: Any) {
//        self.endSettings()
//    }
//
//
//    @IBAction func deletePOIClick(_ sender: Any) {
//        let alertController = UIAlertController(title: "Delete All", message: "Are you sure you want to delete POI, It will delete also delete waypoints", preferredStyle: .alert)
//        let action1 = UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
//            alertController.dismiss(animated: false)
//        })
//        let action2 = UIAlertAction(title: "Delete", style: .default, handler: { (action) in
//            self.deleteWaypointsAndPOI()
//        })
//
//        alertController.addAction(action1)
//        alertController.addAction(action2)
//
//        // Present the alert controller
//        self.present(alertController, animated: true, completion: nil)
//    }
//
//    @IBAction func cameraHeightBtnClick(_ sender: Any) {
//        if isFullCamera == true{
//            isFullCamera = false
//            UIView.animate(withDuration: 0.3) {
//                self.cameraContainerWidthConstraint.constant = 190
//                self.cameraContainerHeightConstraint.constant = 102
//            }
//            self.cameraBtn.setImage(UIImage(systemName: "plus.circle"), for: .normal)
//        }else{
//            isFullCamera = true
//            UIView.animate(withDuration: 0.3) {
//                self.cameraContainerWidthConstraint.constant = 300
//                self.cameraContainerHeightConstraint.constant = 180
//            }
//            self.cameraBtn.setImage(UIImage(systemName: "minus.circle"), for: .normal)
//        }
//        adapter?.stop()
//        adapter = VideoPreviewerAdapter.init()
//        adapter?.start()
//    }
//
//
//    @IBAction func startDrawing(_ sender: Any) {
//        isHomeDrawing = false
//        homeDrawBtn.setImage(UIImage(named: "home"), for: .normal)
//
//        if pointOfInterest == nil{
//            isDrawing = false
//            drawBtn.setImage(UIImage(named: "add"), for: .normal)
//            self.showAlertViewWithTitle(title: "POI", withMessage: "Please draw point of interest before drawing waypoints")
//        }else{
//            if(isDrawing == true){
//                isDrawing = false
//                drawBtn.setImage(UIImage(named: "add"), for: .normal)
//            }else{
//                isDrawing = true
//                drawBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
//            }
//        }
//    }
//
//    @IBAction func drawPointOfInterest(_ sender: Any) {
//        isDrawing = false
//        drawBtn.setImage(UIImage(named: "add"), for: .normal)
//
//        if(isHomeDrawing == true){
//            isHomeDrawing = false
//            homeDrawBtn.setImage(UIImage(named: "home"), for: .normal)
//        }else{
//            isHomeDrawing = true
//            homeDrawBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
//        }
//    }
//
//
//    @objc private func handleTap(sender: UIGestureRecognizer) {
//        let touchCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
//        if(isDrawing == true && pointOfInterest != nil){
//            // Add a point at the tapped location
//            drawWaypoint(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude )
//        }
//        else if(isHomeDrawing == true){
//            if(pointOfInterest == nil){
//                pointOfInterest = MKPointAnnotation()
//                pointOfInterest!.title = "Point of Interest"
//                pointOfInterest!.coordinate = CLLocationCoordinate2D(latitude: touchCoordinate.latitude, longitude: touchCoordinate.longitude)
//                mapView.addAnnotation(pointOfInterest!)
//            }
//        }
//    }
//
//    @IBAction func playButtonAction(_ sender: Any) {
//        print("playButtonAction")
//        print("Pause \(self.paused)")
//        print("started \(self.started)")
//        if self.paused {
//            print("Self.Pause")
//            DJISDKManager.missionControl()?.resumeTimeline()
//        } else if self.started {
//            print("Self.Statertedause")
//            DJISDKManager.missionControl()?.pauseTimeline()
//        } else {
//            print("Self.Start")
//            DJISDKManager.missionControl()?.startTimeline()
//        }
//    }
//
//    @IBAction func stopButtonAction(_ sender: Any) {
//        print("Stop Button Click")
//        DJISDKManager.missionControl()?.stopTimeline()
//    }
//
//
//    @IBAction func onSimulatorSwitchValueChanged(_ sender: UISwitch) {
//        startSimulatorButtonAction()
//    }
//
//    func startSetting(){
//        self.informationView.isHidden = true
//        self.settingsButtonsView.isHidden = false
//        self.settingBtnsView.isHidden = false
//    }
//
//    func endSettings(){
//        self.informationView.isHidden = false
//        self.settingsButtonsView.isHidden = true
//        self.settingBtnsView.isHidden = true
//    }
//
//    func deleteWaypoints(){
//        if(points.count == 0){
//            self.showAlertViewWithTitle(title: "No Waypoints", withMessage: "No Waypoints deleted")
//        }else{
//            self.mapView.removeAnnotations(points)
//            points = []
//            waypointsList = []
//            selectedWayPoint = 0
//            reDrawAnnotations()
//            self.mapView.removeOverlays(allOverLays)
//            self.waypointSettingView.isHidden = true
//        }
//    }
//
//    func deleteWaypointsAndPOI(){
//        if(pointOfInterest != nil){
//            self.mapView.removeAnnotation(pointOfInterest!)
//            pointOfInterest = nil
//            self.deleteWaypoints()
//        }else{
//            self.showAlertViewWithTitle(title: "No POI", withMessage: "No Point of Interest Found")
//        }
//    }
//
//    func checkConnectivity() {
//        guard let connectedKey = DJIProductKey(param: DJIParamConnection) else {
//            NSLog("Error creating the connectedKey")
//            isProductConnectd = false
//            self.connectionLbl.text = "Disconnected"
//            self.connectionLbl.textColor = .red
//            hideElements()
//            return;
//        }
//
//        print("Connecting Check")
//        DJISDKManager.keyManager()?.startListeningForChanges(on: connectedKey, withListener: self, andUpdate: { (oldValue: DJIKeyedValue?, newValue : DJIKeyedValue?) in
//            if newValue != nil {
//                if newValue!.boolValue {
//                    // At this point, a product is connected so we can show it.
//
//                    // UI goes on MT.
//                    DispatchQueue.main.async {
//                        self.isProductConnectd = true
//                        self.connectionLbl.text = "Connected"
//                        self.connectionLbl.textColor = .green
//                        self.showElements()
//                        self.initView()
//                    }
//                }else{
//                    self.isProductConnectd = false
//                    self.connectionLbl.text = "Disconnected"
//                    self.connectionLbl.textColor = .red
//                    self.hideElements()
//                }
//            }
//        })
//        DJISDKManager.keyManager()?.getValueFor(connectedKey, withCompletion: { (value:DJIKeyedValue?, error:Error?) in
//            if let unwrappedValue = value {
//                if unwrappedValue.boolValue {
//                    // UI goes on MT.
//                    DispatchQueue.main.async {
//                        self.isProductConnectd = true
//                    }
//                }else{
//                    self.isProductConnectd = false
//                    self.connectionLbl.text = "Disconnected"
//                    self.connectionLbl.textColor = .red
//                    self.hideElements()
//                }
//            }
//        })
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
//            self.checkConnectivity()
//        }
//    }
//
//
//    func drawWaypoint(latitude: Double, longitude: Double){
//
//        let waypointSetting = WaypointSetting()
//        waypointSetting.name = "Waypoint -  \(points.count+1)"
//
//        let point = MKPointAnnotation()
//        point.title = "Waypoint -  \(points.count+1)"
//        point.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
//        points.append(point)
//        mapView.addAnnotation(point)
//
//        waypointSetting.latittude = latitude
//        waypointSetting.longitude = longitude
//
//        let currentLocation = CLLocation(latitude: latitude, longitude: longitude)
//        let pointOfInterestLocation = CLLocation(latitude: (pointOfInterest?.coordinate.latitude)!, longitude: (pointOfInterest?.coordinate.longitude)!)
//
//        let angle = ImageUtils.getAngleBetweenPoints(point1: currentLocation, point2: pointOfInterestLocation)
//
//        waypointSetting.heading = angle
//
//        if(waypointsList.count == 0){
//            waypointSetting.gimbalPitch = 0
//        }
//        else{
//            let index = waypointsList.count - 1
//            if(waypointsList[index].gimbalPitch == 0){
//                waypointSetting.gimbalPitch = -90
//            }else{
//                waypointSetting.gimbalPitch = 0
//            }
//        }
//        waypointsList.append(waypointSetting)
//        connectPoints()
//    }
//
//    //Back Button Click
//    @IBAction func backButtonClick(_ sender: Any) {
//        navigationController?.popViewController(animated: true)
//    }
//
//    //this method calls after drag and drop points and draw points
//    func connectPoints() {
//        let pointCount = points.count
//        if pointCount < 2 { return }
//
//        if let polyline = polyline{
//            mapView.removeOverlay(polyline)
//        }
//        polyline = MKPolyline(coordinates: points.map { $0.coordinate }, count: pointCount)
//        mapView.addOverlay(polyline!)
//    }
//
//    //This will redraw Annotations
//    func reDrawAnnotations(){
//        for point in points {
//            self.mapView.addAnnotation(point)
//        }
//    }
//
//
//    func setUpCamera(){
//        let camera = fetchCamera()
//        camera?.delegate = self
//
//        DJIVideoPreviewer.instance()?.start()
//
//        adapter = VideoPreviewerAdapter.init()
//        adapter?.start()
//
//        if camera?.displayName == DJICameraDisplayNameMavic2ZoomCamera ||
//            camera?.displayName == DJICameraDisplayNameDJIMini2Camera ||
//            camera?.displayName == DJICameraDisplayNameMavicAir2Camera ||
//            camera?.displayName == DJICameraDisplayNameDJIAir2SCamera ||
//            camera?.displayName == DJICameraDisplayNameMavic2ProCamera {
//            adapter?.setupFrameControlHandler()
//        }
//
//    }
//
//    func showElements(){
//        self.cameraBtn.isHidden = false
//    }
//
//    func hideElements(){
//        self.cameraBtn.isHidden = true
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        self.viewWillAppear(true)
//        navigationController?.setNavigationBarHidden(false, animated: false)
//
//        Environment.telemetryService.stopListeners()
//        Environment.locationService.stopListeners()
//
//        // Call unSetView during exiting to release the memory.
//        DJIVideoPreviewer.instance()?.unSetView()
//
//        if adapter != nil {
//            adapter?.stop()
//            adapter = nil
//        }
//    }
//
//    func showAlertViewWithTitle(title: String, withMessage message: String) {
//        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
//        let okAction = UIAlertAction.init(title:"OK", style: .default, handler: nil)
//        alert.addAction(okAction)
//        self.present(alert, animated: true, completion: nil)
//    }
//
//
//    override func viewWillAppear(_ animated: Bool) {
//
//        DJIVideoPreviewer.instance()?.setView(cameraFPVView)
//
//        Environment.telemetryService.registerListeners()
//        Environment.locationService.registerListeners()
//        registerTelemetryServices()
//
//        DJIVideoPreviewer.instance()?.setView(cameraFPVView)
//
//        if let camera = fetchCamera(){
//            camera.delegate = self
//            if camera.isFlatCameraModeSupported() == true {
//                camera.setFlatMode(.photoSingle, withCompletion: {(error: Error?) in
//                    if error != nil {
//                        print("Error set camera flat mode photo/video \(String(describing: error?.localizedDescription))");
//                    }
//                })
//                } else {
//                    camera.setMode(.shootPhoto, withCompletion: {(error: Error?) in
//                        if error != nil {
//                            print("Error set mode photo/video \(String(describing: error?.localizedDescription))");
//                        }
//                    })
//                }
//         }
//         if adapter == nil{
//            DJIVideoPreviewer.instance()?.start()
//            adapter = VideoPreviewerAdapter.init()
//            adapter?.start()
//        }
//
//        DJISDKManager.missionControl()?.addListener(self, toTimelineProgressWith: { (event: DJIMissionControlTimelineEvent, element: DJIMissionControlTimelineElement?, error: Error?, info: Any?) in
//
//            if let error = error{
//                print("Error - \(error)")
//            }
//
//            switch event {
//                case .started:
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
//        })
//
//        self.mapView.addAnnotations([self.aircraftAnnotation, self.homeAnnotation])
//
//        if let aircarftLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation)  {
//            DJISDKManager.keyManager()?.startListeningForChanges(on: aircarftLocationKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
//                if newValue != nil {
//                    let newLocationValue = newValue!.value as! CLLocation
//
//                    if CLLocationCoordinate2DIsValid(newLocationValue.coordinate) {
//                        self.aircraftAnnotation.coordinate = newLocationValue.coordinate
//                    }
//                }
//            }
//        }
//
//
//        if let aircraftHeadingKey = DJIFlightControllerKey(param: DJIFlightControllerParamCompassHeading) {
//            DJISDKManager.keyManager()?.startListeningForChanges(on: aircraftHeadingKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
//                if (newValue != nil) {
//                    self.aircraftAnnotation.heading = newValue!.doubleValue
//                    if (self.aircraftAnnotationView != nil) {
//                        self.aircraftAnnotationView.transform = CGAffineTransform(rotationAngle: CGFloat(self.degreesToRadians(Double(self.aircraftAnnotation.heading))))
//                    }
//                }
//            }
//        }
//
//        if let homeLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamHomeLocation) {
//            DJISDKManager.keyManager()?.startListeningForChanges(on: homeLocationKey, withListener: self) { [unowned self] (oldValue: DJIKeyedValue?, newValue: DJIKeyedValue?) in
//                if (newValue != nil) {
//                    let newLocationValue = newValue!.value as! CLLocation
//
//                    if CLLocationCoordinate2DIsValid(newLocationValue.coordinate) {
//                        self.homeAnnotation.coordinate = newLocationValue.coordinate
//                    }
//                }
//            }
//        }
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        DJIVideoPreviewer.instance()?.unSetView()
//
//        if adapter != nil {
//            adapter?.stop()
//            adapter = nil
//        }
//
//        DJISDKManager.missionControl()?.removeListener(self)
//        DJISDKManager.keyManager()?.stopAllListening(ofListeners: self)
//    }
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//    func startSimulatorButtonAction() {
//        weak var weakSelf = self
//
//        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
//            DJIAlert.show(title: "", msg: "No Drone Location Detected" , fromVC: weakSelf! as UIViewController)
//            return
//        }
//
//        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
//            DJIAlert.show(title: "", msg: "No Drone Location Detected" , fromVC: weakSelf! as UIViewController)
//            return
//        }
//
//        let droneLocation = droneLocationValue.value as! CLLocation
//
//        let location = CLLocationCoordinate2DMake(droneLocation.coordinate.latitude, droneLocation.coordinate.longitude);
//        if let aircraft = DJISDKManager.product() as? DJIAircraft {
//            if _isSimulatorActive {
//                aircraft.flightController?.simulator?.stop(completion: nil)
//            } else {
//                aircraft.flightController?.simulator?.start(withLocation: location,
//                                                                      updateFrequency: 30,
//                                                                      gpsSatellitesNumber: 12,
//                                                                      withCompletion: { (error) in
//                    if (error != nil) {
//                        weakSelf?.simulatorSwitch.isOn = false
//                        DJIAlert.show(title: "", msg: "start simulator failed:" + (error?.localizedDescription)!, fromVC: weakSelf! as UIViewController)
//                        NSLog("Start Simulator Error: \(error.debugDescription)")
//                    }else{
//                        DJIAlert.show(title: "", msg: "start simulator Successful!" , fromVC: weakSelf! as UIViewController)
//                                                                        }
//                })
//            }
//        }
//    }
//
//    func didStart() {
//        self.started = true
//        DispatchQueue.main.async {
//            self.stopButton.isEnabled = true
//            self.playButton.setTitle("⏸", for: .normal)
//        }
//    }
//
//    func didPause() {
//        self.paused = true
//        DispatchQueue.main.async {
//            self.playButton.setTitle("▶️", for: .normal)
//        }
//    }
//
//    func didResume() {
//        self.paused = false
//        DispatchQueue.main.async {
//            self.playButton.setTitle("⏸", for: .normal)
//        }
//    }
//
//    func didStop() {
//        print("Did Stopped")
//        self.started = false
//        DispatchQueue.main.async {
//            self.stopButton.isEnabled = false
//            self.playButton.setTitle("▶️", for: .normal)
//        }
//    }
//
//    //MARK: OutlineView Delegate & Datasource
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == self.availableElementsView {
//            return self.availableElements.count
//        } else if collectionView == self.timelineView {
//            return self.scheduledElements.count
//        }
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "elementCell", for: indexPath) as! TimelineElementCollectionViewCell
//
//        if collectionView == self.availableElementsView {
//            cell.label.text = self.availableElements[indexPath.row].rawValue
//        } else if collectionView == self.timelineView {
//            cell.label.text = self.scheduledElements[indexPath.row].rawValue
//        }
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView.isEqual(self.availableElementsView) {
//            let elementKind = self.availableElements[indexPath.row]
//
//            guard let element = self.timelineElementForKind(kind: elementKind) else {
//                return;
//            }
//            let error = DJISDKManager.missionControl()?.scheduleElement(element)
//
//            if error != nil {
//                NSLog("Error scheduling element \(String(describing: error))")
//                return;
//            }
//
//            self.scheduledElements.append(elementKind)
//            DispatchQueue.main.async {
//                self.timelineView.reloadData()
//            }
//        } else if collectionView.isEqual(self.timelineView) {
//            if self.started == false {
//                DJISDKManager.missionControl()?.unscheduleElement(at: UInt(indexPath.row))
//                self.scheduledElements.remove(at: indexPath.row)
//                DispatchQueue.main.async {
//                    self.timelineView.reloadData()
//                }
//            }
//        }
//    }
//
//    // MARK : Timeline Element
//
//    func timelineElementForKind(kind: TimelineElementKind) -> DJIMissionControlTimelineElement? {
//        switch kind {
//            case .takeOff:
//                return DJITakeOffAction()
//            case .goTo:
//                return DJIGoToAction(altitude: 30)
//            case .goHome:
//                return DJIGoHomeAction()
//            case .gimbalAttitude:
//                return self.defaultGimbalAttitudeAction()
//            case .singleShootPhoto:
//                return DJIShootPhotoAction(singleShootPhoto: ())
//            case .continuousShootPhoto:
//                return DJIShootPhotoAction(photoCount: 10, timeInterval: 3.0, waitUntilFinish: false)
//            case .recordVideoDuration:
//                return DJIRecordVideoAction(duration: 10)
//            case .recordVideoStart:
//                return DJIRecordVideoAction(startRecordVideo: ())
//            case .recordVideoStop:
//                return DJIRecordVideoAction(stopRecordVideo: ())
//            case .waypointMission:
//                return self.defaultWaypointMission()
//            case .hotpointMission:
//                return self.defaultHotPointAction()
//            case .aircraftYaw:
//                return DJIAircraftYawAction(relativeAngle: 36, andAngularVelocity: 30)
//        }
//    }
//
//
//    func defaultGimbalAttitudeAction() -> DJIGimbalAttitudeAction? {
//        let attitude = DJIGimbalAttitude(pitch: 30.0, roll: 0.0, yaw: 0.0)
//
//        return DJIGimbalAttitudeAction(attitude: attitude)
//    }
//
//    func defaultWaypointMission() -> DJIWaypointMission? {
//        let mission = DJIMutableWaypointMission()
//
//        mission.maxFlightSpeed = 15
//        mission.autoFlightSpeed = 8
//        mission.finishedAction = .noAction
//        mission.headingMode = .auto
//        mission.flightPathMode = .normal
//        mission.rotateGimbalPitch = true
//        mission.exitMissionOnRCSignalLost = true
//        mission.gotoFirstWaypointMode = .pointToPoint
//        mission.repeatTimes = 1
//
//        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
//            Toast.show(message: "Invalid Location Key", controller: self)
//            return nil
//        }
//
//        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
//            Toast.show(message: "Invalid Location", controller: self)
//            return nil
//        }
//
//        let droneLocation = droneLocationValue.value as! CLLocation
//        let droneCoordinates = droneLocation.coordinate
//
//        if !CLLocationCoordinate2DIsValid(droneCoordinates) {
//            return nil
//        }
//
//        mission.pointOfInterest = droneCoordinates
//        let offset = 0.0000899322
//
//
//        let loc1 = CLLocationCoordinate2DMake(droneCoordinates.latitude + offset, droneCoordinates.longitude)
//        drawWaypoint(latitude: loc1.latitude, longitude: loc1.longitude)
//        let waypoint1 = DJIWaypoint(coordinate: loc1)
//        waypoint1.altitude = 25
//        waypoint1.heading = 0
//        waypoint1.actionRepeatTimes = 1
//        waypoint1.actionTimeoutInSeconds = 60
//        waypoint1.cornerRadiusInMeters = 5
//        waypoint1.turnMode = .clockwise
//        waypoint1.gimbalPitch = 0
//
//        let loc2 = CLLocationCoordinate2DMake(droneCoordinates.latitude, droneCoordinates.longitude + offset)
//        drawWaypoint(latitude: loc2.latitude, longitude: loc2.longitude)
//        let waypoint2 = DJIWaypoint(coordinate: loc2)
//        waypoint2.altitude = 26
//        waypoint2.heading = 0
//        waypoint2.actionRepeatTimes = 1
//        waypoint2.actionTimeoutInSeconds = 60
//        waypoint2.cornerRadiusInMeters = 5
//        waypoint2.turnMode = .clockwise
//        waypoint2.gimbalPitch = -90
//
//        let loc3 = CLLocationCoordinate2DMake(droneCoordinates.latitude - offset, droneCoordinates.longitude)
//        drawWaypoint(latitude: loc3.latitude, longitude: loc3.longitude)
//        let waypoint3 = DJIWaypoint(coordinate: loc3)
//        waypoint3.altitude = 27
//        waypoint3.heading = 0
//        waypoint3.actionRepeatTimes = 1
//        waypoint3.actionTimeoutInSeconds = 60
//        waypoint3.cornerRadiusInMeters = 5
//        waypoint3.turnMode = .clockwise
//        waypoint3.gimbalPitch = 0
//        //waypoint3.waypointActions = DJIWaypointA
//
//
//        let loc4 = CLLocationCoordinate2DMake(droneCoordinates.latitude, droneCoordinates.longitude - offset)
//        drawWaypoint(latitude: loc4.latitude, longitude: loc4.longitude)
//        let waypoint4 = DJIWaypoint(coordinate: loc4)
//        waypoint4.altitude = 28
//        waypoint4.heading = 0
//        waypoint4.actionRepeatTimes = 1
//        waypoint4.actionTimeoutInSeconds = 60
//        waypoint4.cornerRadiusInMeters = 5
//        waypoint4.turnMode = .clockwise
//        waypoint4.gimbalPitch = -90
//
//        let waypoint5 = DJIWaypoint(coordinate: loc1)
//        drawWaypoint(latitude: loc1.latitude, longitude: loc1.longitude)
//        waypoint5.altitude = 29
//        waypoint5.heading = 0
//        waypoint5.actionRepeatTimes = 1
//        waypoint5.actionTimeoutInSeconds = 60
//        waypoint5.cornerRadiusInMeters = 5
//        waypoint5.turnMode = .clockwise
//        waypoint5.gimbalPitch = 0
//
//        mission.add(waypoint1)
//        mission.add(waypoint2)
//        mission.add(waypoint3)
//        mission.add(waypoint4)
//        mission.add(waypoint5)
//
//        return DJIWaypointMission(mission: mission)
//    }
//
//    func flightController(_ fc: DJIFlightController, didUpdate state: DJIFlightControllerState) {
//        if(state.isFlying == true){
//            self.isFlying = true
//            self.takeOffLandBtn.setImage(UIImage(named: "buttonCommandGoHome"), for: .normal)
//        }else{
//            self.isFlying = false
//            self.takeOffLandBtn.setImage(UIImage(named: "buttonCommandStart"), for: .normal)
//        }
//    }
//
//    @IBAction func onTakeOffAndLandBtn(_ sender: Any) {
//        DJISDKManager.missionControl()?.unscheduleEverything()
//        if isFlying == true{
//            let goHomeAction = DJIGoHomeAction()
//            goHomeAction.autoConfirmLandingEnabled = false
//            DJISDKManager.missionControl()?.scheduleElement(goHomeAction)
//        } else {
//            DJISDKManager.missionControl()?.scheduleElement(DJITakeOffAction())
//        }
//        DJISDKManager.missionControl()?.startTimeline()
//    }
//
//    func defaultHotPointAction() -> DJIHotpointAction? {
//        let mission = DJIHotpointMission()
//
//        guard let droneLocationKey = DJIFlightControllerKey(param: DJIFlightControllerParamAircraftLocation) else {
//            Toast.show(message: "Invalid Location Key", controller: self)
//            return nil
//        }
//
//        guard let droneLocationValue = DJISDKManager.keyManager()?.getValueFor(droneLocationKey) else {
//            Toast.show(message: "Invalid Location", controller: self)
//            return nil
//        }
//
//        let droneLocation = droneLocationValue.value as! CLLocation
//        let droneCoordinates = droneLocation.coordinate
//
//        if !CLLocationCoordinate2DIsValid(droneCoordinates) {
//            return nil
//        }
//
//        let offset = 0.0000899322
//
//        mission.hotpoint = CLLocationCoordinate2DMake(droneCoordinates.latitude + offset, droneCoordinates.longitude)
//        mission.altitude = 15
//        mission.radius = 15
//        DJIHotpointMissionOperator.getMaxAngularVelocity(forRadius: Double(mission.radius), withCompletion: {(velocity:Float, error:Error?) in
//            mission.angularVelocity = velocity
//        })
//        mission.startPoint = .nearest
//        mission.heading = .alongCircleLookingForward
//
//        return DJIHotpointAction(mission: mission, surroundingAngle: 180)
//    }
//
//    // MARK: - Convenience
//
//    func degreesToRadians(_ degrees: Double) -> Double {
//        return Double.pi / 180 * degrees
//    }
//
//    //Mission Listeners
//    @IBAction func onMaxSpeedChangeListener(_ sender: Any) {
//        self.maxFlightSpeedBar.value = Float(Int(self.maxFlightSpeedBar.value))
//        self.maxFlightSpeedLbl.text = "\(self.maxFlightSpeedBar.value) m/s"
//    }
//
//    @IBAction func onMaxPlusClick(_ sender: Any) {
//        self.maxFlightSpeedBar.value = self.maxFlightSpeedBar.value + 1
//        self.maxFlightSpeedLbl.text = "\(self.maxFlightSpeedBar.value) m/s"
//    }
//
//    @IBAction func onMaxMinusClick(_ sender: Any) {
//        self.maxFlightSpeedBar.value = self.maxFlightSpeedBar.value - 1
//        self.maxFlightSpeedLbl.text = "\(self.maxFlightSpeedBar.value) m/s"
//    }
//
//    @IBAction func autoSpeedPlusClick(_ sender: Any) {
//        self.autoSpeedBar.value = self.autoSpeedBar.value + 1
//        self.autoSpeedLbl.text = "\(self.autoSpeedBar.value) m/s"
//    }
//
//    @IBAction func autoSpeedMinusClick(_ sender: Any) {
//        self.autoSpeedBar.value = self.autoSpeedBar.value - 1
//        self.autoSpeedLbl.text = "\(self.autoSpeedBar.value) m/s"
//    }
//
//    @IBAction func autoSpeedChangeListener(_ sender: Any) {
//        self.autoSpeedBar.value = Float(Int(self.autoSpeedBar.value))
//        self.autoSpeedLbl.text = "\(self.autoSpeedBar.value) m/s"
//    }
//
//    @IBAction func rotateGimbleListener(_ sender: Any) {
//    }
//
//    @IBAction func connectionLoseListener(_ sender: Any) {
//    }
//
//    @IBAction func gotToListener(_ sender: Any) {
//    }
//
//    @IBAction func pathModeListener(_ sender: Any) {
//    }
//
//    @IBAction func repeatTimeMinusClick(_ sender: Any) {
//        DJISDKManager.product()
//        self.repeatTimesBar.value = self.repeatTimesBar.value - 1
//        self.repeatTimesLbl.text = "\(self.repeatTimesBar.value)"
//    }
//
//    @IBAction func repeatTimePlusClick(_ sender: Any) {
//        self.repeatTimesBar.value = self.repeatTimesBar.value + 1
//        self.repeatTimesLbl.text = "\(self.repeatTimesBar.value)"
//    }
//
//    @IBAction func repeatTimeBarListener(_ sender: Any) {
//        self.repeatTimesBar.value = Float(Int(self.repeatTimesBar.value))
//        self.repeatTimesLbl.text = "\(self.repeatTimesBar.value)"
//    }
//
//    //Waypoint Value Change Listeners
//
//    @IBAction func onAltitudeChange(_ sender: Any) {
//        self.altitudeBar.value = Float(Int(self.altitudeBar.value))
//        self.altitudeLbl.text = "\(self.altitudeBar.value)m"
//    }
//
//    @IBAction func onAltitudePlusClick(_ sender: Any) {
//        self.altitudeBar.value = Float(Int(self.altitudeBar.value + 1))
//        self.altitudeLbl.text = "\(self.altitudeBar.value)"
//    }
//
//    @IBAction func onAltitudeMinus(_ sender: Any) {
//        self.altitudeBar.value = Float(Int(self.altitudeBar.value - 1))
//        self.altitudeLbl.text = "\(self.altitudeBar.value)"
//    }
//
//
//    @IBAction func onHeadingChange(_ sender: Any) {
//        self.headingBar.value = Float(Int(self.headingBar.value))
//        self.headingLbl.text = "\(self.headingBar.value)°"
//    }
//
//    @IBAction func onHeadingPlusClick(_ sender: Any) {
//        self.headingBar.value = Float(Int(self.headingBar.value + 1))
//        self.headingLbl.text = "\(self.headingBar.value)"
//    }
//
//    @IBAction func onHeadingMinusClick(_ sender: Any) {
//        self.headingBar.value = Float(Int(self.headingBar.value - 1))
//        self.headingLbl.text = "\(self.headingBar.value)"
//    }
//
//    @IBAction func onWaypointRepeatChange(_ sender: Any) {
//        self.wayPointRepeatTimeBar.value = Float(Int(self.wayPointRepeatTimeBar.value))
//        self.wayPointRepeatTimeLbl.text = "\(self.wayPointRepeatTimeBar.value)"
//    }
//
//    @IBAction func onWaypointPlusClick(_ sender: Any) {
//        self.wayPointRepeatTimeBar.value = Float(Int(self.wayPointRepeatTimeBar.value + 1))
//        self.wayPointRepeatTimeLbl.text = "\(self.wayPointRepeatTimeBar.value)"
//    }
//
//    @IBAction func onWaypointRepeatMinusClick(_ sender: Any) {
//        self.wayPointRepeatTimeBar.value = Float(Int(self.wayPointRepeatTimeBar.value - 1))
//        self.wayPointRepeatTimeLbl.text = "\(self.wayPointRepeatTimeBar.value)"
//    }
//
//    @IBAction func onActiontimeoutChange(_ sender: Any) {
//        self.actionTimeoutBar.value = Float(Int(self.actionTimeoutBar.value))
//        self.actionTimoutLbl.text = "\(self.actionTimeoutBar.value)s"
//    }
//
//    @IBAction func onTimeoutActionPlusClick(_ sender: Any) {
//        self.actionTimeoutBar.value = Float(Int(self.actionTimeoutBar.value + 100))
//        self.actionTimoutLbl.text = "\(self.actionTimeoutBar.value)"
//    }
//
//    @IBAction func onTimeoutMinusClick(_ sender: Any) {
//        self.actionTimeoutBar.value = Float(Int(self.actionTimeoutBar.value - 100))
//        self.actionTimoutLbl.text = "\(self.actionTimeoutBar.value)"
//    }
//
//    @IBAction func onCornerRadiusChange(_ sender: Any) {
//        self.cornerRadiusBar.value = Float(self.cornerRadiusBar.value)
//        self.cornerRadiusLbl.text = "\(self.cornerRadiusBar.value)m"
//    }
//
//    @IBAction func onCornerRadiusPlusClick(_ sender: Any) {
//        self.cornerRadiusBar.value = Float(Int(self.cornerRadiusBar.value + 1))
//        self.cornerRadiusLbl.text = "\(self.cornerRadiusBar.value)"
//    }
//
//    @IBAction func onCornerRadiusMinusClick(_ sender: Any) {
//        self.cornerRadiusBar.value = Float(Int(self.cornerRadiusBar.value - 1))
//        self.cornerRadiusLbl.text = "\(self.cornerRadiusBar.value)"
//    }
//
//    @IBAction func gimbalPitchOnChange(_ sender: Any) {
//        self.gimbalPitchBar.value = Float(Int(self.gimbalPitchBar.value))
//        self.gimbalPicthLbl.text = "\(self.gimbalPitchBar.value)°"
//    }
//
//
//    @IBAction func poiHeightValueChange(_ sender: Any) {
//        self.poiBar.value = Float(Int(self.poiBar.value))
//        self.poiHeightLbl.text = "\(self.poiBar.value)m"
//    }
//
//    @IBAction func onGimbalPitchPlusClick(_ sender: Any) {
//        self.gimbalPitchBar.value = Float(Int(self.gimbalPitchBar.value + 1))
//        self.gimbalPicthLbl.text = "\(self.gimbalPitchBar.value)"
//    }
//
//
//    @IBAction func onGimbalPitchMinusClick(_ sender: Any) {
//        self.gimbalPitchBar.value = Float(Int(self.gimbalPitchBar.value - 1))
//        self.gimbalPicthLbl.text = "\(self.gimbalPitchBar.value)"
//    }
//
//    @IBAction func onPOIPlusClick(_ sender: Any) {
//        self.poiBar.value = Float(Int(self.poiBar.value + 1))
//        self.poiHeightLbl.text = "\(self.poiBar.value)m"
//    }
//
//
//    @IBAction func onPOIMinusClick(_ sender: Any) {
//        self.poiBar.value = Float(Int(self.poiBar.value - 1))
//        self.poiHeightLbl.text = "\(self.poiBar.value)m"
//    }
//
//    @IBAction func commandStartBtnClick(_ sender: Any) {
//        Environment.commandService.executeMissionCommand(.start)
//
//    }
//
//    @IBAction func commandPauseBtnClick(_ sender: Any) {
//        Environment.commandService.executeMissionCommand(.pause)
//    }
//
//    @IBAction func commandResumeBtnClick(_ sender: Any) {
//        Environment.commandService.executeMissionCommand(.resume)
//    }
//
//    @IBAction func commandGoHomeBtn(_ sender: Any) {
//        Environment.commandService.executeMissionCommand(.goHome)
//    }
//
//    @IBAction func commandStopBtnClick(_ sender: Any) {
//        Environment.commandService.executeMissionCommand(.stop)
//    }
//
//
//
//}
//
//// Private methods
//extension TimelineMissionViewController {
//    private func registerListeners() {
//        Environment.locationService.aircraftLocationListeners.append({ location in
//            self.showObject(self.aircraftAnnotation, location)
//        })
//        Environment.locationService.aircraftHeadingChanged = { heading in
//            if (heading != nil) {
//                self.aircraftAnnotation.heading = heading!
//            }
//        }
//        Environment.locationService.homeLocationListeners.append({ location in
//            self.showObject(self.homeAnnotation, location)
//        })
//
//    }
//
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
//
//    private func objectPresentOnMap(_ object: MovingObject) -> Bool {
//        return mapView.annotations.contains(where: { annotation in
//            return annotation as? MovingObject == object
//        })
//    }
//
//    private func showObject(_ object: MovingObject, _ location: CLLocation?) {
//        if location != nil {
//            object.coordinate = location!.coordinate
//            if !objectPresentOnMap(object) {
//                mapView.addAnnotation(object)
//            }
//        } else if objectPresentOnMap(object) {
//            mapView.removeAnnotation(object)
//        }
//    }
//
//    private func trackObject(_ object: MovingObject, _ enable: Bool) -> Bool {
//        if objectPresentOnMap(object) {
//            object.isTracked = enable
//            if enable {
//                focusOnCoordinate(object.coordinate)
//                object.coordinateChanged = { coordinate in
//                    self.focusOnCoordinate(coordinate)
//                }
//            } else {
//                object.coordinateChanged = nil
//            }
//            return true
//        } else {
//            return false
//        }
//    }
//
//    private func focusOnCoordinate(_ coordinate: CLLocationCoordinate2D) {
//        let distanceSpan: CLLocationDistance = 5
//        let mapCoordinates = MKCoordinateRegion(center: coordinate, latitudinalMeters: distanceSpan, longitudinalMeters: distanceSpan)
//        mapView.setRegion(mapCoordinates, animated: true)
//    }
//
//
//    private func movingObjectView(for movingObject: MovingObject, on mapView: MKMapView) -> MovingObjectView? {
//        let movingObjectView = mapView.dequeueReusableAnnotationView(withIdentifier: NSStringFromClass(MovingObject.self), for: movingObject) as? MovingObjectView
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
//}
//
//// Public methods
//extension TimelineMissionViewController {
//    func trackUser(_ enable: Bool) -> Bool {
//        let _ = trackObject(aircraftAnnotation, false)
//        return trackObject(userAnnotation, enable)
//    }
//
//    func trackAircraft(_ enable: Bool) -> Bool {
//        let _ = trackObject(userAnnotation, false)
//        return trackObject(aircraftAnnotation, enable)
//    }
//
//    func locateHome() {
//        if objectPresentOnMap(homeAnnotation) {
//            focusOnCoordinate(homeAnnotation.coordinate)
//        }
//    }
//}
//
//// Display annotations and renderers
//extension TimelineMissionViewController : MKMapViewDelegate {
//    internal func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        var image: UIImage!
//
//        var imageAnnotation: MovingObject? = nil
//        if annotation.isEqual(self.aircraftAnnotation) {
//            imageAnnotation = annotation as? MovingObject
//            image = #imageLiteral(resourceName: "placemarkAircraft")
//        } else if annotation.isEqual(self.homeAnnotation) {
//            imageAnnotation = annotation as? MovingObject
//            image = #imageLiteral(resourceName: "buttonLocatorHome")
//        }else if annotation.isEqual(self.userAnnotation){
//            image = #imageLiteral(resourceName: "placemarkUser")
//        }
//        else if(annotation is MKPointAnnotation){
//            let title = annotation.title!!
//            if title.contains("Waypoint") && pointOfInterest != nil{
//                let data = title.components(separatedBy: " - ")
//                let waypoint = data[1]
//
//                let currentLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
//                let pointOfInterestLocation = CLLocation(latitude: (pointOfInterest?.coordinate.latitude)!, longitude: (pointOfInterest?.coordinate.longitude)!)
//
//                let angle = ImageUtils.getBearingBetweenTwoPoints(point1: currentLocation, point2: pointOfInterestLocation)
//                let backgroundImage = UIImage(named: "paper_plane")?.rotateImage(radians: Float(angle))
//                let forGroundImage = ImageUtils.drawWayPointImage(waypoint: waypoint)
//                image = ImageUtils.drawWayPointWithPointOfInterest(backgroundImage: backgroundImage!, foregroundImage: forGroundImage)
//            }
//            else if(title.contains("Point of Interest"))
//            {
//                image = #imageLiteral(resourceName: "home_location")
//            }
//            else{
//                image = #imageLiteral(resourceName: "point")
//            }
//        }
//
//        if annotation is MKPointAnnotation{
//            let title = annotation.title ?? ""
//            if title != nil && title!.contains("Point of Interest"){
//                imageAnnotation = MovingObject(CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), 0.0, .point_of_interest)
//            }else{
//                imageAnnotation = MovingObject(CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude), 0.0, .draw_point)
//            }
//        }else{
//            imageAnnotation = annotation as? MovingObject
//        }
//
//        var annotationView = movingObjectView(for: imageAnnotation!, on: mapView)
//
//        if annotation is MKPointAnnotation{
//            annotationView?.isDraggable = true
//        }
//
//        if annotationView == nil {
//            annotationView = movingObjectView(for: imageAnnotation!, on: mapView)
//        }
//
//        annotationView?.image = image
//
//        if annotation.isEqual(self.aircraftAnnotation) {
//            if annotationView != nil {
//                self.aircraftAnnotationView = annotationView!
//            }
//        }
//
//        return annotationView
//    }
//
//    internal func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
//        for view in views {
//            if let movingObjectView = view as? MovingObjectView {
//                movingObjectView.addedToMapView()
//            }
//        }
//    }
//
//    internal func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
//        switch newState {
//            case .starting:
//                view.dragState = .dragging
//            case .ending, .canceling:
//                view.dragState = .none
//                self.mapView.removeAnnotations(points)
//                reDrawAnnotations()
//                connectPoints()
//            default:
//                break
//        }
//    }
//
//    internal func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//        if overlay is MKPolyline {
//            self.allOverLays.append(overlay)
//            let renderer = MKPolylineRenderer(overlay: overlay)
//            renderer.strokeColor = .orange
//            renderer.lineWidth = 1.5
//            return renderer
//        } else {
//            return MKOverlayRenderer()
//        }
//        //return MissionRenderer(overlay: overlay)
//    }
//}
//
//// Handle custom gestures
//extension TimelineMissionViewController : UIGestureRecognizerDelegate {
//    internal func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//
//
////    @objc private func handlePolygonDrag(sender: UIGestureRecognizer) {
////        let touchCoordinate = mapView.convert(sender.location(in: mapView), toCoordinateFrom: mapView)
////        if let polygon = self.missionPolygon {
////            let canDragPolygon = polygon.bodyContains(coordinate: touchCoordinate)
////            let canDragVertex = polygon.vertexContains(coordinate: touchCoordinate)
////
////            if !canDragVertex && !canDragPolygon {
////                enableMapInteraction(true)
////            } else if sender.state == .began {
////                enableMapInteraction(false)
////                polygon.computeOffsets(relativeTo: touchCoordinate)
////            } else if sender.state == .changed && canDragVertex {
////                polygon.moveVertex(following: touchCoordinate)
////            } else if sender.state == .changed && canDragPolygon {
////                polygon.movePolygon(following: touchCoordinate)
////            } else if sender.state == .ended {
////                enableMapInteraction(true)
////            }
////        } else {
////            enableMapInteraction(true)
////        }
////    }
//}
//
//// Handle user location and heading updates
//extension TimelineMissionViewController : CLLocationManagerDelegate {
//    internal func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        let newCoordinate = locations[0].coordinate
//        if (objectPresentOnMap(userAnnotation)) {
//            userAnnotation.coordinate = newCoordinate
//        } else {
//            userAnnotation = MovingObject(newCoordinate, 0.0, .user)
//            mapView.addAnnotation(userAnnotation)
//            focusOnCoordinate(userAnnotation.coordinate)
//        }
//
//    }
//
//    internal func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
//        if (objectPresentOnMap(userAnnotation)) {
//            userAnnotation.heading = newHeading.trueHeading
//        }
//    }
//}
//
//extension TimelineMissionViewController {
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
//}
//
////Extension for Telemetry View
//extension TimelineMissionViewController{
//
//    func registerTelemetryServices(){
//
//        Environment.telemetryService.registerListeners()
//        Environment.telemetryService.flightModeChanged = { modeString in
//            self.updateFlightMode(modeString)
//        }
//        Environment.telemetryService.gpsSignalStatusChanged = { signalStatus in
//            self.updateGpsSignalStatus(signalStatus)
//        }
//        Environment.telemetryService.gpsSatCountChanged = { satCount in
//            self.updateGpsSatCount(satCount)
//        }
//        Environment.telemetryService.linkSignalQualityChanged = { signalStrength in
//            self.updateLinkSignalStrength(signalStrength)
//        }
//        Environment.telemetryService.batteryChargeChanged = { batteryPercentage in
//            self.updateBettery(batteryPercentage)
//        }
//
//        Environment.telemetryService.horizontalVelocityChanged = { horizontalVelocity in
//            let value = horizontalVelocity != nil ? String(format: "%.1f", horizontalVelocity!) : nil
//            self.hsSpeedLabel.text = "\(value ?? "0.0") m/s"
//        }
//        Environment.telemetryService.verticalVelocityChanged = { verticalVelocity in
//            let value = verticalVelocity != nil ? String(format: "%.1f", Utils.trimToZeroAndInvert(verticalVelocity!)) : nil
//            self.vsSpeedLabel.text = "\(value ?? "0.0") m/s"
//        }
//        Environment.telemetryService.altitudeChanged = { altitude in
//            let value = altitude != nil ? String(altitude!) : nil
//            self.altitudeLabel.text = "\(value ?? "0.0") m"
//        }
//
//        Environment.locationService.aircraftLocationListeners.append({ location in
//            if location != nil && self.lastHomeLocation != nil {
//                let value = location!.distance(from: self.lastHomeLocation!)
//                self.distanceLabel.text = "\(String(format: "%.0f", value)) m"
//            } else {
//                self.distanceLabel.text = "N/A"
//            }
//        })
//
//        Environment.locationService.homeLocationListeners.append({ location in
//            self.lastHomeLocation = location
//        })
//
//    }
//
//    func updateFlightMode(_ modeString: String?) {
//        var txt = "N/A"
//        if(modeString != nil && modeString != ""){
//            txt = modeString!
//        }
//        self.flightModelLabel.text = txt
//    }
//
//    func updateGpsSignalStatus(_ signalStatus: UInt?) {
//        let defaultIndicator = UIImage(#imageLiteral(resourceName: "indicatorSignal0"))
//        if let status = signalStatus {
//            switch status {
//            case 0:
//                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal1")
//            case 1:
//                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal2")
//            case 2:
//                fallthrough
//            case 3:
//                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal3")
//            case 4:
//                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal4")
//            case 5:
//                gpsImageView.image = #imageLiteral(resourceName: "indicatorSignal5")
//            default:
//                gpsImageView.image = defaultIndicator
//            }
//        } else {
//            gpsImageView.image = defaultIndicator
//        }
//    }
//
//    func updateGpsSatCount(_ satCount: UInt?) {
//        var txt = "0"
//        if(satCount != nil){
//            txt = String(satCount!)
//        }
//        gpsSignalLabel.text = txt
//    }
//
//    func updateLinkSignalStrength(_ signalStrength: UInt?) {
//
//        let defaultIndicator = UIImage(#imageLiteral(resourceName: "indicatorSignal0"))
//        if let signalStrength = signalStrength {
//            if signalStrength > 0 && signalStrength <= 20 {
//                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal1")
//            } else if signalStrength > 20 && signalStrength <= 40 {
//                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal2")
//            } else if signalStrength > 40 && signalStrength <= 60 {
//                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal3")
//            } else if signalStrength > 60 && signalStrength <= 80 {
//                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal4")
//            } else if signalStrength > 80 && signalStrength <= 100 {
//                remoteSignalImage.image = #imageLiteral(resourceName: "indicatorSignal5")
//            }
//        } else {
//            remoteSignalImage.image = defaultIndicator
//        }
//
//    }
//
//    func updateBettery(_ batteryPercentage: UInt?) {
//        if let batteryPercentage = batteryPercentage {
//            betteryLabel.text = String(batteryPercentage) + "%"
//            if batteryPercentage > 0 && batteryPercentage <= 30 {
//                betteryLabel.textColor = Colors.error
//                betteryImageView.image = #imageLiteral(resourceName: "indicatorBattery1")
//            } else if batteryPercentage > 30 && batteryPercentage <= 60 {
//                betteryLabel.textColor = Colors.warning
//                betteryImageView.image = #imageLiteral(resourceName: "indicatorBattery2")
//            } else if batteryPercentage > 60 && batteryPercentage <= 80 {
//                betteryLabel.textColor = Colors.success
//                betteryImageView.image = #imageLiteral(resourceName: "indicatorBattery2")
//            } else {
//                betteryLabel.textColor = Colors.success
//                betteryImageView.image = #imageLiteral(resourceName: "indicatorBattery3")
//            }
//        } else {
//            betteryLabel.text = "0.0%"
//            betteryLabel.textColor = UIColor.white
//            betteryImageView.image = #imageLiteral(resourceName: "indicatorBattery1")
//        }
//    }
//}
//
//
////Mission Setting Extension
//extension TimelineMissionViewController{
//
//    func setUpMissionViewValues(){
//        self.maxFlightSpeedBar.minimumValue = 2
//        self.maxFlightSpeedBar.maximumValue = 15
//
//        self.poiBar.minimumValue = 1
//        self.poiBar.maximumValue = 20
//
//        self.autoSpeedBar.minimumValue = 2
//        self.autoSpeedBar.maximumValue = 15
//
//        self.repeatTimesBar.minimumValue = 1
//        self.repeatTimesBar.maximumValue = 5
//
//        self.finishActionDropDown.optionArray = finishActionsTxts
//        self.headingModeDropdown.optionArray = headModesTxts
//
//        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissHeadingKeyboard))
//            tap.cancelsTouchesInView = false
//        self.headingModeDropdown.addGestureRecognizer(tap)
//
//        let tap1: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissActionsKeyboard))
//            tap1.cancelsTouchesInView = false
//        self.finishActionDropDown.addGestureRecognizer(tap1)
//
//    }
//
//    @objc func dismissHeadingKeyboard() {
//        view.endEditing(true)
//        self.headingModeDropdown.showList()
//    }
//
//    @objc func dismissActionsKeyboard() {
//        view.endEditing(true)
//        self.finishActionDropDown.showList()
//    }
//
//    func setUpMissionValues(){
//        self.maxFlightSpeedBar.value = Float(missionSetting.maxFlightSpeed)
//        self.maxFlightSpeedLbl.text = "\(Float(missionSetting.maxFlightSpeed)) m/s"
//
//        self.poiBar.value = Float(missionSetting.poiHeight)
//        self.poiHeightLbl.text = "\(Float(missionSetting.poiHeight)) m"
//
//        self.autoSpeedBar.value = Float(missionSetting.autoFlightSpeed)
//        self.autoSpeedLbl.text = "\(Float(missionSetting.autoFlightSpeed)) m/s"
//
//        self.repeatTimesBar.value = Float(missionSetting.repeatTimes)
//        self.repeatTimesLbl.text = "\(Float(missionSetting.repeatTimes))"
//
//        if(missionSetting.rotateGimblePitch){
//            self.rotateGimbalBar.selectedSegmentIndex = 1
//        }else{
//            self.rotateGimbalBar.selectedSegmentIndex = 0
//        }
//
//        if(missionSetting.exitMissionOnRCSignalLost){
//            self.connectionLoseBar.selectedSegmentIndex = 1
//        }else{
//            self.connectionLoseBar.selectedSegmentIndex = 0
//        }
//
//        if(missionSetting.flightPathMode == .normal){
//            self.waypointPathBar.selectedSegmentIndex = 0
//        }else{
//            self.waypointPathBar.selectedSegmentIndex = 1
//        }
//
//        if(missionSetting.gotoFirstWaypointMode == .safely){
//            self.goToBar.selectedSegmentIndex = 0
//        }else{
//            self.goToBar.selectedSegmentIndex = 1
//        }
//
//        let headingModeIndex = self.headingMode.firstIndex(of: missionSetting.headingMode)
//        let finishActionIndex = self.finishActions.firstIndex(of: missionSetting.finishAction)
//        self.headingModeDropdown.selectedIndex = headingModeIndex
//        self.finishActionDropDown.selectedIndex = finishActionIndex
//        self.headingModeDropdown.text = self.headModesTxts[headingModeIndex!]
//        self.finishActionDropDown.text = self.finishActionsTxts[finishActionIndex!]
//
//    }
//
//
//    func setUpWaypointSettingViewValues(){
//
//        self.headingBar.minimumValue = -180
//        self.headingBar.maximumValue = 180
//
//        self.gimbalPitchBar.minimumValue = -90
//        self.gimbalPitchBar.maximumValue = 30
//
//        self.cornerRadiusBar.minimumValue = 0.2
//        self.cornerRadiusBar.maximumValue = 1000
//
//        self.actionTimeoutBar.minimumValue = 0
//        self.actionTimeoutBar.maximumValue = 999
//
//        self.wayPointRepeatTimeBar.minimumValue = 0
//        self.wayPointRepeatTimeBar.maximumValue = Float(DJIMaxActionRepeatTimes)
//
//        self.altitudeBar.minimumValue = 2
//        self.altitudeBar.maximumValue = 100
//    }
//
//    func setUpWaypointValues(){
//
//        var setting = waypointsList[selectedWayPoint]
//
//        if(isSeprateWaypointSetting == false){
//            if(allWaypointSetting == nil){
//                allWaypointSetting = WaypointSetting()
//            }
//            setting = allWaypointSetting!
//            self.wayPointLabl.text = "All Waypoints"
//        }else{
//            self.wayPointLabl.text = setting.name
//            let loc = CLLocationCoordinate2D(latitude: setting.latittude!, longitude: setting.longitude!)
//            let region = MKCoordinateRegion(center: loc, latitudinalMeters: 50, longitudinalMeters: 50)
//
//            self.mapView.setRegion(region, animated: true)
//
//        }
//
//        self.headingBar.value = Float(setting.heading)
//        self.gimbalPitchBar.value = Float(setting.gimbalPitch)
//        self.cornerRadiusBar.value = Float(setting.cornerRadiusInMeters)
//        self.actionTimeoutBar.value = Float(setting.actionTimeoutInSeconds)
//        self.wayPointRepeatTimeBar.value = Float(setting.actionRepeatTimes)
//        self.altitudeBar.value = Float(setting.altitude)
//
//        self.headingLbl.text = "\(self.headingBar.value)°"
//        self.gimbalPicthLbl.text = "\(self.gimbalPitchBar.value)°"
//        self.cornerRadiusLbl.text = "\(self.cornerRadiusBar.value)m"
//        self.actionTimoutLbl.text = "\(self.actionTimeoutBar.value)s"
//        self.wayPointRepeatTimeLbl.text = "\(self.wayPointRepeatTimeBar.value)"
//        self.altitudeLbl.text = "\(self.altitudeBar.value) m"
//
//        if setting.turnMode == .clockwise{
//            self.turnModeBar.selectedSegmentIndex = 0
//        }
//        else{
//            self.turnModeBar.selectedSegmentIndex = 1
//        }
//    }
//
//
//}
//
////Command View Controller Extension to Fly the Mission
//extension TimelineMissionViewController{
//    private func registerCommandListeners() {
//        Environment.commandService.commandResponseListeners.append({ id, success in
//            print("Comand Service commandResponseListeners \(success) \(id)")
//            if success {
//                switch id {
//                    case .stop:
//                        Environment.missionStateManager.state = .none
//                    default:
//                        break
//                }
//            }
//        })
//        Environment.commandService.missionFinished = { success in
//            print("Comand Service missionFinished \(success)")
//            Environment.missionStateManager.state = .none
//        }
//        Environment.missionStateManager.stateListeners.append({ _, newState in
//            print("Comand Service stateListeners \(newState)")
//            if newState != .none && newState != .editing {
//                self.setControls(for: newState)
//                self.toggleShowView(show: true, delay: Animations.defaultDelay)
//            } else {
//                self.toggleShowView(show: false, delay: 0)
//            }
//        })
//    }
//
//    func setControls(for state: MissionState) {
//        switch state {
//            case .uploaded:
//                self.commandStartBtn.isHidden = false
//                self.commandPauseBtn.isHidden = true
//                self.commandResumeBtn.isHidden = true
//                self.commandStopBtn.isHidden = false
//            case .paused:
//                self.commandStartBtn.isHidden = true
//                self.commandPauseBtn.isHidden = true
//                self.commandResumeBtn.isHidden = false
//                self.commandStopBtn.isHidden = false
//            case .running:
//                self.commandStartBtn.isHidden = true
//                self.commandPauseBtn.isHidden = false
//                self.commandResumeBtn.isHidden = true
//                self.commandStopBtn.isHidden = false
//            default:
//                break
//        }
//    }
//
//    func toggleShow(_ show: Bool) {
//        self.commandView.layer.opacity = show ? 1 : 0
//    }
//
//
//    private func toggleShowView(show: Bool, delay: TimeInterval) {
//        if show {
//            self.commandView.isHidden = false
//            self.takeOffLandBtn.isHidden = true
//        }
//        UIView.animate(
//            withDuration: Animations.defaultDuration,
//            delay: delay,
//            options: [],
//            animations: {
//                self.toggleShow(show)
//            },
//            completion: { _ in
//                if !show {
//                    self.commandView.isHidden = true
//                    self.takeOffLandBtn.isHidden = false
//                }
//            }
//        )
//    }
//}
//
////Console View Controller
//extension TimelineMissionViewController{
//    private func registerConsoleListeners() {
//        Environment.commandService.logConsole = { message, type in
//            self.logConsole(message, type)
//        }
//        Environment.mapViewController.logConsole = { message, type in
//            self.logConsole(message, type)
//        }
//        Environment.missionViewController.logConsole = { message, type in
//            self.logConsole(message, type)
//        }
//        Environment.simulatorService.logConsole = { message, type in
//            self.logConsole(message, type)
//        }
//        Environment.connectionService.logConsole = { message, type in
//            self.logConsole(message, type)
//        }
//        Environment.missionStorage.logConsole = { message, type in
//            self.logConsole(message, type)
//        }
//        Environment.missionStateManager.logConsole = {message, type in
//            self.logConsole(message, type)
//        }
//    }
//
//    func currentDateString() -> String {
//        let date = Date()
//        let formatter = DateFormatter()
//        formatter.timeStyle = .medium
//        formatter.dateStyle = .none
//        return formatter.string(from: date)
//    }
//
//    private func logConsole(_ message: String, _ type: OSLogType) {
//        os_log("%@", type: type, message)
//        self.assistantLbl.text = message
//    }
//}
