//
//  RegionModel.swift
//  Coronavirus
//
//  Created by Shomil Jain on 3/19/20.
//  Copyright © 2020 Pineal Labs. All rights reserved.
//

import Foundation

struct NewsModel {
    
    var documentID: String!
    
    var title: String = ""
    var publisher: String = ""
    var time: String = ""
    var image: String? = nil
    var url: String = ""
    
}

extension NewsModel: FirestoreModel {
    
    init?(modelData: FirestoreModelData) {
        try? self.init(documentID: modelData.documentID, title: modelData.value(forKey: "title"), publisher: modelData.value(forKey: "publisher"), time: modelData.value(forKey: "time"), image: modelData.optionalValue(forKey: "image"), url: modelData.value(forKey: "url"))
    }
    
}

struct RegionModel {
    
    var documentID: String!
    
    var numCases: Int {
        return (timeSeriesY["Confirmed"] ?? []).last ?? 0
    }
    
    var numRecovered: Int {
        return (timeSeriesY["Recovered"] ?? []).last ?? 0
    }
    
    var numDead: Int {
        return (timeSeriesY["Deaths"] ?? []).last ?? 0
    }

    var country: String = ""
    var region: String? = nil
    
    var oneDayNumber: Int = 0
    var fiveDayNumber: Int = 0
    var tenDayNumber: Int = 0
    
    var oneDayPercent: Double = 0.0
    var fiveDayPercent: Double = 0.0
    var tenDayPercent: Double = 0.0
    
    var timeSeriesKeys: [String] = [String]()
    var timeSeriesX: [String] = [String]()
    var timeSeriesY: [String: [Int]] = [String: [Int]]()
    
    static func dummy() -> RegionModel {
        return RegionModel(country: "Global",
                           region: nil,
                           oneDayNumber: 3434,
                           fiveDayNumber: 423,
                           tenDayNumber: 454,
                           oneDayPercent: 43.2,
                           fiveDayPercent: 323.4,
                           tenDayPercent: 23.4,
                           timeSeriesKeys: ["Dead"],
                           timeSeriesX: ["08/22/20", "10/20/20"],
                           timeSeriesY: ["Dead": [232, 2324]])
    }
}

extension RegionModel: FirestoreModel {
    init?(modelData: FirestoreModelData) {
        try? self.init(documentID: modelData.documentID, country: modelData.value(forKey: "country"), region: modelData.optionalValue(forKey: "region"), oneDayNumber: modelData.value(forKey: "oneDayNum"), fiveDayNumber: modelData.value(forKey: "fiveDayNum"), tenDayNumber: modelData.value(forKey: "tenDayNum"), oneDayPercent: modelData.value(forKey: "oneDayPercent"), fiveDayPercent: modelData.value(forKey: "fiveDayPercent"), tenDayPercent: modelData.value(forKey: "tenDayPercent"), timeSeriesKeys: modelData.value(forKey: "timeSeriesKeys"), timeSeriesX: modelData.value(forKey: "timeSeriesX"), timeSeriesY: modelData.value(forKey: "timeSeriesY"))
    }
}
