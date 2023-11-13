//
//  StaticTelemetryViewController.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 23.05.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class StaticTelemetryViewController : UIViewController {
    private var staticTelemetryView: StaticTelemetryView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        staticTelemetryView = StaticTelemetryView()
        registerListeners()
        view = staticTelemetryView
    }
}

// Private methods
extension StaticTelemetryViewController {
    private func registerListeners() {
        Environment.telemetryService.flightModeChanged = { modeString in
            self.staticTelemetryView.updateFlightMode(modeString)
        }
        Environment.telemetryService.gpsSignalStatusChanged = { signalStatus in
            self.staticTelemetryView.updateGpsSignalStatus(signalStatus)
        }
        Environment.telemetryService.gpsSatCountChanged = { satCount in
            self.staticTelemetryView.updateGpsSatCount(satCount)
        }
        Environment.telemetryService.linkSignalQualityChanged = { signalStrength in
            self.staticTelemetryView.updateLinkSignalStrength(signalStrength)
        }
        Environment.telemetryService.batteryChargeChanged = { batteryPercentage in
            self.staticTelemetryView.updateBatteryPercentage(batteryPercentage)
        }
        staticTelemetryView.simulatorButtonSelected = { isSelected in
            if isSelected {
                let userLocation = Environment.mapViewController.userLocation
                Environment.simulatorService.startSimulator(userLocation, { success in
                    self.staticTelemetryView.enableSimulatorVisualization(success)
                })
            } else {
                Environment.simulatorService.stopSimulator({ _ in
                    self.staticTelemetryView.enableSimulatorVisualization(false)
                })
            }
        }
        Environment.connectionService.listeners.append({ model in
            if model == nil {
                self.staticTelemetryView.enableSimulatorVisualization(false)
            }
        })
    }
}
