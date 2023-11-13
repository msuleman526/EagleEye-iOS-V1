//
//  ConsoleView.swift
//  Zond
//
//  Created by Evgeny Agamirzov on 18.04.20.
//  Copyright © 2020 Evgeny Agamirzov. All rights reserved.
//

import os.log

import UIKit

class ConsoleView : UIView {
    private var stackView = UIStackView()
    private var messageLabel = UILabel()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init() {
        super.init(frame: CGRect())

        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(
            top: 0,
            left: Dimensions.doubleSpacer,
            bottom: 0,
            right: 0
        )

        messageLabel.font = Fonts.title
        messageLabel.textColor = UIColor.white
        stackView.addArrangedSubview(messageLabel)

        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        addSubview(stackView)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: Dimensions.tileSize),
            stackView.widthAnchor.constraint(equalTo: widthAnchor),
            stackView.heightAnchor.constraint(equalTo: heightAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// Public methods
extension ConsoleView {
    func logMessage(_ message: String, _ type: OSLogType) {
        os_log("%@", type: type, message)
        messageLabel.text = message
    }
}
