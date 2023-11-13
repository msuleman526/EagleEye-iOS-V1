//
//  File.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 23/01/2023.
//  Copyright © 2023 DJI. All rights reserved.
//
import GoogleMaps
import Foundation

class Utils{
    
    public static func trimToZeroAndInvert(_ value: Double) -> Double {
        let precision = 0.1
        return (value < precision && value > -precision) ? 0.0 : -value
    }
    
    public static func getRequiredFieldLabelText(labelText: String) -> NSMutableAttributedString{
        let attributedString = NSMutableAttributedString(string: labelText)
        
        let blackColor = [NSAttributedString.Key.foregroundColor: UIColor.black]
        let redColor = [NSAttributedString.Key.foregroundColor: UIColor.red]
        
        attributedString.addAttributes(blackColor, range: NSRange(location: 0, length: labelText.count - 1))
        attributedString.addAttributes(redColor, range: NSRange(location: labelText.count - 1, length: 1))
        
        return attributedString
    }
    
    public static func getCirclePoints (centerLat: Double, centerLng: Double, radius: Int, numPoints: Int) -> [CLLocationCoordinate2D]{
        var points: [CLLocationCoordinate2D] = []
        
        var angle = 0.0
        let increment = (2 * Double.pi) / Double(numPoints)

        for i in 0..<numPoints {
            let lat = centerLat + (Double(radius) / 111320) * cos(angle)
            let lng = centerLng + (Double(radius) / (111320 * cos(centerLat * (Double.pi / 180)))) * sin(angle)

            points.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
            angle += increment
        }

        return points
    }
    
    
    public static func checkWaypointInObstacle(latitude: Double, longitude: Double, obstacle_boundary: [[Obstacle]]) -> Bool{
        var validate = false
       
        let coordinateToCheck = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        for i in (0..<obstacle_boundary.count){
            var boundary = GMSMutablePath()
            for j in (0..<obstacle_boundary[i].count){
                boundary.add(CLLocationCoordinate2D(latitude: obstacle_boundary[i][j].lat!, longitude: obstacle_boundary[i][j].lng!))
            }
            validate = GMSGeometryContainsLocation(coordinateToCheck, boundary, true)
            if(validate){
                break
            }
        }
        
        return validate
    }
    
    public static func getPitchBetweenPOIAndWaypoint(){
        let poi = CLLocationCoordinate2D(latitude: 33.6967810, longitude: 73.050720)
        let poiAltitude: Float = 8
        let aircraftLocation = CLLocationCoordinate2D(latitude: 33.696921, longitude: 73.050749)
        let aircraftAltitude: Float = 20
        
        print("New Pitch \(Utils.angleBetweenLocations(location1: poi, location2: aircraftLocation, height1: Double(poiAltitude), height2: Double(aircraftAltitude)))")
    }

    public static func angleBetweenLocations(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D, height1: Double, height2: Double) -> Double {
        
          let prependicular = height2 - height1
          let base = Utils.haversineDistance(location1: location2, location2: location1)
          let slop = Double(base)/Double(prependicular)
          let angle = atan(slop)
          return -angle * 180 / .pi
        
    }
    
    public static func haversineDistance(location1: CLLocationCoordinate2D, location2: CLLocationCoordinate2D) -> Double {
        let lat1 = location1.latitude * Double.pi / 180
        let lat2 = location2.latitude * Double.pi / 180
        let lng1 = location1.longitude * Double.pi / 180
        let lng2 = location2.longitude * Double.pi / 180
        let dLat = lat2 - lat1
        let dLng = lng2 - lng1
        let a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLng / 2) * sin(dLng / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        let R = 6371e3 // Earth's radius in meters
        return R * c
    }
    
    public static func calculatePitchAngle(waypointCoordinate: CLLocationCoordinate2D, poiCoordinate: CLLocationCoordinate2D, waypointHeight: Double, poiHeight: Double) -> Double {
        // Calculate the height difference
        let heightDifference = poiHeight - waypointHeight
        
        // Calculate the distance between the waypoint and POI using Haversine formula
        let distance = calculateDistance(coord1: poiCoordinate, coord2: waypointCoordinate)
        print("Distance \(distance)")
        
        // Check if the distance is zero (same location)
        if distance == 0 {
            return -90.0 // Gimbal pitch angle is -90 degrees
        }
        
        // Calculate the gimbal pitch angle in radians
        let pitchAngleInRadians = atan(heightDifference / distance)
        
        // Convert the angle to degrees
        let pitchAngleInDegrees = Utils.radiansToDegrees(pitchAngleInRadians)
        
        return pitchAngleInDegrees
    }
    
    public static func calculateDistance(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> CLLocationDistance{
        let location1 = CLLocation(latitude: coord1.latitude, longitude: coord1.longitude)
        let location2 = CLLocation(latitude: coord2.latitude, longitude: coord2.longitude)
        return location1.distance(from: location2)
    }
    
    public static func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * .pi / 180.0
    }

    public static func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / .pi
    }
    
    public static func mergeImageData(imageData: Data, with metadata: NSDictionary) -> Data {
        let source: CGImageSource = CGImageSourceCreateWithData(imageData as NSData, nil)!
        let UTI: CFString = CGImageSourceGetType(source)!
        let newImageData =  NSMutableData()
        let cgImage = UIImage(data: imageData)!.cgImage
        let imageDestination: CGImageDestination = CGImageDestinationCreateWithData((newImageData as CFMutableData), UTI, 1, nil)!
        CGImageDestinationAddImage(imageDestination, cgImage!, metadata as CFDictionary)
        CGImageDestinationFinalize(imageDestination)

        return newImageData as Data
    }
    
    public static func createCircleImage(size: CGSize, backgroundColor: UIColor, borderColor: UIColor, borderWidth: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()

        // Outer circle (border)
        borderColor.setStroke()
        let outerCirclePath = UIBezierPath(ovalIn: CGRect(x: borderWidth / 2, y: borderWidth / 2, width: size.width - borderWidth, height: size.height - borderWidth))
        outerCirclePath.lineWidth = borderWidth
        outerCirclePath.stroke()

        // Inner circle (background)
        backgroundColor.setFill()
        let innerCirclePath = UIBezierPath(ovalIn: CGRect(x: borderWidth, y: borderWidth, width: size.width - borderWidth * 2, height: size.height - borderWidth * 2))
        innerCirclePath.fill()

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
    
    public static func getCategoryColors(category: DJIFlyZoneCategory) -> [String: Any]{
        var fillColor: UIColor = UIColor(hexString: "#979797", alpha: 0.3)
        var strokeColor: UIColor = UIColor(hexString: "#979797", alpha:1.0)
        var categoryStr: String = "Altitude Zone"
        
        if(category == DJIFlyZoneCategory.restricted){
            fillColor = UIColor(hexString: "#de4329", alpha: 0.3)
            strokeColor = UIColor(hexString: "#de4329",alpha: 1.0)
            categoryStr = "Restricted Zone"
        }
        else if(category == DJIFlyZoneCategory.authorization){
            fillColor = UIColor(hexString: "#1088F2", alpha: 0.3)
            strokeColor = UIColor(hexString: "#1088F2", alpha: 1.0)
            categoryStr = "Authorization Zone"
        }
        else if(category == DJIFlyZoneCategory.warning){
            fillColor = UIColor(hexString: "#FFCC00", alpha: 0.3)
            strokeColor = UIColor(hexString: "#FFCC00", alpha: 1.0)
            categoryStr = "Warning Zone"
        }
        else if(category == DJIFlyZoneCategory.enhancedWarning){
            fillColor = UIColor(hexString: "#EE8815", alpha: 0.3)
            strokeColor = UIColor(hexString: "#EE8815", alpha: 1.0)
            categoryStr = "Enhanced Warning Zone"
        }
        
        return [
            "fillColor": fillColor,
            "strokeColor": strokeColor,
            "category": categoryStr
        ]
    }
    
    public static func getFlyZoneReason(reason: DJIFlyZoneReason) -> String{
        if(reason == .airport){
            return "Airport that cannot be unlocked using GEO system."
        }
        else if(reason == .military){
            return "Military authorized zone. This cannot be unlocked using the GEO system."
        }
        else if(reason == .special){
            return "Special Zone. This cannot be unlocked using the GEO system."
        }
        else if(reason == .commercialAirport){
            return "Commercial airport."
        }
        else if(reason == .privateCommercialAirport){
            return "Private commercial airport."
        }
        else if(reason == .recreationalAirport){
            return "Recreational airport"
        }
        else if(reason == .nationalPark){
            return "National park"
        }
        else if(reason == .NOAA){
            return "The National Oceanic and Atmospheric Administration."
        }
        else if(reason == .parcel){
            return "Parcel."
        }
        else if(reason == .powerPlant){
            return "Power plant."
        }
        else if(reason == .prison){
            return "Prison."
        }
        else if(reason == .school){
            return "School."
        }
        else if(reason == .stadium){
            return "Stadium."
        }
        else if(reason == .prohibitedSpecialUse){
            return "Prohibited special use."
        }
        else if(reason == .restrictedSpecialUse){
            return "Restriction special use."
        }
        else if(reason == .temporaryFlightRestriction){
            return "Temporary flight restriction."
        }
        else if(reason == .classBAirSpace){
            return "Class B Airspace."
        }
        else if(reason == .classCAirSpace){
            return "Class C Airspace."
        }
        else if(reason == .classDAirSpace){
            return "Class D Airspace."
        }
        else if(reason == .classEAirSpace){
            return "Class E Airspace."
        }
        else if(reason == .unpavedAirport){
            return "Airport with unpaved runway."
        }
        else if(reason == .heliport){
            return "Heliport."
        }
        else{
            return "Airport Area"
        }
    }

    
}
