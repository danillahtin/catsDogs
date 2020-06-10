//
//  UserDefaults+Keys.swift
//  CatsDogs
//
//  Created by Danil Lahtin on 10.06.2020.
//  Copyright © 2020 Danil Lahtin. All rights reserved.
//

import Foundation


extension UserDefaults {
    var hasSkippedAuth: Bool {
        get {
            bool(forKey: "hasSkippedAuth")
        }
        
        set {
            set(newValue, forKey: "hasSkippedAuth")
        }
    }
 
}
