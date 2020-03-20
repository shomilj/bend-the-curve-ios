//
//  UserModel.swift
//  Coronavirus
//
//  Created by Shomil Jain on 3/19/20.
//  Copyright © 2020 Pineal Labs. All rights reserved.
//

import Foundation

struct UserModel {
    
    static func savedCommunities() -> [String] {
        return UserDefaults.standard.array(forKey: "savedCommunities") as? [String] ?? ["nan__US", "New York__US", "California__US",  "Illinois__US", "nan__China", "nan__India",]
    }
    
    static func addCommunity(id: String) {
        var saved = savedCommunities()
        if !saved.contains(id) {
            saved.append(id)
            UserDefaults.standard.set(saved, forKey: "savedCommunities")
        }
    }
    
    static func removeCommunity(id: String) {
        var saved = savedCommunities()
        if let i = saved.firstIndex(of: id) {
            saved.remove(at: i)
            UserDefaults.standard.set(saved, forKey: "savedCommunities")
        }
    }
    
}
