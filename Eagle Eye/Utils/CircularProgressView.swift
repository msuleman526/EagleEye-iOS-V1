//
//  CircularProgressView.swift
//  Eagle Eye
//
//  Created by Mohsin Sherin on 25/10/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation
import UIKit

class CircularProgressView: UIView {
    var progress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    override func draw(_ rect: CGRect) {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startAngle: CGFloat = -CGFloat.pi / 2
        let endAngle = startAngle + 2 * CGFloat.pi * progress

        let path = UIBezierPath()
        path.move(to: center)
        path.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.close()

        UIColor.blue.setStroke()
        path.stroke()
    }
}
