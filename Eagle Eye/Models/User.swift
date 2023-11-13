//
//  User.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 20/03/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation

class User: Decodable{
    var id:Int?;
    var first_name:String?
    var last_name:String?
    var organization: String?
    var role: String?
    var full_name: String?
    var email: String?
    var phone: String?
    var created_at: String?
}
