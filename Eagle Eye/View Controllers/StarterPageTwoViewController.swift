//
//  StarterPageTwoViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 15/03/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import UIKit

class StarterPageTwoViewController: UIViewController {
    
    @IBOutlet weak var loginBtn: UIButton!
    var alreadyLogin = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        loginBtn.isHidden = true
        //signUpBtn.isHidden = true
        
        if(SessionUtils.getUserID() != 0 && SessionUtils.getUserEmail() != "" && SessionUtils.getUserToken() != ""){
            self.alreadyLogin = true
        }
        
        if(alreadyLogin){
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "startUp") as! StartupViewController
            self.navigationController?.pushViewController(nextViewController, animated: false)
        }else{
            loginBtn.isHidden = false
            loginBtn.layer.cornerRadius = 10
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "login") as! LoginViewController
            self.navigationController?.pushViewController(nextViewController, animated: false)
        }
    
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
