//
//  WaypointSetting.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 31/01/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation

class WaypointSetting: Codable{
    public var name: String = "Waypoint"
    public var latittude: Double? = nil
    public var longitude: Double? = nil
    public var altitude: Double = 10
    public var heading: Double = 0
    public var actionRepeatTimes: Int = 1
    public var actionTimeoutInSeconds: Int = 60
    public var cornerRadiusInMeters: Int = 5
    public var turnMode: UInt = DJIWaypointTurnMode.clockwise.rawValue
    public var gimbalPitch: Int = 0
}
