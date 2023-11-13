//
//  Toast.swift
//  EmpowerEnergy
//
//  Created by Salman Sherin on 19/04/2020.
//  Copyright © 2020 Salman Sherin. All rights reserved.
//

import Foundation
import UIKit

class Toast {
    static func show(message: String, controller: UIViewController) {
        let toastContainer = UIView(frame: CGRect())
        toastContainer.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastContainer.alpha = 0.0
        toastContainer.layer.cornerRadius = 25;
        toastContainer.clipsToBounds  =  true

        let toastLabel = UILabel(frame: CGRect())
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = toastLabel.font.withSize(12.0) // Corrected the font size setting
        toastLabel.text = message
        toastLabel.clipsToBounds  =  true
        toastLabel.numberOfLines = 0

        toastContainer.addSubview(toastLabel)
        controller.view.addSubview(toastContainer)

        toastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastContainer.translatesAutoresizingMaskIntoConstraints = false

        // Constraints for toastLabel
        let labelConstraints = [
            toastLabel.leadingAnchor.constraint(equalTo: toastContainer.leadingAnchor, constant: 15),
            toastLabel.trailingAnchor.constraint(equalTo: toastContainer.trailingAnchor, constant: -15),
            toastLabel.bottomAnchor.constraint(equalTo: toastContainer.bottomAnchor, constant: -15),
            toastLabel.topAnchor.constraint(equalTo: toastContainer.topAnchor, constant: 15)
        ]

        NSLayoutConstraint.activate(labelConstraints)

        // Constraints for toastContainer
        let containerConstraints = [
            toastContainer.leadingAnchor.constraint(greaterThanOrEqualTo: controller.view.leadingAnchor, constant: 65),
            toastContainer.trailingAnchor.constraint(lessThanOrEqualTo: controller.view.trailingAnchor, constant: -65),
            toastContainer.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor, constant: -75),
            toastContainer.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor)
        ]

        NSLayoutConstraint.activate(containerConstraints)

        // Maximum width constraint for toastContainer
        let maxToastWidth: CGFloat = 600 // Adjust this value as needed
        let toastContainerWidthConstraint = toastContainer.widthAnchor.constraint(lessThanOrEqualToConstant: maxToastWidth)
        toastContainerWidthConstraint.priority = UILayoutPriority(999)
        toastContainerWidthConstraint.isActive = true

        // Animations to show and hide the toast message
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseIn, animations: {
            toastContainer.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 1.5, options: .curveEaseOut, animations: {
                toastContainer.alpha = 0.0
            }, completion: {_ in
                toastContainer.removeFromSuperview()
            })
        })
    }
}
