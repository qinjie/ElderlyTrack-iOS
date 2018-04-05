//
//  Functions.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 1/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UserNotifications
import Foundation
import Alamofire
import CoreLocation
import SwiftyJSON

struct alamofire{
    
    static func loginWithEmail(email: String, viewController:UIViewController){
        
        let parameters: Parameters = [
            "email" : email
        ]
        print("email:\(email)")
        Constant.email = email
        UserDefaults.standard.set(email, forKey: "email")
        
        Alamofire.request(Constant.URLLogin, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            if let json = response.result.value as? [String: Any]{
                print("\(json)")
                let result = json["result"] as! String
                
                if result == "correct"{
                    Constant.token = json["token"] as! String
                    Constant.user_id = json["user_id"] as! Int
                    Constant.username = json["username"] as! String
                    Constant.role = json["role"] as! Int
                    createDeviceToken(viewController: viewController)
                    UserDefaults.standard.set(Constant.username, forKey: "username")
                    UserDefaults.standard.set(Constant.token, forKey: "token")
                    UserDefaults.standard.set(Constant.user_id, forKey: "user_id")
                    UserDefaults.standard.set(Constant.role, forKey: "role")
                }
                else{
                    if let loginController = viewController as? LoginController{
                        loginController.alertController.dismiss(animated: true, completion: nil)
                    }
                    viewController.displayAlert(title: "Login Failed", message: "This function can only be used by registered user. You can go to nearest police station for registration or use Anonymous login!")
                 
                    //GIDSignIn.sharedInstance().signOut()
                }
            }
            else{
                if let loginController = viewController as? LoginController{
                    loginController.alertController.dismiss(animated: true, completion: nil)
                }
                viewController.displayAlert(title: "Login Failed", message: "Please check your internet connection!")
            }
        }
    }
    
    static func reportFoundResident(location: LocationHistory){
        let parameters : [String:Any] = [
            "beacon_id" : location.beaconId,
            "user_id" : Constant.user_id,
            "longitude" : location.long,
            "latitude" : location.lat
        ]
        Alamofire.request(Constant.URLReport, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response: DataResponse) in
            if response.response?.statusCode == 200{
                print("Successfully report for \(location.userId)")
            }
        }
    }
    
    static func loadDistinctUUID(controller: UIViewController){
        
        
        //start monitoring
        if let missingController = controller as? MissingResidentsController{
            missingController.startMonitorCommon()
        }
    }
    
    static func reportMissingResident(resident: Resident, remark: String, viewController: UIViewController){
        
        viewController.showLoadingHUD()
        
        let parameters: [String:Any] = [
            "id" : resident.id,
            "remark" : remark == "" ? " ":remark
        ]
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + Constant.token
        ]
        
        Alamofire.request(Constant.URLStatus, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse) in
            let statusCode = response.response?.statusCode
            viewController.hideLoadingHUD()
            if statusCode == 200 {
                let json = response.result.value
                print(" reponse \(String(describing: json))")
                
                if let controller = viewController as? ResidentDetailController{
                    if controller.switchBtn.isOn{
                        controller.resident?.remark = remark
                        controller.resident?.status = true
                        controller.setup()
                        controller.tableView.reloadData()
                    }else{
                        controller.resident?.status = false
                        controller.resident?.remark = ""
                        controller.setup()
                        controller.tableView.reloadData()
                    }
                    controller.saveRelativeState()
                    NotificationCenter.default.post(name: Notification.Name("refreshMissingResident"), object: nil)
                }
            }
        }
        
        
    }
    
    static func createDeviceToken(viewController:UIViewController){
        
        let parameters: Parameters = [
            "token": Constant.device_token,
            "user_id":Constant.user_id
        ]
        
        Alamofire.request(Constant.URLCreateDeviceToken, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response:DataResponse) in
            if let json = response.result.value as? [String:Any]{
                print("\(json)")
                let result = json["result"] as! String
                if result == "correct" && Constant.user_id == 0{
                    Constant.token = json["token"] as! String
                    Constant.user_id = json["user_id"] as! Int
                    Constant.username = "Anonymous"
                    Constant.role = json["role"] as! Int
                    UserDefaults.standard.set(Constant.user_id, forKey: "user_id")
                    UserDefaults.standard.set(Constant.role, forKey: "role")
                    UserDefaults.standard.set(Constant.token, forKey: "token")
                }
                loadRelativeList(viewController: viewController)
            }
        }
    }
    
    static func loadRelativeList(viewController:UIViewController){
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer " + Constant.token
        ]
        
        Alamofire.request(Constant.URLAll, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response:DataResponse) in
            if let JSON = response.result.value as? [[String:Any]] {
                GlobalData.allResidents.removeAll()
                Constant.isLogin = true
                for json in JSON{
                    
                    let newResident = Resident()
                    
                    newResident.status = json["status"] as! Bool
                    newResident.name = json["fullname"] as! String
                    newResident.id = String(describing: json["id"] as! Int)
                    newResident.photo = json["image_path"] as! String
                    newResident.remark = json["remark"] as! String
                    newResident.nric = json["nric"] as! String
                    newResident.dob = json["dob"] as! String
                    
                    if let latestLocation = json["latestLocation"] as? [[String:Any]]{
                        if latestLocation.count > 0{
                            let location = Location(arr: latestLocation[0])
                            newResident.latestLocation = location
                        }
                    }
                    
                    if let relatives = json["relatives"] as? [[String:Any]]{
                        
                        for relative in relatives{
                            
                            let x = relative["id"] as! Int
                            if x == Constant.user_id{
                                newResident.isRelative = true
                            }
                        }
                    }
                    GlobalData.allResidents.append(newResident)
                }
                
                print(" all residents : \(GlobalData.allResidents.count)")
                
                GlobalData.relativeList = GlobalData.allResidents.filter({$0.isRelative == true})
                
                NSKeyedArchiver.archiveRootObject(GlobalData.allResidents, toFile: FilePath.allResidents())
                NSKeyedArchiver.archiveRootObject(GlobalData.relativeList, toFile: FilePath.relativePath())
                
                DispatchQueue.main.async {
                    OperationQueue.main.addOperation {
                        if let loginController = viewController as? LoginController{
                            loginController.performSegue(withIdentifier: "loginSegue", sender: nil)
                        }else if let relativeController = viewController as? RelativeController{
                            relativeController.relatives = GlobalData.relativeList
                            relativeController.tableView.reloadData()
                            relativeController.refreshControl?.endRefreshing()
                        }
                    }
                }
            }
        }
    }
    
    static func loadMissingResidents(viewController: UIViewController){
        
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + Constant.token
        ]
        
        Alamofire.request(Constant.URLMissing, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse) in
            
            let statusCode = response.response?.statusCode
            
            if statusCode == 200{
                
                print("finish load")
                if let viewController = viewController as? MissingResidentsController{
                    viewController.refreshControl?.endRefreshing()
                }
                
                if let JSON = response.result.value as? [[String:Any]]{
                    
                    GlobalData.beaconList.removeAll()
                    GlobalData.missingList.removeAll()
                    
                    for json in JSON{
                        let status = json["status"] as! Bool
                        
                        if status.hashValue != 0{
                            let id = String(describing: json["id"] as! Int)
                            var resident = Resident()
                            if let newMissing = GlobalData.allResidents.first(where: {$0.id == id}){
                                newMissing.status = true
                                newMissing.report = json["reported_at"] as! String
                                
                                resident = newMissing
                            }else{
                                let newMissing = Resident()
                                
                                newMissing.status = true
                                newMissing.name = json["fullname"] as! String
                                newMissing.id = String(describing: json["id"] as! Int)
                                newMissing.photo = json["image_path"] as! String
                                newMissing.remark = json["remark"] as! String
                                newMissing.report = json["reported_at"] as! String
                                newMissing.nric = json["nric"] as! String
                                newMissing.dob = json["dob"] as! String
                                
                                resident = newMissing
                            }
                            
                            if let beacons = json["beacons"] as? [[String:Any]]{
                                var tempBeacon = [Beacon]()
                                for beacon in beacons{
                                    
                                    let newBeacon = Beacon()
                                    newBeacon.uuid = beacon["uuid"] as! String
                                    newBeacon.major = beacon["major"] as! Int32
                                    newBeacon.minor = beacon["minor"] as! Int32
                                    newBeacon.id = beacon["id"] as! Int
                                    newBeacon.resident_id = Int(resident.id)!
                                    newBeacon.status = beacon["status"] as! Bool
                                    
                                    if newBeacon.status?.hashValue != 0 {
                                        newBeacon.name = resident.name + "#" + String(describing: newBeacon.id) + "#" + String(resident.id)
                                        print("** NAME \(newBeacon.name)")
                                        if let viewController = viewController as? MissingResidentsController{
                                            let uuid = NSUUID(uuidString: newBeacon.uuid!)! as UUID
                                            let newRegion = CLBeaconRegion(proximityUUID: uuid, major: UInt16(newBeacon.major!), minor: UInt16(newBeacon.minor!), identifier: newBeacon.name!)
                                            viewController.newRegionList.append(newRegion)
                                        }
                                        GlobalData.beaconList.append(newBeacon)
                                    }
                                    tempBeacon.append(newBeacon)
                                    
                                }
                                NSKeyedArchiver.archiveRootObject(GlobalData.beaconList, toFile: FilePath.beaconList())
                                resident.beacons = tempBeacon
                            }
                            
                            if let locations = json["locations"] as? [[String:Any]]{
                                for location in locations{
                                    let now = dateFormatter.formatDate(date: Date(), format: "yyyy-MM-dd HH:mm:ss")
                                    if let created_at = location["created_at"] as? String{
                                        let timeInterval = now.timeIntervalSince(dateFormatter.format(string: created_at, format: "yyyy-MM-dd HH:mm:ss"))
                                        if timeInterval < 3600{
                                            resident.latestLocation = Location(arr: location)
                                        }
                                    }
                                }
                            }
                            
                            GlobalData.missingList.append(resident)
                            
                        }
                    }
                    
                    for i in GlobalData.missingList{
                        if !GlobalData.allResidents.contains(i){
                            GlobalData.allResidents.append(i)
                        }
                    }
                    
                    if let viewController = viewController as? MissingResidentsController{
                        viewController.residents = GlobalData.missingList
                        viewController.tableView.reloadData()
                        viewController.switchMornitoringList()
                    }
                    
                    NSKeyedArchiver.archiveRootObject(GlobalData.missingList, toFile: FilePath.missingResidents())
                }
                
            }
            
        }
        
    }
    
    static func logout(viewController:UIViewController){
        let headers: HTTPHeaders = [
            "Authorization" : "Bearer " + Constant.token
        ]
        
        Alamofire.request(Constant.URLLogout, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON { (response: DataResponse) in
            if viewController is SettingController{
                viewController.showLoadingHUD()
            }
            if response.data != nil{
                let parameters: Parameters = [
                    "token" : Constant.device_token,
                    "user_id" : Constant.user_id
                ]
                Alamofire.request(Constant.URLDeleteDeviceToken, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON(completionHandler: { (response: DataResponse) in
                    if response.data != nil{
                        if let settingController = viewController as? SettingController{
                            settingController.deleteData()
                            viewController.hideLoadingHUD()
                        }
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.resetAppToFirstController()
                        
                        if Constant.role != 5{
                            //GIDSignIn.sharedInstance().signOut()
                        }
                    }else{
                        viewController.displayAlert(title: "No internet connection", message: "Please check your internet connection.")
                    }
                    
                })
            }else {
                viewController.displayAlert(title: "Warning", message: "Please check your internet connection.")
            }
        }
    }
    
}

struct dateFormatter{
    static func format(date: Date,format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    static func format(string: String,format: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: string)!
    }
    
    static func now(format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: Date())
    }
    
    static func formatDate(date: Date,format: String) -> Date{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: formatter.string(from: date))!
    }
    
    static func formatString(string: String,format: String) -> String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: formatter.date(from: string)!)
    }
}

struct notification{
    
    static func presentNotification(title: String, body: String, timeInterval: Int, repeats: Bool, identifier: String){
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(timeInterval), repeats: repeats)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if error != nil{
                print("error adding notification: \(error!.localizedDescription)")
            }
        }
    }
    
}

