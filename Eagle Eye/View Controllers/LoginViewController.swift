//
//  LoginViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 15/03/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

@available(iOS 13.0, *)
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    
    
    var alert : UIAlertController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email Address",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3]
        )
        passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray3]
        )
        
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            self.view.endEditing(true)
            return false
        }
    
    @IBAction func loginBtnClick(_ sender: Any) {
        let email: String = emailTextField.text!
        let password: String = passwordTextField.text!
        
        if(email == "" || password == ""){
            Toast.show(message: "Please fill email and password", controller: self)
        }else{
            callLoginApi(email: email, password: password)
        }
        
    }
    
    func callLoginApi(email: String, password: String){
        present(alert!, animated: false, completion: nil)
        let parametersLogin =  [
            "email": email,
            "password": password
        ]
        
        let header = [
            "Accept": "text/json"
        ]
        
        let resourceString = "\(Constants.API_LINK)api/auth/login";
        
        Alamofire.request(resourceString, method: .post, parameters: parametersLogin, headers: header).responseString(completionHandler: { (response) in
            switch response.result {
            case .success(let value):
                if let httpURLResponse = response.response{
                    let response_code = httpURLResponse.statusCode;
                    if response_code == 200{
                        do{
                            self.alert?.dismiss(animated: false, completion: nil)
                            let json = JSON(value)
                            let str = String(describing: json);
                            let jsonData = str.data(using: .utf8)
                            let decoder = JSONDecoder();
                            if Constants.LOGGING_ENABLED{
                                print(value)}
                            let res = try decoder.decode(UsersResponse.self, from: jsonData!)
                            SessionUtils.setLoginData(userResponse: res)
                            self.goToHomeScreen()
                        }catch{
                            Toast.show(message: "There is some issue while login", controller: self)
                        }
                    }
                    else{
                        self.alert?.dismiss(animated: false, completion: nil)
                        if(response.result.value!.contains("credentials do not match"))
                        {
                            Toast.show(message: "Invalid Credentials", controller: self)
                        }else if(response.result.value!.contains("User Not Found"))
                        {
                            Toast.show(message: "User Not Found", controller: self)
                        }
                        else if(response.result.value!.contains("\"app_login\":0"))
                        {
                            Toast.show(message: "Access Denied", controller: self)
                        }
                        else
                        {
                            Toast.show(message: "No Internet Connection/Server Issue", controller: self)
                        }
                    }
                }
            case .failure(let error):
                self.alert?.dismiss(animated: false, completion: nil)
                Toast.show(message: "No Internet Connect/Server Error.", controller: self)
            }
        })
    }
    
    func goToHomeScreen(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "startUp") as! StartupViewController
        self.navigationController?.pushViewController(nextViewController, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
