//
//  ProjectSetting.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 23/03/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation

class ProjectSetting: Codable{
    var circleOneRadius: Int?
    var circleTwoRadius: Int?
    var circleOnePoints: Int?
    var circleTwoPoints: Int?
    var horizontalScanRadius: Int?
    var horizontalScanPoints: Int?
    
    init(circleOneRadius: Int, circleTwoRadius: Int, circleOnePoints: Int, circleTwoPoints: Int, horizontalScanRadius: Int, horizontalScanPoints: Int){
        self.circleOneRadius = circleOneRadius
        self.circleTwoRadius = circleTwoRadius
        self.circleOnePoints = circleOnePoints
        self.circleTwoPoints = circleTwoPoints
        self.horizontalScanPoints = horizontalScanPoints
        self.horizontalScanRadius = horizontalScanRadius
    }
}
