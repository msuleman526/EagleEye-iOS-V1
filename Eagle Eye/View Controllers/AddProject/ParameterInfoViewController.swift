//
//  ParameterInfoViewController.swift
//  Eagle Eye
//
//  Created by Mohsin Sherin on 03/05/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class ParameterInfoViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var backBtn: UIImageView!
    @IBOutlet weak var googleMapView: GMSMapView!
    var houseLat: Double = 37.4669494
    var houseLng: Double = -122.2142187
    var streetAddress: String = "23 Oakwood Blvd, Atherton ,CA 94027, USA"
    
    
    
    
    
    @IBOutlet weak var completeBtn: UIButton!
    
    var locationManager = CLLocationManager()
    var polygon: GMSPolygon!
    var polygonPath: GMSMutablePath!
    var markers: [GMSMarker] = []
    var waypointMarkers: [GMSMarker] = []
    
    @IBOutlet weak var innerPointsField: UITextField!
    @IBOutlet weak var outerPointsField: UITextField!
    @IBOutlet weak var outerRadiusField: UITextField!
    @IBOutlet weak var horizontalScanRadiusLbl: UILabel!
    @IBOutlet weak var innerRadiusField: UITextField!
    
    @IBOutlet weak var horizontalPointsLbl: UILabel!
    @IBOutlet weak var innerPointsLbl: UILabel!
    @IBOutlet weak var outerPointsLbl: UILabel!
    
    @IBOutlet weak var innerRadiusLbl: UILabel!
    @IBOutlet weak var outerRadiusLbl: UILabel!
    
    //let animationView = LottieAnimationView()
    
    @IBOutlet weak var horizontalScanPointsEdt: UITextField!
    @IBOutlet weak var horizontalScanRadiusEdt: UITextField!
    
    @IBOutlet weak var drawSwitch: UISwitch!
    var isDrawing: Bool = false
    
    var project: Project? = nil
    var alert: UIAlertController?
    
    
    @IBOutlet weak var fullScreenBtn: UIButton!
    @IBOutlet weak var halfScreenBtn: UIButton!
    @IBOutlet weak var showMapBtn: UIButton!
    @IBOutlet weak var hideMapBtn: UIButton!
    
    @IBOutlet weak var deleteBoundaryBtn: UIButton!
    
    @IBOutlet weak var mapArrowBtn: UIButton!
    @IBOutlet weak var googleMapBox: UIView!
    @IBOutlet weak var detailedView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(project!.lat != nil && project!.lat != ""){
            if let latitude = Double(project!.lat!) {
                houseLat = latitude
            }
            if let longitude = Double(project!.lng!) {
                houseLng = longitude
            }
        }
        streetAddress = project!.address ?? ""
        
        self.completeBtn.isHidden = true
        
        backBtn.isUserInteractionEnabled = true
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(backBtnClick))
        backBtn.addGestureRecognizer(tapGesture1)
        
        self.outerRadiusLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Outer Circle Radius*")
        self.innerRadiusLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Inner Circle Radius*")
        self.horizontalScanRadiusLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Horizontal Circle Radius*")
        self.outerPointsLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Outer Circle Waypoints*")
        self.innerPointsLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Inner Circle Waypoints*")
        self.horizontalPointsLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Horizontal Circle Waypoints*")
        
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        //self.setUpAnimationForPolygonDrawing()
        setUpViews()
        initGoogleMaps()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        self.updateValues()
    
    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func halfScreenBtn(_ sender: Any) {
        self.halfScreen()
    }
    
    @IBAction func halfScreenArrowClick(_ sender: Any) {
        self.halfScreen()
    }
    
    @IBAction func deleteBoundaryBtnClick(_ sender: Any) {
        self.clearHouseBoundary()
        if(waypointMarkers.count > 0){
            for waypointMarker in waypointMarkers {
                waypointMarker.map = nil
            }
            waypointMarkers.removeAll()
            waypointMarkers = []
        }
        self.drawSwitch.isOn = false
        self.deleteBoundaryBtn.isHidden = true
    }
    
    func halfScreen(){
        self.showMapBtn.isHidden = true
        self.hideMapBtn.isHidden = false
        self.detailedView.isHidden = false
        self.mapArrowBtn.isHidden = true
        self.googleMapBox.isHidden = false
        self.halfScreenBtn.isHidden = true
        self.fullScreenBtn.isHidden = false
    }
    
    @IBAction func fullScreenBtn(_ sender: Any) {
        self.showMapBtn.isHidden = true
        self.hideMapBtn.isHidden = false
        self.detailedView.isHidden = true
        self.mapArrowBtn.isHidden = false
        self.googleMapBox.isHidden = false
        self.halfScreenBtn.isHidden = false
        self.fullScreenBtn.isHidden = true
    }
    
    @IBAction func showMap(_ sender: Any) {
        self.showMapBtn.isHidden = true
        self.hideMapBtn.isHidden = false
        self.mapArrowBtn.isHidden = true
        self.detailedView.isHidden = false
        self.googleMapBox.isHidden = false
    }
    
    @IBAction func hideMap(_ sender: Any) {
        self.showMapBtn.isHidden = false
        self.hideMapBtn.isHidden = true
        self.mapArrowBtn.isHidden = true
        self.detailedView.isHidden = false
        self.googleMapBox.isHidden = true
    }
    
    func setUpViews(){
        self.drawSwitch.isOn = false
        self.outerPointsField.delegate = self
        self.innerPointsField.delegate = self
        self.outerRadiusField.delegate = self
        self.innerRadiusField.delegate = self
        self.horizontalScanPointsEdt.delegate = self
        self.horizontalScanRadiusEdt.delegate = self
        
        outerPointsField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        innerRadiusField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        outerRadiusField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        innerPointsField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        horizontalScanRadiusEdt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        horizontalScanPointsEdt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    }
    
    @IBAction func onDrawingEnabled(_ sender: Any) {
        if(self.drawSwitch.isOn){
            self.isDrawing = true
            self.clearHouseBoundary()
            self.completeBtn.isHidden = false
            if(waypointMarkers.count > 0){
                for waypointMarker in waypointMarkers {
                    waypointMarker.map = nil
                }
                waypointMarkers.removeAll()
                waypointMarkers = []
            }
        }else{
            self.isDrawing = false
            self.completeBtn.isHidden = true
        }
    }
    
    func clearHouseBoundary(){
        for marker in markers{
            marker.map = nil
        }
        markers.removeAll()
        markers = []
        if(polygonPath != nil){
            self.polygonPath = nil
            self.polygon.map = nil
            self.polygon = nil
        }
    }
    
    func updateValues(){
        let outerRadius = self.outerRadiusField.text
        let innerRadius = self.innerRadiusField.text
        let horizontleRadius = self.horizontalScanRadiusEdt.text
        
        let feet1 = Double(outerRadius!)!*3.28084
        let feet2 = Double(innerRadius!)!*3.28084
        let feet3 = Double(horizontleRadius!)!*3.28084
        
        self.outerRadiusLbl.attributedText = Utils.getRequiredFieldLabelText(labelText:"Outer Path Radius (\(Int(feet1)) Feet)*")
        self.innerRadiusLbl.attributedText = Utils.getRequiredFieldLabelText(labelText:"Inner Path Radius (\(Int(feet2)) Feet)*")
        self.horizontalScanRadiusLbl.attributedText = Utils.getRequiredFieldLabelText(labelText:"Horizontal Scan Radius (\(Int(feet3)) Feet)*")
        
    }
    
    @IBAction func completeBtnClick(_ sender: Any) {
        if(polygonPath.count() > 3){
            self.isDrawing = false
            self.completeBtn.isHidden = true
            self.setUpHouseBoundaryAndWaypoints(type: "New")
        }else{
            Toast.show(message: "Please draw atleast 4 points of house boundary", controller: self)
        }
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let val = textField.text
        if(val != nil && val != "" && Double(val!)! > 0){
            let feet = Double(val!)!*3.28084
            if(textField == outerRadiusField){
                self.outerRadiusLbl.text = "Outer Path Radius (\(Int(feet)) Feet)"
            }
            else if(textField == innerRadiusField){
                self.innerRadiusLbl.text = "Inner Path Radius (\(Int(feet)) Feet)"
            }
            else if(textField == horizontalScanRadiusEdt){
                self.horizontalScanRadiusLbl.text = "Horizontal Scan Radius (\(Int(feet)) Feet)"
            }
            drawParamters()
        }
    }
    
//    func setUpAnimationForPolygonDrawing()
//    {
//        self.animationView.animation = LottieAnimation.named("animation")
//        self.animationView.contentMode = .scaleAspectFit
//        self.animationView.frame = self.googleMapView.bounds
//        self.animationView.backgroundColor = UIColor.clear
//        self.animationView.loopMode = .loop
//    }
//    
//    func startAnimation()
//    {
//        self.animationView.play()
//        self.googleMapView.addSubview(self.animationView)
//    }
//    
//    func stopAnimation()
//    {
//        self.animationView.removeFromSuperview()
//        animationView.stop()
//        
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
    
    func initGoogleMaps() {
        var camera = GMSCameraPosition.camera(withLatitude: houseLat, longitude: houseLng, zoom: 19.0)
        self.googleMapView.camera = camera
        self.googleMapView.delegate = self
        self.googleMapView.mapType = .hybrid
        self.googleMapView.isMyLocationEnabled = true
    
        
        let marker=GMSMarker()
        marker.icon = UIImage(named: "home_location")
        marker.position = CLLocationCoordinate2D(latitude: houseLat, longitude: houseLng)
        marker.title = "Current Address"
        marker.snippet = "\(streetAddress)"
        marker.map = googleMapView
        
        camera = GMSCameraPosition.camera(withLatitude: houseLat, longitude: houseLng, zoom: 19.0)
        self.googleMapView.camera = camera
        
        self.setUpHouseBoundaryAndWaypoints(type: "Old")
        
    }
    
    func setUpHouseBoundaryAndWaypoints(type: String){
        if(project!.house_boundary != nil && project!.house_boundary != "" && project!.house_boundary != "[]" && project != nil && project!.flight_path != nil && project!.flight_path != "" && project!.flight_path != "[]"){
            let jsonData2 = project!.flight_setting!.data(using: .utf8)!
            let decoder2 = JSONDecoder()
            let flightSetting = try! decoder2.decode(ProjectSetting.self, from: jsonData2)
            
            self.outerPointsField.text = "\(flightSetting.circleOnePoints ?? 50)"
            self.innerPointsField.text = "\(flightSetting.circleTwoPoints ?? 30)"
            self.outerRadiusField.text = "\(flightSetting.circleOneRadius ?? 30)"
            self.innerRadiusField.text = "\(flightSetting.circleTwoRadius ?? 20)"
            self.horizontalScanPointsEdt.text = "\(flightSetting.horizontalScanPoints ?? 15)"
            self.horizontalScanRadiusEdt.text = "\(flightSetting.horizontalScanRadius ?? 10)"
            
            let jsonData = project!.flight_path!.data(using: .utf8)!
            let decoder = JSONDecoder()
            let waypointsList = try! decoder.decode([WaypointAddress].self, from: jsonData)
            
            let count = waypointsList.count
            let lastWaypoint = waypointsList[count-1]
            
            if houseLat == lastWaypoint.lat! && houseLng == lastWaypoint.lng && type == "Old"{
                for i in (0..<count){
                    let waypoint = Int(i) + 1
                    let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: waypointsList[i].lat!, longitude: waypointsList[i].lng!))
                    marker.icon = ImageUtils.drawWayPointImage(waypoint: "\(waypoint)")
                    marker.map = self.googleMapView
                    self.waypointMarkers.append(marker)
                }
                
                let jsonData1 = project!.house_boundary!.data(using: .utf8)!
                let decoder1 = JSONDecoder()
                let houseBounday = try! decoder1.decode([WaypointAddress].self, from: jsonData1)
                
                polygonPath = GMSMutablePath()
                polygon = GMSPolygon(path: polygonPath)
                polygon.strokeWidth = 1.5
                polygon.fillColor = UIColor.green.withAlphaComponent(0.3)
                polygon.strokeColor = .green
                polygon.isTappable = true
                polygon.map = self.googleMapView
                
                for i in (0..<houseBounday.count){
                    let coordinate = CLLocationCoordinate2D(latitude: houseBounday[i].lat!, longitude: houseBounday[i].lng!)
                    let marker = GMSMarker(position: coordinate)
                    marker.icon = UIImage(named: "rec")
                    marker.isDraggable = true
                    marker.map = self.googleMapView
                    markers.append(marker)
                    polygonPath.add(coordinate)
                    polygon.path = polygonPath
                }
                self.deleteBoundaryBtn.isHidden = false
            }else{
                drawParamters()
            }
        }else{
            drawParamters()
        }
    }
    
    func drawParamters(){
        if(polygonPath != nil && polygonPath.count() > 3){
            if(waypointMarkers.count > 0){
                for waypointMarker in waypointMarkers {
                    waypointMarker.map = nil
                }
                waypointMarkers.removeAll()
                waypointMarkers = []
            }
            
            let outerRadius = Double(self.outerRadiusField.text!)
            let innerRadius =  Double(self.innerRadiusField.text!)
            let outerPoints =  Double(self.outerPointsField.text!)
            let innerPoints =  Double(self.innerPointsField.text!)
            let horizontalScanRadius = Double(self.horizontalScanRadiusEdt.text!)
            let horizontalScanPoints = Double(self.horizontalScanPointsEdt.text!)
            
            let outCirlePoints = Utils.getCirclePoints(centerLat: houseLat, centerLng: houseLng, radius: Int(outerRadius!), numPoints: Int(outerPoints!))
            
            let inCirlePoints = Utils.getCirclePoints(centerLat: houseLat, centerLng: houseLng, radius: Int(innerRadius!), numPoints: Int(innerPoints!))
            
            var horizontalPoints = Utils.getCirclePoints(centerLat: houseLat, centerLng: houseLng, radius: Int(horizontalScanRadius!), numPoints: Int(horizontalScanPoints!))
            
            var allPoints = outCirlePoints + inCirlePoints + horizontalPoints
            allPoints.append(CLLocationCoordinate2D(latitude: houseLat, longitude: houseLng))
            
            for i in (0..<allPoints.count){
                let waypoint = Int(i) + 1
                let marker = GMSMarker(position: allPoints[i])
                marker.icon = ImageUtils.drawWayPointImage(waypoint: "\(waypoint)")
                marker.map = self.googleMapView
                self.waypointMarkers.append(marker)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        
        if(isDrawing){
            let marker = GMSMarker(position: coordinate)
            marker.icon = UIImage(named: "rec")
            marker.map = mapView
            marker.isDraggable = true
            markers.append(marker)
            
            if polygon != nil{
                polygonPath.add(coordinate)
                polygon.path = polygonPath
                
            } else {
                self.deleteBoundaryBtn.isHidden = false
                polygonPath = GMSMutablePath()
                polygonPath.add(coordinate)
                polygon = GMSPolygon(path: polygonPath)
                polygon.strokeWidth = 1.5
                
                polygon.fillColor = UIColor.green.withAlphaComponent(0.3)
                polygon.strokeColor = .green
                polygon.isTappable = true
                polygon.map = mapView
            }
            
        }
        
    }

    @IBAction func onSaveAndNextClick(_ sender: Any) {
        let circleOneRadius = Int(self.outerRadiusField.text!)
        let circleTwoRadius = Int(self.innerRadiusField.text!)
        let circleOnePoints = Int(self.outerPointsField.text!)
        let circleTwoPoints = Int(self.innerPointsField.text!)
        let horizontalScanRadius = Int(self.horizontalScanRadiusEdt.text!)
        let horizontalScanPoints = Int(self.horizontalScanPointsEdt.text!)
        
        let difference = circleOneRadius!-circleTwoRadius!
        let difference1 = circleTwoRadius!-horizontalScanRadius!

        if(horizontalScanRadius! < 6){
            Toast.show(message: "Horizontal Scan radius must be greater then 6 meters", controller: self)
        }else if(horizontalScanPoints! < 8){
            Toast.show(message: "Horizontal Scan points must be greater then 8", controller: self)
        }else if(circleOneRadius! < 15){
            Toast.show(message: "Outer circle radius must be greater then 15 meters", controller: self)
        }else if(circleTwoRadius! < 8){
            Toast.show(message: "Inner circle radius must be greater then 8 meters", controller: self)
        }else if(circleTwoRadius! > circleOneRadius!){
            Toast.show(message: "Outer cirle radius must be greater then inner circle radius", controller: self)
        }else if(difference < 7){
            Toast.show(message: "Atleast 7 meter difference in both circle radius", controller: self)
        }else if(difference1 < 2){
            Toast.show(message: "Atleast 2 meter difference in both inner and horzontal scan radius.", controller: self)
        }else if(circleOnePoints! < 25){
            Toast.show(message: "Outer cirle waypoints must be greater then 30", controller: self)
        }else if(circleTwoPoints! < 15){
            Toast.show(message: "Inner cirle waypoints must be greater then 20", controller: self)
        }else{
            
            let flightSetting = ProjectSetting(circleOneRadius: circleOneRadius!, circleTwoRadius: circleTwoRadius!, circleOnePoints: circleOnePoints!, circleTwoPoints: circleTwoPoints!, horizontalScanRadius: horizontalScanRadius!, horizontalScanPoints: horizontalScanPoints!)
            
            var flightPath:[WaypointAddress] = []
            for i in (0..<self.waypointMarkers.count){
                flightPath.append(WaypointAddress(lat: self.waypointMarkers[i].position.latitude, lng: self.waypointMarkers[i].position.longitude))
            }
            
            var houseBoundat:[WaypointAddress] = []
            for i in (0..<self.markers.count){
                houseBoundat.append(WaypointAddress(lat: self.markers[i].position.latitude, lng: self.markers[i].position.longitude))
            }
            
            if(flightPath.count < 40){
                Toast.show(message: "To less waypoints", controller: self)
            }else if(houseBoundat.count < 4){
                Toast.show(message: "Please draw proper house boundary", controller: self)
            }else{
                
                var flight_setting = ""
                var flight_path = ""
                var house_boundary = ""
                
                let encoder = JSONEncoder()
                encoder.outputFormatting = .prettyPrinted
                
                do {
                    let data = try encoder.encode(flightSetting)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        flight_setting = jsonString
                    }else{
                        Toast.show(message: "Issue in Flight Setting.", controller: self)
                        return
                    }
                } catch {
                    Toast.show(message: "Issue in Flight Setting", controller: self)
                    return
                }
                
                do {
                    let data = try encoder.encode(flightPath)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        flight_path = jsonString
                    }else{
                        Toast.show(message: "Issue in Flight Path.", controller: self)
                        return
                    }
                } catch {
                    Toast.show(message: "Issue in Flight Path", controller: self)
                    return
                }
                
                do {
                    let data = try encoder.encode(houseBoundat)
                    if let jsonString = String(data: data, encoding: .utf8) {
                        house_boundary = jsonString
                    }else{
                        Toast.show(message: "Issue in House Boundary.", controller: self)
                        return
                    }
                } catch {
                    Toast.show(message: "Issue in House Boundary", controller: self)
                    return
                }
                
                callUpdateProjectApi(flightSetting: flight_setting, flightPath: flight_path, houseBoundat: house_boundary)
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        if let index = markers.firstIndex(of: marker) {
            polygonPath.replaceCoordinate(at: UInt(index), with: marker.position)
            polygon.path = polygonPath
        }
    }
    
    func callUpdateProjectApi(flightSetting: String, flightPath: String, houseBoundat: String){
        
        alert = UIAlertController(title: "Saving Project", message: "Please wait project is update...", preferredStyle: .alert)
        self.present(self.alert!, animated: true, completion: nil)
        
        let headers = [
            "Authorization": "Bearer \(SessionUtils.getUserToken())"
        ]
        
        let parameters: [String: Any] = [
            "flight_path": flightPath,
            "flight_setting": flightSetting,
            "house_boundary": houseBoundat,
        ]
        
        let resourceString = "\(Constants.API_LINK)api/project/\(String(describing: project!.id ?? 0))";
        
        Alamofire.request(resourceString, method: .post, parameters: parameters, headers: headers).responseJSON(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                print(value)
                if let httpURLResponse = response.response{
                    let response_code = httpURLResponse.statusCode;
                    if response_code == 200 {
                        self.alert?.dismiss(animated: false, completion: nil)
                        do{
                            let json = JSON(value)
                            let str = String(describing: json);
                            let jsonData = str.data(using: .utf8)
                            let decoder = JSONDecoder();
                            let res = try decoder.decode(UpdateProjectResponse.self, from: jsonData!)
                            Toast.show(message: "Project Info updated", controller: self)
                            self.dismiss(animated: true, completion: {
                                self.goToNextPage(project: res.project!)
                            })
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }else{
                        Toast.show(message: "No Internet Connection/Server Issue", controller: self)
                    }
                }
            case .failure(let error):
                print(error)
                self.alert?.dismiss(animated: false, completion: nil)
                Toast.show(message: "There is Some Server Issue.", controller: self)
                
            }
            
        })
        
    }
    
    
    func goToNextPage(project: Project){
    
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "ObstableInfo") as! ObstacleViewController
        nextVC.project = project
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
