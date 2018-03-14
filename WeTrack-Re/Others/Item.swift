//
//  Item.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 1/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import Foundation
import CoreLocation

struct Constant{
    static let baseURL = "http://128.199.93.67/WeTrack/api/web/index.php/v1/"
    static let URLLogin = baseURL + "user/login-email"
    static let URLReport = baseURL + "location-history"
    static let URLMissing = baseURL + "resident/missing?expand=beacons,relatives,locations"
    static let URLAll = baseURL + "resident?expand=relatives,beacons,locations,locationHistories"
    static let URLCreateDeviceToken = baseURL + "device-token/new"
    static let URLDeleteDeviceToken = baseURL + "device-token/del"
    static let URLStatus = baseURL + "resident/status"
    static let URLLogout = baseURL + "user/logout"
    
    static var device_token = ""
    static let restartTime = 300.0
    static let photoURL = "http://128.199.93.67/WeTrack/backend/web/"
    static var token = ""
    static var username = ""
    static var role = 40
    static var user_id = 0
    static var email = ""
    static var notification = true
    static var userphoto = URL(string: "")
    static var isLogin = false
}

struct GlobalData{
    static var residentStatus = [String:String]()
    static var missingList = [Resident]()
    static var allResidents = [Resident]()
    static var relativeList = [Resident]()
    static var history = [Beacon]()
    static var nearMe = [Resident]()
    static var offlineData = [LocationHistory]()
    
    static var beaconList = [Beacon]()
    static var currentRegionList = [CLBeaconRegion]()
}
