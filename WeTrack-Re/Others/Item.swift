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
    //static let baseURL = "http://128.199.93.67/WeTrack/api/web/index.php/v1/"
    static let URLLoginEmail = "/v1/user/login_with_email"
    static let URLLoginAnonymous = "/v1/user/login_anonymous"
    static let URLReportMissing = "/v1/resident/report_missing"
    static let URLMissing = "/v1/resident/missing"
    static let URLRelatives = "/v1/resident/relatives"
    static let URLReportFound = "/v1/resident/report_found"
    static let URLDisableBeacon = "/v1/beacon/disable_beacon"
    static let URLDistinctUUID = "/v1/beacon/load_distinctUUID"
    static let URLRegisterEndpoint = "/v1/pinpoint/register_endpoint"
    static let URLDisableEndpoint = "/v1/pinpoint/disable_endpoint"
    static let URLNotificationStatus = "/v1/user/notification_status"
    
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
    static var distinctBeacons = [Beacon]()
    static var missingList = [Resident]()
    static var allResidents = [Resident]()
    static var relativeList = [Resident]()
    static var history = [Beacon]()
    static var nearMe = [Beacon]()
    static var offlineData = [LocationHistory]()
    static var reportedHistory = [ReportedHistory]()
    
    static var showNotification = false
    
    static var beaconList = [Beacon]()
    static var currentRegionList = [CLBeaconRegion]()
    static var totalGroup = Int()
    static var currentGroup = Int()
    static var backgroundStartTime = Date()
}
