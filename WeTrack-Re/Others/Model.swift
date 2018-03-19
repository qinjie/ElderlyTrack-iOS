//
//  Model.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 1/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import Foundation
import SwiftyJSON

class Beacon {
    
    var detect: Bool = true
    var id: Int = 0
    var major: Int32 = 0
    var minor: Int32 = 0
    var name: String = ""
    var photopath: String = ""
    var resident_id: Int = 0
    var report: String = ""
    var status: Bool = true
    var uuid: String = ""
    
    func toString() -> String{
        return "ID: \(id) | Major: \(major) | Minor : \(minor)"
    }
}

class Resident: NSObject, NSCoding {
    var name: String = "Test"
    var id: String = "0"
    var photo: String = ""
    var nric: String = ""
    var report: String = ""
    var status: String = "true"
    var remark: String = "No report"
    var dob: String = "00"
    var isRelative: String = "false"
    var beacons : [Beacon]?
    var latestLocation : Location?
    var beacon_count = 0
    override init(){
        
        name = "Test"
        id = "0"
        photo = ""
        nric = ""
        report = ""
        status = "true"
        remark = "No report"
        dob = "00"
        isRelative = "false"
        self.beacon_count = 0
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        id = aDecoder.decodeObject(forKey: "id") as? String ?? "0"
        photo = aDecoder.decodeObject(forKey: "photo") as? String ?? ""
        nric = aDecoder.decodeObject(forKey: "nric") as? String ?? ""
        report = aDecoder.decodeObject(forKey: "report") as? String ?? ""
        status = aDecoder.decodeObject(forKey: "status") as? String ?? "true"
        remark = aDecoder.decodeObject(forKey: "remark") as? String ?? ""
        dob = aDecoder.decodeObject(forKey: "dob") as? String ?? ""
        isRelative = aDecoder.decodeObject(forKey: "isRelative") as? String ?? "false"
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(id, forKey: "id")
        aCoder.encode(photo, forKey: "photo")
        aCoder.encode(nric, forKey: "nric")
        aCoder.encode(report, forKey: "report")
        aCoder.encode(status, forKey: "status")
        aCoder.encode(remark, forKey: "remark")
        aCoder.encode(dob, forKey: "dob")
        aCoder.encode(isRelative, forKey: "isRelative")
    }
    
}

class LocationHistory: NSObject, NSCoding {
    
    var beaconId: String = "123"
    var userId: String = "68"
    var lat: String = "1.0"
    var long: String = "123"
    
    init(bId: String, uId: String, newlat: String, newlong: String){
        beaconId = bId
        userId = uId
        lat = newlat
        long = newlong
    }
    
    
    required init(coder aDecoder: NSCoder) {
        beaconId = aDecoder.decodeObject(forKey: "beaconId") as? String ?? ""
        userId = aDecoder.decodeObject(forKey: "userId") as? String ?? ""
        lat = aDecoder.decodeObject(forKey: "lat") as? String ?? ""
        long = aDecoder.decodeObject(forKey: "long") as? String ?? ""
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(beaconId, forKey: "beaconId")
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(lat, forKey: "lat")
        aCoder.encode(long, forKey: "long")
    }
}

class Location: NSObject {
    var id : String
    var beacon_id : String
    var locator_id : String
    var user_id : String
    var longitude : String
    var latitude : String
    var address : String
    var created_at : String
    
    init(json : JSON) {
        self.id = json["id"].stringValue
        self.beacon_id = json["beacon_id"].stringValue
        self.locator_id = json["locator_id"].stringValue
        self.user_id = json["user_id"].stringValue
        self.longitude = json["longitude"].stringValue
        self.latitude = json["latitude"].stringValue
        self.address = json["address"].stringValue
        self.created_at = json["created_at"].stringValue
    }
    init(arr: [String : Any]) {
        self.id = String(arr["id"] as? Int ?? 0)
        self.beacon_id = String(arr["beacon_id"] as? Int ?? 0)
        self.locator_id = String(arr["locator_id"] as? Int ?? 0)
        self.user_id = String(arr["user_id"] as? Int ?? 0)
        self.longitude = arr["longitude"] as? String ?? ""
        self.latitude = arr["latitude"] as? String ?? ""
        self.address = arr["address"] as? String ?? ""
        self.created_at = arr["created_at"] as? String ?? ""
    }
}

