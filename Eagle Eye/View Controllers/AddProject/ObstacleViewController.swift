//
//  ObstacleViewController.swift
//  Eagle Eye
//
//  Created by Mohsin Sherin on 05/05/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit
import GoogleMaps
import Alamofire
import SwiftyJSON

class ObstacleViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var mapView: UIView!
    
    @IBOutlet weak var drawingBtnsView: UIStackView!
    @IBOutlet weak var drawObstableSwift: UISwitch!
    @IBOutlet weak var mustHighField: UITextField!
    @IBOutlet weak var obstacleHeightField: UITextField!
    @IBOutlet weak var heightOfHouseField: UITextField!
    @IBOutlet weak var googleMapView: GMSMapView!
    
    var houseLat: Double = 37.4669494
    var houseLng: Double = -122.2142187
    var streetAddress: String = "23 Oakwood Blvd, Atherton ,CA 94027, USA"
    
    @IBOutlet weak var closeBtn: UIButton!
    var polygonDrawingCompleted: Bool = true
    var locationManager = CLLocationManager()
    var polygons: [GMSPolygon] = []
    var polygonPaths: [GMSMutablePath] = []
    var markers: [[GMSMarker]] = []
    var waypointMarkers: [GMSMarker] = []
    
    @IBOutlet weak var mustLbl: UILabel!
    @IBOutlet weak var obstacleLbl: UILabel!
    var project: Project? = nil
    var alert: UIAlertController?
    
    @IBOutlet weak var heightLbl: UILabel!
    @IBOutlet weak var backBtn: UIImageView!
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
        
        
        
        backBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backBtnClick))
        backBtn.addGestureRecognizer(tapGesture)
        
        
        streetAddress = project!.address ?? ""
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        setUpViews()
        initGoogleMaps()
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture1)
        
        self.polygonDrawingCompleted = true
        self.drawObstableSwift.isOn = false
        self.drawingBtnsView.isHidden = true
        
        self.heightLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Height of House (Feet)*")
        self.obstacleLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "How high must the drone fly to avoid obstacle? (Feet)*")
        self.mustLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "What is the highest you can fly in the airspace? (Feet)*")
    }
    
    @objc func backBtnClick() {
        print("Working")
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func setUpViews(){
        self.drawingBtnsView.isHidden = true
        self.drawObstableSwift.isOn = false
        self.mustHighField.delegate = self
        self.obstacleHeightField.delegate = self
        self.heightOfHouseField.delegate = self
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
    
    @IBAction func fullScreenClick(_ sender: Any) {
        self.detailedView.isHidden = true
        self.closeBtn.isHidden = false
    }
    
    @IBAction func halfScreenClick(_ sender: Any) {
        self.detailedView.isHidden = false
        self.closeBtn.isHidden = true
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    
    func initGoogleMaps(){
        
        let camera = GMSCameraPosition.camera(withLatitude: houseLat, longitude: houseLng, zoom: 19.0)
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
        
        if(project != nil && project!.flight_path != nil && project!.flight_path != ""){
            
            let jsonData = project!.flight_path!.data(using: .utf8)!
            let decoder = JSONDecoder()
            let waypointsList = try! decoder.decode([WaypointAddress].self, from: jsonData)
            for i in (0..<waypointsList.count){
                let waypoint = Int(i) + 1
                let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: waypointsList[i].lat!, longitude: waypointsList[i].lng!))
                marker.icon = ImageUtils.drawWayPointImage(waypoint: "\(waypoint)")
                marker.map = self.googleMapView
                self.waypointMarkers.append(marker)
            }
            
            let jsonData1 = project!.house_boundary!.data(using: .utf8)!
            let decoder1 = JSONDecoder()
            let houseBounday = try! decoder1.decode([WaypointAddress].self, from: jsonData1)
            
            let path = GMSMutablePath()
            let polygon = GMSPolygon(path: path)
            polygon.strokeWidth = 1.5
            polygon.fillColor = UIColor.green.withAlphaComponent(0.3)
            polygon.strokeColor = .green
            polygon.isTappable = true
            //polygon.map = self.googleMapView
            
            for i in (0..<houseBounday.count){
                let coordinate = CLLocationCoordinate2D(latitude: houseBounday[i].lat!, longitude: houseBounday[i].lng!)
                path.add(coordinate)
                polygon.path = path
            }
            
            self.obstacleHeightField.text = "\(project!.must_height ?? 90)"
            self.heightOfHouseField.text = "\(project!.height_of_house ?? 20)"
            self.mustHighField.text = "\(project!.highest_can ?? 200)"
            
            if(project!.obstacle_boundary != nil && project!.obstacle_boundary != ""){
                print(project!.obstacle_boundary!)
                let jsonData2 = project!.obstacle_boundary!.data(using: .utf8)!
                let decoder2 = JSONDecoder()
                let obstacleBoundary = try! decoder2.decode([[WaypointAddress]].self, from: jsonData2)
                
                self.drawObstableSwift.setOn(true, animated: false)
                for i in (0..<obstacleBoundary.count){
                    self.polygonDrawingCompleted = true
                    for j in (0..<obstacleBoundary[i].count){
                        self.drawOnMap(coordinate: CLLocationCoordinate2D(latitude: obstacleBoundary[i][j].lat!, longitude: obstacleBoundary[i][j].lng!), mapView: self.googleMapView)
                    }
                }
            }
            
        }else{
            drawParamters()
        }
    }
    
    func drawParamters(){
        if(waypointMarkers.count > 0){
            for waypointMarker in waypointMarkers {
                waypointMarker.map = nil
            }
            waypointMarkers.removeAll()
            waypointMarkers = []
        }
        
        let outerRadius = 30
        let innerRadius =  20
        let outerPoints =  50
        let innerPoints =  30
        
        let outCirlePoints = Utils.getCirclePoints(centerLat: houseLat, centerLng: houseLng, radius: outerRadius, numPoints: outerPoints)
        let inCirlePoints = Utils.getCirclePoints(centerLat: houseLat, centerLng: houseLng, radius: innerRadius, numPoints: innerPoints)
        
        let allPoints = outCirlePoints + inCirlePoints
        
        for i in (0..<allPoints.count){
            let waypoint = Int(i) + 1
            let marker = GMSMarker(position: allPoints[i])
            marker.icon = ImageUtils.drawWayPointImage(waypoint: "\(waypoint)")
            marker.map = self.googleMapView
            self.waypointMarkers.append(marker)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if(self.drawObstableSwift.isOn){
            self.drawOnMap(coordinate: coordinate, mapView: mapView)
        }
        
    }
    
    func drawOnMap (coordinate: CLLocationCoordinate2D, mapView: GMSMapView){
        let marker = GMSMarker(position: coordinate)
        marker.icon = UIImage(named: "rec")
        marker.isDraggable = true
        marker.map = mapView
        
        if polygonDrawingCompleted {
            let path = GMSMutablePath()
            path.add(coordinate)
            
            polygonPaths.append(path)
            
            let pathIndex = polygonPaths.endIndex - 1
            
            let currentPlogyon = GMSPolygon(path: polygonPaths[pathIndex])
            polygons.append(currentPlogyon)
            
            let index = polygons.endIndex - 1
            polygons[index].strokeWidth = 1.5
            polygons[index].fillColor = UIColor.red.withAlphaComponent(0.3)
            polygons[index].strokeColor = .red
            polygons[index].isTappable = true
            polygons[index].map = mapView
            
            var myDictionary = [String: Any]()
            myDictionary["polygonIndex"] = index
            myDictionary["pathIndex"] = pathIndex
            
            var arr: [GMSMarker] = []
            arr.append(marker)
            
            myDictionary["markerIndex"] = arr.count-1
            markers.append(arr)
            
            marker.userData = myDictionary
            
            self.drawingBtnsView.isHidden = false
            polygonDrawingCompleted = false
            
        }else{
            let pathIndex = polygonPaths.endIndex - 1
            let index = polygons.endIndex - 1
            polygonPaths[pathIndex].add(coordinate)
            
            var myDictionary = [String: Any]()
            myDictionary["polygonIndex"] = index
            myDictionary["pathIndex"] = pathIndex
            
            polygons[index].path = polygonPaths[pathIndex]
            
            let markerIndex = markers.endIndex - 1
            markers[markerIndex].append(marker)
            
            myDictionary["markerIndex"] = markers[markerIndex].count-1
            marker.userData = myDictionary
        }
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        
        if let userData = marker.userData as? [String: Any],
            let polygonIndex = userData["polygonIndex"] as? Int,
            let markerIndex = userData["markerIndex"] as? Int,
            let pathIndex = userData["pathIndex"] as? Int {
            
            let path = polygonPaths[pathIndex]
            path.replaceCoordinate(at: UInt(markerIndex), with: marker.position)
            polygons[polygonIndex].path = path
        }
        
    }
    
    // Function to check if two GMSMutablePath objects have matching coordinates
    func pathsMatch(_ path1: GMSMutablePath, _ path2: GMSMutablePath) -> Bool {
        if path1.count() != path2.count() {
            return false
        }
        
        for i in 0..<path1.count() {
            let coordinate1 = path1.coordinate(at: UInt(i))
            let coordinate2 = path2.coordinate(at: UInt(i))
            if coordinate1.latitude != coordinate2.latitude || coordinate1.longitude != coordinate2.longitude {
                return false
            }
        }
        
        return true
    }
    
    @IBAction func onSubmitBtnClick(_ sender: Any) {

        var flightPath:[WaypointAddress] = []
        for i in (0..<self.waypointMarkers.count){
            flightPath.append(WaypointAddress(lat: self.waypointMarkers[i].position.latitude, lng: self.waypointMarkers[i].position.longitude))
        }
        
        var obstacles:[[WaypointAddress]] = []
        for i in (0..<self.markers.count){
            var tmp:[WaypointAddress] = []
            for j in (0..<self.markers[i].count){
                tmp.append(WaypointAddress(lat: self.markers[i][j].position.latitude, lng: self.markers[i][j].position.longitude))
            }
            obstacles.append(tmp)
        }
        
     
        if(flightPath.count < 40){
            Toast.show(message: "To less waypoints", controller: self)
        }else if(obstacles.count < 1){
            Toast.show(message: "Please draw atleast one obstacles boundary", controller: self)
        }else{
            var flight_path = ""
            var obstacleBoundary = ""
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted

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
                let data = try encoder.encode(obstacles)
                if let jsonString = String(data: data, encoding: .utf8) {
                    obstacleBoundary = jsonString
                }else{
                    Toast.show(message: "Issue in Obstacle Boundary.", controller: self)
                    return
                }
            } catch {
                Toast.show(message: "Issue in Obstacle Boundary", controller: self)
                return
            }
            
            callUpdateProjectApi(obstacleBoundary: obstacleBoundary, flightPath: flight_path)
        }
    }
    
    func callUpdateProjectApi(obstacleBoundary: String, flightPath: String){
        let heightOfHouse = Int(self.heightOfHouseField.text!)
        let highestCan = Int(self.mustHighField.text!)
        let mustHeight = Int(self.obstacleHeightField.text!)
        
        alert = UIAlertController(title: "Saving Project", message: "Please wait project is update...", preferredStyle: .alert)
        self.present(self.alert!, animated: true, completion: nil)
        
        let headers = [
            "Authorization": "Bearer \(SessionUtils.getUserToken())"
        ]
        
        let parameters: [String: Any] = [
            "flight_path": flightPath,
            "height_of_house": heightOfHouse!,
            "highest_can": highestCan!,
            "must_height": mustHeight!,
            "obstacle_boundary": obstacleBoundary,
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
        let desiredIndex = navigationController!.viewControllers.count - 5
        if desiredIndex >= 0 {
            let desiredViewController = navigationController!.viewControllers[desiredIndex]
            navigationController!.popToViewController(desiredViewController, animated: true)
        }
    }
    
    @IBAction func removeOneClick(_ sender: Any) {
        
        let markerIndex = markers.endIndex - 1
        let pathIndex = polygonPaths.endIndex - 1
        let polygonIndex = polygons.endIndex - 1
        
        for mark in markers[markerIndex]{
            mark.map = nil
        }
        markers.remove(at: markerIndex)
        polygonPaths.remove(at: pathIndex)

        if polygons[polygonIndex] != nil{
            polygons[polygonIndex].map = nil
        }
        
        polygons.remove(at: polygonIndex)
        self.polygonDrawingCompleted = true
        
    }
    
    @IBAction func removeAllClick(_ sender: Any) {
        self.polygonDrawingCompleted = true
        for marker in markers{
            for mark in marker{
                mark.map = nil
            }
        }
        markers.removeAll()
        markers = []
        
        polygonPaths.removeAll()
        polygonPaths = []
        
        for polygon in polygons{
            if(polygon != nil){
                polygon.map = nil
            }
        }
        
        polygons.removeAll()
        polygons = []
        
        self.drawObstableSwift.isOn = false
        self.drawingBtnsView.isHidden = true
    }
    
    @IBAction func completePolygonClick(_ sender: Any) {
        self.polygonDrawingCompleted = true
        self.drawObstableSwift.isOn = false
        self.drawingBtnsView.isHidden = true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
