//
//  UpdateProjectResponse.swift
//  Eagle Eye
//
//  Created by Mohsin Sherin on 12/05/2023.
//  Copyright © 2023 DJI. All rights reserved.
//

import Foundation


class UpdateProjectResponse: Decodable {
    public var message: String?
    public var project: Project?
}
