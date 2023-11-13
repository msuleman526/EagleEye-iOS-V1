//
//  SessionUtils.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 20/03/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation

class SessionUtils{
    
    static func setLoginData(userResponse: UsersResponse)
    {
       let preferences = UserDefaults.standard;
       preferences.set(userResponse.user!.email, forKey: Constants.SESSION_EMAIL)
       preferences.set(userResponse.user!.organization, forKey: Constants.SESSION_ORGANIZATION)
       preferences.set(userResponse.user!.id, forKey: Constants.SESSION_ID)
       preferences.set(userResponse.token, forKey: Constants.SESSION_TOKEN)
       preferences.set(userResponse.user!.full_name, forKey: Constants.SESSION_NAME)
       preferences.set(userResponse.user!.role, forKey: Constants.SESSION_TYPE)
       preferences.synchronize()
       
    }
    
    static func saveActiveFlight(flight: Bool)
    {
        let preferences = UserDefaults.standard;
        preferences.set(true, forKey: "flight")
        preferences.synchronize()
    }
    
    static func saveLatestProject(project: Project)
    {
       let preferences = UserDefaults.standard;
       preferences.set(project.id, forKey: "project_id")
       preferences.synchronize()
    }
    
    static func savePointOfInterest(location: CLLocationCoordinate2D)
    {
        let loc = LocationCoordinate(location)
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(loc) {
           let preferences = UserDefaults.standard;
           preferences.set(encoded, forKey: "point_of_interest")
           preferences.synchronize()
        }
    }
    
    static func getPointOfInterest() -> LocationCoordinate{
        let decoder = JSONDecoder()
        if let savedCoordinate = UserDefaults.standard.data(forKey: "point_of_interest"),
           let locationCoordinate = try? decoder.decode(LocationCoordinate.self, from: savedCoordinate) {
            return locationCoordinate
        } else {
            return LocationCoordinate(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        }
    }
    
    static func getActiveFlight() -> Bool{
        let preferences = UserDefaults.standard;
        if(preferences.object(forKey: "flight")) == nil{
            return false;
        }else
        {
            return preferences.object(forKey: "flight") as! Bool;
        }
    }
    
    static func saveWaypoints(waypoints: [WaypointSetting])
    {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(waypoints) {
           let preferences = UserDefaults.standard;
           preferences.set(encoded, forKey: "waypoints")
           preferences.synchronize()
        }
    }
    
    
    static func getWaypoints() -> [WaypointSetting]{
        let decoder = JSONDecoder()
        if let savedCoordinate = UserDefaults.standard.data(forKey: "waypoints"),
           let locationCoordinate = try? decoder.decode([WaypointSetting].self, from: savedCoordinate) {
             return locationCoordinate
        } else {
            return []
        }
    }
    
    static func saveObstacles(obstacle: String)
    {
       let preferences = UserDefaults.standard;
       preferences.set(obstacle, forKey: "obstacles")
       preferences.synchronize()
    }
    
    
    static func getObstacles() -> String{
        let decoder = JSONDecoder()
        if let savedCoordinate = UserDefaults.standard.object(forKey: "obstacles"){
            return savedCoordinate as! String
        }else{
            return ""
        }
    }
    
    
    static func getLatestProject() -> Int{
        let preferences = UserDefaults.standard;
        if(preferences.object(forKey: "project_id")) == nil{
            return 0;
        }else
        {
            return preferences.object(forKey: "project_id") as! Int;
        }
    }
    
    static func getUserEmail() -> String{
        let preferences = UserDefaults.standard;
        if(preferences.object(forKey: Constants.SESSION_EMAIL)) == nil{
            return "";
        }else
        {
            return preferences.object(forKey: Constants.SESSION_EMAIL) as! String;
        }
    }
    
    static func getUserName() -> String{
        let preferences = UserDefaults.standard;
        if(preferences.object(forKey: Constants.SESSION_NAME)) == nil{
            return "";
        }else
        {
            return preferences.object(forKey: Constants.SESSION_NAME) as! String;
        }
    }
    
    static func getUserToken() -> String{
        let preferences = UserDefaults.standard;
        if(preferences.object(forKey: Constants.SESSION_TOKEN)) == nil{
            return "";
        }else
        {
            return preferences.object(forKey: Constants.SESSION_TOKEN) as! String;
        }
    }
    
    static func getUserID() -> Int{
        let preferences = UserDefaults.standard;
        if(preferences.object(forKey: Constants.SESSION_ID)) == nil{
            return 0;
        }else
        {
            return preferences.object(forKey: Constants.SESSION_ID) as! Int;
        }
    }
    
    static func getUserOrganization() -> String{
        let preferences = UserDefaults.standard;
        if(preferences.object(forKey: Constants.SESSION_ORGANIZATION)) == nil{
            return "";
        }else
        {
            return preferences.object(forKey: Constants.SESSION_ORGANIZATION) as! String;
        }
    }
    
    static func userLogout()
    {
       let preferences = UserDefaults.standard;
       preferences.set("", forKey: Constants.SESSION_EMAIL)
       preferences.set("", forKey: Constants.SESSION_ORGANIZATION)
       preferences.set(0, forKey: Constants.SESSION_ID)
       preferences.set("", forKey: Constants.SESSION_TOKEN)
       preferences.set("", forKey: Constants.SESSION_NAME)
       preferences.set("", forKey: Constants.SESSION_TYPE)
       preferences.synchronize()
       
    }
    
}

struct LocationCoordinate: Codable {
    let latitude: Double
    let longitude: Double

    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

