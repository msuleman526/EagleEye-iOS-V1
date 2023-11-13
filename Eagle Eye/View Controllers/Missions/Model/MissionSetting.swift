//
//  MissionSetting.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 30/01/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation

class MissionSetting{
    
    //Default Mission Settings
    public var missionName: String = "EmpTechSol Mission"
    public var maxFlightSpeed: Int = 15
    public var poiHeight: Int = 2
    public var autoFlightSpeed: Int = 5
    public var finishAction: DJIWaypointMissionFinishedAction = .goHome
    public var repeatTimes: Int = 1
    public var headingMode: DJIWaypointMissionHeadingMode = .towardPointOfInterest
    public var rotateGimblePitch: Bool = true
    public var exitMissionOnRCSignalLost: Bool = true
    public var gotoFirstWaypointMode: DJIWaypointMissionGotoWaypointMode = .safely
    public var flightPathMode: DJIWaypointMissionFlightPathMode = .normal
}
