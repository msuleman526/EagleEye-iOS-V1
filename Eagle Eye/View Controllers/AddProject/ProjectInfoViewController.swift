//
//  ProjectInfoViewController.swift
//  Eagle Eye
//
//  Created by Mohsin Sherin on 03/05/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProjectInfoViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var surveyDateLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var projectNameFeld: UITextField!
    
    @IBOutlet weak var addressImageView: UIImageView!
    var houseLat: Double = 37.4669494
    var houseLng: Double = -122.2142187
    var streetAddress: String = "23 Oakwood Blvd, Atherton, CA 94027, USA"
    
    var project: Project? = nil
    var alert: UIAlertController?
    
    @IBOutlet weak var addressImgView: UIView!
    @IBOutlet weak var hideMapBtn: UIButton!
    @IBOutlet weak var showMapBtn: UIButton!

    @IBOutlet weak var backBtn: UIImageView!
    var datePicker: UIDatePicker? = nil

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
        
        self.projectNameFeld.delegate = self
        self.phoneField.delegate = self
        self.dateField.delegate = self
        self.emailField.delegate = self
        self.addressField.delegate = self
        
        backBtn.isUserInteractionEnabled = true
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(backBtnClick))
        backBtn.addGestureRecognizer(tapGesture1)
        
        //Setting Up Labels
        self.addressLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Project Address*")
        self.nameLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Project Name*")
        self.emailLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Email Address*")
        self.surveyDateLbl.attributedText = Utils.getRequiredFieldLabelText(labelText: "Survey Date*")
        
        streetAddress = project!.address ?? ""
        self.addressField.text = project!.address ?? ""
        self.phoneField.text = project!.phone ?? ""
        self.emailField.text = project!.email ?? ""
        self.dateField.text =  project!.survey_at ?? ""
        
        self.projectNameFeld.text = project!.name ?? ""
        
        datePicker = UIDatePicker()
        datePicker!.datePickerMode = .date
        dateField.inputView = datePicker
        datePicker!.preferredDatePickerStyle = .wheels
        datePicker!.addTarget(self, action: #selector(handleDateChange), for: .valueChanged)

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonTapped))
        toolbar.setItems([doneButton], animated: false)
        dateField.inputAccessoryView = toolbar
        
        loadProjectData()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss the keyboard
        return true
    }
    
    @objc func backBtnClick() {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func doneButtonTapped() {
        let selectedDate = datePicker!.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Customize the date format as needed
        dateField.text = dateFormatter.string(from: selectedDate)
        dateField.resignFirstResponder()
            
    }
    
    @IBAction func showMap(_ sender: Any) {
        self.hideMapBtn.isHidden = false
        self.showMapBtn.isHidden = true
        self.addressImgView.isHidden = false
    }
    
    @IBAction func hideMap(_ sender: Any) {
        self.hideMapBtn.isHidden = true
        self.showMapBtn.isHidden = false
        self.addressImgView.isHidden = true
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func handleDateChange(datePicker: UIDatePicker){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateField.text = dateFormatter.string(from: datePicker.date)
    }
    
    
    func loadProjectData(){
        var urlStr = project?.address_image

        if(urlStr == nil || urlStr == ""){
            urlStr = Constants.IMAGE_URL
            urlStr = urlStr!.replacingOccurrences(of: "[LAT]", with: "\(houseLat)")
            urlStr = urlStr!.replacingOccurrences(of: "[LNG]", with: "\(houseLng)")
        }
        
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
                self.addressImageView.image = image
            }
        }.resume()
        
        //self.addressField.text = streetAddress
        
    }
    
    @IBAction func onProjectInfoSaveClick(_ sender: Any) {
        let address = addressField.text
        let name = projectNameFeld.text
        let email = emailField.text
        let phone = phoneField.text
        let surveyDate = dateField.text
        
        if(address == "" || name == "" || email == "" || surveyDate == ""){
            Toast.show(message: "Please fill the form properly", controller: self)
        }else{
            callUpdateProjectApi(address: address!, name: name!, date: surveyDate!, phone: phone!, email: email!)
        }
    }
    
    func callUpdateProjectApi(address: String, name: String, date: String, phone: String, email: String){
        
        alert = UIAlertController(title: "Saving Project", message: "Please wait project is update...", preferredStyle: .alert)
        self.present(self.alert!, animated: true, completion: nil)
        
        let headers = [
            "Authorization": "Bearer \(SessionUtils.getUserToken())"
        ]
        
        let parameters: [String: Any] = [
            "address": address,
            "assign_to": SessionUtils.getUserID(),
            "email": email,
            "name": name,
            "phone": phone,
            "survey_date": date,
            "type": "Residential"
        ]
        
        let resourceString = "\(Constants.API_LINK)api/project/\(String(describing: project!.id ?? 0))";
        print(resourceString)
        
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
    
        let nextVC = storyboard?.instantiateViewController(withIdentifier: "ParameterInfo") as! ParameterInfoViewController
        nextVC.project = project
        self.navigationController?.pushViewController(nextVC, animated: false)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    

}
