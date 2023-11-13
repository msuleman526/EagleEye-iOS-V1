//
//  Constants.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 17/03/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation


public class Constants {
    public static var API_LINK: String = "https://eagleyedrone.com/"
    public static var SESSION_EMAIL:String = "SESSION_EMAIL"
    public static var SESSION_ORGANIZATION:String = "SESSION_ORGANIZATION"
    public static var SESSION_NAME:String = "SESSION_NAME"
    public static var SESSION_TOKEN:String = "SESSION_TOKEN"
    public static var SESSION_ID:String = "SESSION_ID"
    public static var MAP_TYPE:String = "MAP_TYPE"
    public static var SESSION_TYPE:String = "SESSION_TYPE"
    public static var LOGGING_ENABLED:Bool = true
    
    public static let GOOGLE_MAP_PLACES_API_KEY:String = "AIzaSyCIxJV6mYZCYE8U4IYI5_JNoaQtRdp3NCE"
    public static let GOOGLE_MAP_KEY:String = "AIzaSyCGJd1Jc-aN30rEU2cwoxY4GHx4ZBbFweE"
    public static var IMAGE_URL:String = "https://maps.googleapis.com/maps/api/staticmap?center=[LAT],[LNG]&zoom=20&size=800x500&maptype=satellite&format=png&key=\(Constants.GOOGLE_MAP_PLACES_API_KEY)"
}
