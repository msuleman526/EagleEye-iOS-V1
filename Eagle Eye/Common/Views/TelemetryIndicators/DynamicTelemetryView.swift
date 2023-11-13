//
//  DynamicTelemetryView.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 28.10.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class DynamicTelemetryView : UIView {
    // Stored properties
    private let stackView = UIStackView()
    private let velocityStackView = UIStackView()
    private let distanceStackView = UIStackView()
    private var horizontalSpeedWidget = DynamicTelemetryWidget(.horizontalSpeed)
    private var verticalSpeedWidget = DynamicTelemetryWidget(.verticalSpeed)
    private var altitudeWidget = DynamicTelemetryWidget(.altitude)
    private var distanceWidget = DynamicTelemetryWidget(.distance)

    // Computed properties
    private var x: CGFloat {
        return Dimensions.screenWidth - width - Dimensions.roundedAreaOffsetOr(Dimensions.spacer)
    }
    private var y: CGFloat {
        return Dimensions.screenHeight - height - Dimensions.spacer
    }
    private var width: CGFloat {
        return Dimensions.dynamicTelemetryWidgetWidth * CGFloat(2) + Dimensions.separator
    }
    private var height: CGFloat {
        return Dimensions.dynamicTelemetryWidgetHeight * CGFloat(2) + Dimensions.separator
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(frame: CGRect())
        frame = CGRect(
            x: x,
            y: y,
            width: width,
            height: height
        )

        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .center

        horizontalSpeedWidget.updateValueLabel(nil)
        verticalSpeedWidget.updateValueLabel(nil)
        altitudeWidget.updateValueLabel(nil)
        distanceWidget.updateValueLabel(nil)

        velocityStackView.axis = .horizontal
        velocityStackView.distribution = .fillEqually
        velocityStackView.alignment = .center
        velocityStackView.addArrangedSubview(horizontalSpeedWidget)
        velocityStackView.setCustomSpacing(Dimensions.separator, after: horizontalSpeedWidget)
        velocityStackView.addArrangedSubview(verticalSpeedWidget)

        distanceStackView.axis = .horizontal
        distanceStackView.distribution = .fillEqually
        distanceStackView.alignment = .center
        distanceStackView.addArrangedSubview(distanceWidget)
        distanceStackView.setCustomSpacing(Dimensions.separator, after: distanceWidget)
        distanceStackView.addArrangedSubview(altitudeWidget)

        stackView.addArrangedSubview(distanceStackView)
        stackView.setCustomSpacing(Dimensions.separator, after: distanceStackView)
        stackView.addArrangedSubview(velocityStackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false;
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
}

// Public methods
extension DynamicTelemetryView {
    func toggleShow(_ show: Bool) {
        self.layer.opacity = show ? 1 : 0
    }

    func updateTelemetryValue(_ id: DynamicTelemetryWidgetId, with value: String?) {
        switch id {
            case .horizontalSpeed:
                horizontalSpeedWidget.updateValueLabel(value)
            case .verticalSpeed:
                verticalSpeedWidget.updateValueLabel(value)
            case .altitude:
                altitudeWidget.updateValueLabel(value)
            case .distance:
                distanceWidget.updateValueLabel(value)
        }
    }
}
