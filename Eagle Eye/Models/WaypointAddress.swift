//
//  WaypointAddress.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 17/03/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation

class WaypointAddress: Codable{
    var lat: Double?
    var lng: Double?
    
    init(lat: Double, lng: Double){
        self.lat = lat
        self.lng = lng
    }
}
