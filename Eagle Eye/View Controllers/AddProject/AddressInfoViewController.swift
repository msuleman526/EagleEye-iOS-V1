//
//  AddressInfoViewController.swift
//  Eagle Eye
//
//  Created by Mohsin Sherin on 02/05/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

struct MyPlace {
    var name: String
    var lat: Double
    var long: Double
}

class AddressInfoViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UITextFieldDelegate  {
    
    
    
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var googleMapView: GMSMapView!
    let currentLocationMarker = GMSMarker()
    var locationManager = CLLocationManager()
    var chosenPlace: MyPlace?
    @IBOutlet weak var googleSearchField: UITextField!
    var currentLat: Double?
    var currentLng: Double?
    var alert: UIAlertController?
    
    
    @IBOutlet weak var backBtn: UIImageView!
    
    var currentLocation: CLLocation?
    
    var project: Project? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        googleMapView.delegate = self
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        backBtn.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backBtnClick))
        backBtn.addGestureRecognizer(tapGesture)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        initGoogleMaps()
        googleSearchField.delegate = self
        
        
        if #available(iOS 15, *) {
            self.addressLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Project Label*")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            if(self.project != nil){
                self.googleSearchField.text = self.project?.address!
                self.currentLat = Double((self.project?.lat!)!)
                self.currentLng = Double((self.project?.lng!)!)
                
                let camera = GMSCameraPosition.camera(withLatitude: self.currentLat!, longitude: self.currentLng!, zoom: 19.0)
                self.googleMapView.camera = camera
                self.googleSearchField.text = self.project?.address!
                self.chosenPlace = MyPlace(name: (self.project?.address!)!, lat: self.currentLat!, long: self.currentLng!)
                let marker=GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: self.currentLat!, longitude: self.currentLng!)
                marker.isDraggable = true
                marker.title = "\(self.project!.name ?? "No Name")"
                marker.map = self.googleMapView
            }
        }
        

    }
    
    @objc func backBtnClick() {
        print("Working")
        self.navigationController?.popViewController(animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        self.currentLat = marker.position.latitude
        self.currentLng = marker.position.longitude
        
        fetchAddress(from: CLLocation(latitude: marker.position.latitude, longitude: marker.position.longitude)) { address in
            print("Address: \(address)")
            self.googleSearchField.text = address
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       let autoCompleteController = GMSAutocompleteViewController()
       autoCompleteController.delegate = self
       
       let filter = GMSAutocompleteFilter()
       autoCompleteController.autocompleteFilter = filter
       
       self.locationManager.startUpdatingLocation()
       self.present(autoCompleteController, animated: true, completion: nil)
    }
    
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        currentLat = place.coordinate.latitude
        currentLng = place.coordinate.longitude
        
        //showPartyMarkers(lat: lat, long: long)
        
        let camera = GMSCameraPosition.camera(withLatitude: currentLat!, longitude: currentLng!, zoom: 19.0)
        googleMapView.camera = camera
        googleSearchField.text=place.formattedAddress
        chosenPlace = MyPlace(name: place.formattedAddress!, lat: currentLat!, long: currentLng!)
        let marker=GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: currentLat!, longitude: currentLng!)
        marker.isDraggable = true
        marker.map = googleMapView
        
        self.dismiss(animated: true, completion: nil) // dismiss after place selected
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 28.7041, longitude: 77.1025, zoom: 17.0)
        self.googleMapView.camera = camera
        self.googleMapView.delegate = self
        self.googleMapView.mapType = .hybrid
        self.googleMapView.isMyLocationEnabled = true
    
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    //MARK: textfield
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
       let autoCompleteController = GMSAutocompleteViewController()
       autoCompleteController.delegate = self
       
       let filter = GMSAutocompleteFilter()
       autoCompleteController.autocompleteFilter = filter
       
       self.locationManager.startUpdatingLocation()
       self.present(autoCompleteController, animated: true, completion: nil)
       return false
    }
    
    
    @IBAction func currentLocationClick(_ sender: Any) {
        if let currentLocation = currentLocation {
            let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 15.0)
            self.googleMapView.animate(to: camera)
            
            self.currentLat = currentLocation.coordinate.latitude
            self.currentLng = currentLocation.coordinate.longitude
            
            // Fetch and print the address of the current location
            fetchAddress(from: currentLocation) { address in
                print("Address: \(address)")
                self.googleSearchField.text = address
                
                self.chosenPlace = MyPlace(name: address, lat: self.currentLat!, long: self.currentLng!)
                let marker=GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: self.currentLat!, longitude: self.currentLng!)
                marker.isDraggable = true
                marker.map = self.googleMapView
            }
        }else{
            print("Current Location is Empty")
        }
    }
    
    func fetchAddress(from location: CLLocation, completion: @escaping (String) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Failed to fetch address: \(error)")
                completion("Failed to fetch address")
                return
            }
            
            if let placemark = placemarks?.first {
                let address = [placemark.subThoroughfare, placemark.thoroughfare, placemark.locality, placemark.administrativeArea, placemark.postalCode, placemark.country].compactMap { $0 }.joined(separator: ", ")
                completion(address)
            } else {
                completion("Address not found")
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       print("Working")
       currentLocation = locations.last
       let lat = (currentLocation?.coordinate.latitude)!
       let long = (currentLocation?.coordinate.longitude)!
    }
    
    
    @IBAction func onSaveAndNextClick(_ sender: Any) {
        let address = self.googleSearchField.text
        
        if(address == ""){
            Toast.show(message: "Please enter address", controller: self)
        }else if(currentLng == nil || currentLng == nil){
            Toast.show(message: "No Address selected", controller: self)
        }else{
            callSaveProjectApi(address: address!)
        }
    }
    
    func callSaveProjectApi(address: String){
        
        alert = UIAlertController(title: "Saving Project", message: "Please wait project is creating...", preferredStyle: .alert)
        self.present(self.alert!, animated: true, completion: nil)
        
        let headers = [
            "Authorization": "Bearer \(SessionUtils.getUserToken())"
        ]
        
        let parameters: [String: Any] = [
            "address": address,
            "latitude": currentLat,
            "longitude": currentLng
        ]
        
        var resourceString = "";
        
        if(project == nil || project?.id! == nil || project?.id! == 0){
            resourceString = "\(Constants.API_LINK)api/project/";
        }else{
            resourceString = "\(Constants.API_LINK)api/project/\(String(describing: project!.id ?? 0))";
        }
        
        
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
                            let res = try decoder.decode(AddProjectResponse.self, from: jsonData!)
                            Toast.show(message: "Project Info updated", controller: self)
                            self.project = res.project!
                            self.dismiss(animated: true, completion: {
                                self.goToProjectInfo(project: res.project!)
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
    
    func goToProjectInfo(project: Project){
        
        print("Go to Project Info")
        if(project.latitude != "" && (project.lat == nil || project.lat == "")){
            project.lat = project.latitude
            project.lng = project.longitude
        }
        
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "ProjectInfo") as! ProjectInfoViewController
        nextVC.project = project
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
