//
//  ImageUtils.swift
//  DJISDKSwiftDemo
//
//  Created by Mohsin Sherin on 18/01/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation

class ImageUtils{
    
    public static func drawWayPointWithPointOfInterest(backgroundImage: UIImage, foregroundImage: UIImage) -> UIImage{
        // Original background image

        // Create a new image context with the size of the background image
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)

        // Draw the background image in the new image context
        backgroundImage.draw(in: CGRect(x: 0, y: 0, width: backgroundImage.size.width, height: backgroundImage.size.height))

        // Draw the foreground image on top of the background image
        foregroundImage.draw(in: CGRect(x: 0, y: 0, width: foregroundImage.size.width, height: foregroundImage.size.height))

        // Get the new image from the image context
        let newImage = UIGraphicsGetImageFromCurrentImageContext()

        // End the image context
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    public static func drawWayPointImage(waypoint: String) -> UIImage{
        let image = UIImage(named: "point")
        let font: UIFont?
        if(waypoint.count < 4)
        {
            font=UIFont(name: "Helvetica-Bold", size: 11.5)!
        }else
        {
            font=UIFont(name: "Helvetica-Bold", size: 19.2)!
        }
        let text_style=NSMutableParagraphStyle()
        text_style.alignment=NSTextAlignment.center
        let text_color=UIColor.white
        let attributes=[NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:text_style, NSAttributedString.Key.foregroundColor:text_color]
        
        // Setup the image context using the passed image
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: image!.size.width, height: image!.size.height), false, scale)
        // Put the image into a rectangle as large as the original image
        image!.draw(in: CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height))
        
        // Create a point within the space that is as bit as the image
        let text_h=font!.lineHeight
        let text_y=(image!.size.height-text_h)/2
        let rect = CGRect(x: 1.8, y: text_y-5.8, width: image!.size.width-4, height: text_h)
        
        // Draw the text into an image
        waypoint.draw(in: rect.integral, withAttributes: attributes)
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage
    }
    
    public static func XXRadiansToDegrees(radians: Double) -> Double {
        return radians * 180.0 / M_PI
    }
    
    static func degreesToRadians(_ degrees: Double) -> Double { return degrees * Double.pi / 180.0 }
    static func radiansToDegrees(_ radians: Double) -> Double { return radians * 180.0 / Double.pi }


    public static func getBearingBetweenTwoPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)

        let lat2 = degreesToRadians(point2.coordinate.latitude);
        let lon2 = degreesToRadians(point2.coordinate.longitude);

        let dLon = lon2 - lon1;

        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);

        return radiansBearing
    }
    
    public static func getAngleBetweenPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)

        let lat2 = degreesToRadians(point2.coordinate.latitude);
        let lon2 = degreesToRadians(point2.coordinate.longitude);

        let dLon = lon2 - lon1;

        let y = sin(dLon) * cos(lat2);
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
        let radiansBearing = atan2(y, x);
        
        let degreesBearing = radiansBearing * 180 / .pi
    
        return degreesBearing
    }
    
}

extension UIImage{
    func rotateImage(radians: Float) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: CGFloat(radians))).size
        // Trim off the extremely small float value to prevent core graphics from rounding it up
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)

        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!

        // Move origin to middle
        context.translateBy(x: newSize.width/2, y: newSize.height/2)
        // Rotate around middle
        context.rotate(by: CGFloat(radians))
        // Draw the image at its center
        self.draw(in: CGRect(x: -self.size.width/2, y: -self.size.height/2, width: self.size.width, height: self.size.height))

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
