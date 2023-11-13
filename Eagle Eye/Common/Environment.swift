//
//  Environment.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 17.04.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

struct Environment {
    // Shared services
    static let connectionService = ProductCommunicationManager()
    static let simulatorService  = SimulatorService()
    static let commandService    = CommandService()
    static let locationService   = LocationService()
    static let telemetryService  = TelemetryService()


    // Shared mission objects
    static let missionStateManager = MissionStateManager()
    static let missionParameters   = MissionParameters()
    static let missionStorage      = MissionStorage()
}
