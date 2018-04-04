//
//  FilePath.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 1/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import Foundation

struct FilePath{
    
    static func relativePath() -> String{
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return dir!.appendingPathComponent("relative.txt").path
    }
    
    static func allResidents() -> String{
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return dir!.appendingPathComponent("allresident.txt").path
    }
    
    static func missingResidents() -> String{
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return dir!.appendingPathComponent("missingresident.txt").path
    }
    
    static func offlineLocations() -> String{
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return dir!.appendingPathComponent("offlinelocations.txt").path
    }
    
    static func beaconList() -> String{
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        return dir!.appendingPathComponent("beaconList.txt").path
    }
    
}
