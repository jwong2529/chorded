//
//  DiscogsCreds.swift
//  MusicReviewApp
//
//  Created by Janice Wong on 5/28/24.
//

import Foundation

struct DiscogsCreds {
    static let shared = DiscogsCreds()
    
    let discogsAPIKey: String
    let discogsAPISecret: String
    
    private init() {
        guard let url = Bundle.main.url(forResource: "DiscogsAPI", withExtension: "plist"),
                let data = try? Data(contentsOf: url),
                let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            fatalError("Couldn't find DiscogsAPI.plist file.")
        }
        
        guard let apiKey = plist["DiscogsAPIKey"] as? String,
              let apiSecret = plist["DiscogsAPISecret"] as? String else {
            fatalError("Couldn't find API keys in DiscogsAPI.plist file.")
        }
        
        self.discogsAPIKey = apiKey
        self.discogsAPISecret = apiSecret
    }
}
