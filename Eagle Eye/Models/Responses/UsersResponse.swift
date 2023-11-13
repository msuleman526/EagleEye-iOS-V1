//
//  UsersResponse.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 20/03/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation

class UsersResponse: Decodable {
    var message: String?
    var user: User?
    var token: String?
}
