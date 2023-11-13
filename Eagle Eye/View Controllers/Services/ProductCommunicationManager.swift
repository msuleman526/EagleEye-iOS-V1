//
//  ProductCommunicationManager.swift
//  SDK Swift Sample
//
//  Created by Arnaud Thiercelin on 3/22/17.
//  Copyright © 2017 DJI. All rights reserved.
//

import UIKit
import DJISDK
import os.log

class ProductCommunicationManager: BaseService {

    var listeners: [((_ model: String?) -> Void)?] = []
    var logConsole: ((_ message: String, _ type: OSLogType) -> Void)?
    var droneLog: ((_ connection: Bool, _ type: OSLogType, _ drone: String) -> Void)?
    
    // Set this value to true to use the app with the Bridge and false to connect directly to the product
    let enableBridgeMode = false
    
    // When enableBridgeMode is set to true, set this value to the IP of your bridge app.
    let bridgeAppIP = "10.81.55.116"
    
    override func start() {
        os_log("Starting connection service", type: .debug)
        DJISDKManager.registerApp(with: self)
        super.start()
    }
    
    
    func registerWithSDK() {
        let appKey = Bundle.main.object(forInfoDictionaryKey: SDK_APP_KEY_INFO_PLIST_KEY) as? String
        
        guard appKey != nil && appKey!.isEmpty == false else {
            NSLog("Please enter your app key in the info.plist")
            return
        }
        
        DJISDKManager.registerApp(with: self)
    }
    
    override func stop() {
        os_log("Stopping connection service", type: .info)
        DJISDKManager.stopConnectionToProduct()
        super.stop()
    }
    
}

extension ProductCommunicationManager : DJISDKManagerDelegate {
    
    
    func didUpdateDatabaseDownloadProgress(_ progress: Progress) {
        NSLog("SDK downloading db file \(progress.completedUnitCount / progress.totalUnitCount)")
    }
    
    func appRegisteredWithError(_ error: Error?) {
        
        if error != nil {
            print("SDK registration failed: \(error!.localizedDescription)")
        } else {
            NSLog("SDK Registered with error \(error?.localizedDescription ?? "")")
            
            if enableBridgeMode {
                DJISDKManager.enableBridgeMode(withBridgeAppIP: bridgeAppIP)
            } else {
                DJISDKManager.startConnectionToProduct()
            }
            DJISDKManager.startConnectionToProduct()
            DJISDKManager.closeConnection(whenEnteringBackground: true)
        }
        NSLog("SDK Registered with error \(error?.localizedDescription ?? "")")
        
    }
    
    func productConnected(_ product: DJIBaseProduct?) {
        if product == nil {
            os_log("Connection error", type: .error)
        } else {
            os_log("Connected, starting services", type: .info)
            Environment.missionStorage.registerListeners()
            Environment.simulatorService.registerListeners()
            Environment.commandService.registerListeners()
            Environment.locationService.registerListeners()
            Environment.telemetryService.registerListeners()
            super.subscribe([
                DJIProductKey(param: DJIProductParamModelName):self.onModelNameChanged
            ])
        }
    }
    
    func productDisconnected() {
        os_log("Disconnected, stopping services", type: .info)
        super.unsubscribe()
    }
    
    func componentConnected(withKey key: String?, andIndex index: Int) {
        
    }
    
    func componentDisconnected(withKey key: String?, andIndex index: Int) {
        
    }
}

// Aircraft key subscribtion handlers
extension ProductCommunicationManager {
    private func onModelNameChanged(_ value: DJIKeyedValue?, _: DJIKey?) {
        print("Model Change")
        var model: String?
        if value == nil || value!.stringValue == nil {
            logConsole?("Product disconnected", .info)
            droneLog?(false, .info, "")
        } else if value!.stringValue! == DJIAircraftModeNameOnlyRemoteController {
            logConsole?("Connected to \(DJIAircraftModeNameOnlyRemoteController)", .info)
            droneLog?(true, .info, DJIAircraftModeNameOnlyRemoteController)
        } else {
            model = value!.stringValue!
            logConsole?("Connected to \(model!)", .info)
            droneLog?(true, .info, model!)
        }
        for listener in listeners {
            listener?(model != DJIAircraftModeNameOnlyRemoteController ? model : nil)
        }
    }
}
