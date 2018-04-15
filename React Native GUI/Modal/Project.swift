//
//  Project.swift
//  React Native GUI
//
//  Created by Tejas on 15/04/18.
//  Copyright © 2018 Tejas. All rights reserved.
//

import Foundation

final class Project {
    
    // Can't init is singleton
    private init() { }
    
    // MARK: Shared Instance
    
    static let shared = Project()
    
    // MARK: Local Variable
    var projectDir: String?
}
