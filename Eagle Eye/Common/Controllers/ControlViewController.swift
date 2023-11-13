//
//  ControlViewController.swift
//  DroneMap
//
//  Created by Evgeny Agamirzov on 14.04.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import UIKit

class NavigationViewController : UIViewController {
    private var controlView: ControlView!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(nibName: nil, bundle: nil)
        controlView = ControlView()
        controlView.addDelegate(self)
        Environment.commandService.addDelegate(self)
        view = controlView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// Subscribe to view updates
extension NavigationViewController : ControlViewDelegate {
    func buttonPressed(_ id: NavigationButtonId) {
//        switch id {
//            case .start:
//                Environment.commandService.executeMissionCommand(.start)
//            case .pause:
//                Environment.commandService.executeMissionCommand(.pause)
//            case .resume:
//                Environment.commandService.executeMissionCommand(.resume)
//            case .stop:
//                Environment.commandService.executeMissionCommand(.stop)
//            default:
//                break
//        }
    }
}

// Subscribe to command responses
extension NavigationViewController : CommandServiceDelegate {
    func missionCommandResponded(_ id: MissionCommandId, _ success: Bool) {
        switch id {
            case .start:
                print("started")
            case .pause:
                print("pause")
            case .resume:
                print("resume")
            case .stop:
                print("stop")
            default:
                break
        }
    }
}
