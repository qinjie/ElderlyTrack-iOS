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
import AWSAPIGateway
import AWSAuthCore
import AWSCore
import AWSMobileClient

struct api{
    static func loginWithEmail(controller: UIViewController){
        
        let httpMethodName = "POST"
        let URLString = Constant.URLLoginEmail
        let headerParameters = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        let httpBody = [
            "email":Constant.email
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName, urlString: URLString, queryParameters: nil, headerParameters: headerParameters, httpBody: httpBody)
        
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_X2QIQAP347_ElderlytrackClient.register(with: serviceConfiguration!, forKey: "loginWithEmail")
        
        let invocationClient = AWSAPI_X2QIQAP347_ElderlytrackClient(forKey: "loginWithEmail")
        
        invocationClient.invoke(apiRequest).continueWith { (task:AWSTask) -> Any? in
            
            if let error = task.error{
                print("Error occured: \(error)")
                return nil
            }
            
            let result = task.result!
            if result.statusCode == 200{
                
                do{
                    let json = (try JSONSerialization.jsonObject(with: result.responseData!) as? [String:Any])!
                    Constant.user_id = json["user_id"] as! Int
                    Constant.username = json["username"] as! String
                    Constant.email = json["email"] as! String
                    Constant.role = json["role"] as! Int
                    UserDefaults.standard.set(Constant.user_id, forKey: "user_id")
                    UserDefaults.standard.set(Constant.username, forKey: "username")
                    UserDefaults.standard.set(Constant.email, forKey: "email")
                    UserDefaults.standard.set(Constant.role, forKey: "role")
                    if (json["status"] as! Int) != 10{
                        controller.displayAlert(title: "Login failed", message: "This account has been deactivated.")
                    }
                    loadRelative(controller: controller)
                    
                } catch{
                    print("Error parsing data to json: \(error.localizedDescription)")
                }
                
            }else{
                controller.displayAlert(title: "Login failed", message: "This account is not registered.")
                AWSSignInManager.sharedInstance().logout(completionHandler: { (success, error) in
                    //Successfully logout
                })
            }
            
            print(result.statusCode)
            
            return nil
            
        }
        
    }
    
    static func loginAnonymous(controller: UIViewController){
        let httpMethodName = "GET"
        let URLString = Constant.URLLoginAnonymous
        let headerParameters = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName, urlString: URLString, queryParameters: nil, headerParameters: headerParameters, httpBody: nil)
        
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_X2QIQAP347_ElderlytrackClient.register(with: serviceConfiguration!, forKey: "loginAnonymous")
        
        let invocationClient = AWSAPI_X2QIQAP347_ElderlytrackClient(forKey: "loginAnonymous")
        
        invocationClient.invoke(apiRequest).continueWith { (task:AWSTask) -> Any? in
            
            if let error = task.error{
                print("Error occured: \(error)")
                return nil
            }
            
            let result = task.result!
            if result.statusCode == 200{
                
                do{
                    let json = (try JSONSerialization.jsonObject(with: result.responseData!) as? [String:Any])!
                    Constant.user_id = json["user_id"] as! Int
                    Constant.username = json["username"] as! String
                    Constant.role = json["role"] as! Int
                    UserDefaults.standard.set(Constant.user_id, forKey: "user_id")
                    UserDefaults.standard.set(Constant.username, forKey: "username")
                    UserDefaults.standard.set(Constant.email, forKey: "email")
                    UserDefaults.standard.set(Constant.role, forKey: "role")
                    if (json["status"] as! Int) != 10{
                        controller.displayAlert(title: "Login failed", message: "This account has been deactivated.")
                    }
                    loadRelative(controller: controller)
                    
                } catch{
                    print("Error parsing data to json: \(error.localizedDescription)")
                }
                
            }else{
                controller.displayAlert(title: "Login failed", message: "Please try again later.")
                AWSSignInManager.sharedInstance().logout(completionHandler: { (success, error) in
                    //Successfully logout
                })
            }
            
            print(result.statusCode)
            
            return nil
        }
    }
    
    static func loadMissingResidents(controller: UIViewController? = nil){
        
        let httpMethodName = "GET"
        let URLString = Constant.URLMissing
        let headerParameters = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName, urlString: URLString, queryParameters: nil, headerParameters: headerParameters, httpBody: nil)
        
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_X2QIQAP347_ElderlytrackClient.register(with: serviceConfiguration!, forKey: "getMissingResidents")
        
        let invocationClient = AWSAPI_X2QIQAP347_ElderlytrackClient(forKey: "getMissingResidents")
        
        invocationClient.invoke(apiRequest).continueWith { (task:AWSTask) -> Any? in
            
            DispatchQueue.main.async {
                OperationQueue.main.addOperation {
                    if let missing = controller as? MissingResidentsController{
                        missing.refreshControl?.endRefreshing()
                    }
                }
            }
            
            if let error = task.error{
                print("Error occured: \(error)")
                return nil
            }
            
            let result = task.result!
            if result.statusCode == 200{
                
                do{
                    let JSON = (try JSONSerialization.jsonObject(with: result.responseData!) as? [[String:Any]])!
                    
                    
                    
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
                                if let remark = json["remark"] as? String{
                                    newMissing.remark = remark
                                }
                                newMissing.report = json["reported_at"] as! String
                                newMissing.nric = json["nric"] as! String
                                newMissing.dob = json["dob"] as! String
                                
                                resident = newMissing
                            }
                            
                            if let beacons = json["beacons"] as? [[String:Any]]{
                                var tempBeacon = [Beacon]()
                                if let viewController = controller as? MissingResidentsController{
                                    viewController.newRegionList.removeAll()
                                }
                                for beacon in beacons{
                                    
                                    let newBeacon = Beacon()
                                    newBeacon.uuid = (beacon["uuid"] as? String)!
                                    newBeacon.major = (beacon["major"] as? Int32)!
                                    newBeacon.minor = (beacon["minor"] as? Int32)!
                                    newBeacon.id = (beacon["id"] as? Int)!
                                    newBeacon.resident_id = Int(resident.id)!
                                    newBeacon.status = (beacon["status"] as? Int)!
                                    
                                    if newBeacon.status?.hashValue != 0 && newBeacon.status?.hashValue != 2{
                                        newBeacon.name = resident.name + "#" + String(describing: newBeacon.id!) + "#" + String(resident.id)
                                        print("** NAME \(String(describing: newBeacon.name))")
                                        if let viewController = controller as? MissingResidentsController{
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
                    
                    DispatchQueue.main.async {
                        OperationQueue.main.addOperation {
                            if let viewController = controller as? MissingResidentsController{
                                viewController.residents = GlobalData.missingList
                                viewController.tableView.reloadData()
                                viewController.switchMornitoringList()
                            }else if let viewController = controller as? RelativeController{
                                viewController.refreshControl?.endRefreshing()
                                viewController.tableView.reloadData()
                            }
                        }
                    }
                    
                    NSKeyedArchiver.archiveRootObject(GlobalData.missingList, toFile: FilePath.missingResidents())
                    
                    
                    
                } catch{
                    print("Error parsing data to json: \(error.localizedDescription)")
                }
                
            }else{
                controller?.displayAlert(title: "Failed to load missing residents", message: "Please try again later.")
            }
            
            print(result.statusCode)
            
            return nil
        }
        
    }
    
    static func loadRelative(controller: UIViewController? = nil){
        let httpMethodName = "POST"
        let URLString = Constant.URLRelatives
        let headerParameters = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        let httpBody = [
            "user_id" : Constant.user_id
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName, urlString: URLString, queryParameters: nil, headerParameters: headerParameters, httpBody: httpBody)
        
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_X2QIQAP347_ElderlytrackClient.register(with: serviceConfiguration!, forKey: "loadRelative")
        
        let invocationClient = AWSAPI_X2QIQAP347_ElderlytrackClient(forKey: "loadRelative")
        
        invocationClient.invoke(apiRequest).continueWith { (task:AWSTask) -> Any? in
            
            if let error = task.error{
                print("Error occured: \(error)")
                return nil
            }
            
            let result = task.result!
            if result.statusCode == 200{
                
                DispatchQueue.main.async {
                    OperationQueue.main.addOperation {
                        if let relativeController = controller as? RelativeController{
                            loadMissingResidents(controller: controller)
                        }
                    }
                }
                
                do{
                    let JSON = (try JSONSerialization.jsonObject(with: result.responseData!) as? [[String:Any]])!
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
                        newResident.isRelative = true
                        GlobalData.allResidents.append(newResident)
                    }
                    
                    print(" all residents : \(GlobalData.allResidents.count)")
                    
                    GlobalData.relativeList = GlobalData.allResidents.filter({$0.isRelative == true})
                    
                    NSKeyedArchiver.archiveRootObject(GlobalData.allResidents, toFile: FilePath.allResidents())
                    NSKeyedArchiver.archiveRootObject(GlobalData.relativeList, toFile: FilePath.relativePath())
                    
                    DispatchQueue.main.async {
                        OperationQueue.main.addOperation {
                            if let loginController = controller as? LoginController{
                                loginController.performSegue(withIdentifier: "home", sender: nil)
                            }else if let relativeController = controller as? RelativeController{
                                relativeController.relatives = GlobalData.relativeList
                                relativeController.tableView.reloadData()
                                relativeController.refreshControl?.endRefreshing()
                            }
                        }
                    }
                    
                } catch{
                    print("Error parsing data to json: \(error.localizedDescription)")
                }
                
            }else{
                controller?.displayAlert(title: "Login failed", message: "Please try again later.")
            }
            
            print(result.statusCode)
            
            return nil
        }
    }
    
    static func loadDistinctUUID(controller: UIViewController?=nil){
        let httpMethodName = "GET"
        let URLString = Constant.URLDistinctUUID
        let headerParameters = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName, urlString: URLString, queryParameters: nil, headerParameters: headerParameters, httpBody: nil)
        
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_X2QIQAP347_ElderlytrackClient.register(with: serviceConfiguration!, forKey: "loadDistinctUUID")
        
        let invocationClient = AWSAPI_X2QIQAP347_ElderlytrackClient(forKey: "loadDistinctUUID")
        
        invocationClient.invoke(apiRequest).continueWith { (task:AWSTask) -> Any? in
            
            if let error = task.error{
                print("Error occured: \(error)")
                return nil
            }
            
            let result = task.result!
            if result.statusCode == 200{
                
                do{
                    let json = (try JSONSerialization.jsonObject(with: result.responseData!) as? [String:Any])!
                    if let beacons = json["beacons"] as? [[String: Any]]{
                        GlobalData.distinctBeacons.removeAll()
                        for beacon in beacons{
                            let newBeacon = Beacon()
                            newBeacon.uuid = beacon["uuid"] as? String
                            newBeacon.identifier = "common: \(GlobalData.distinctBeacons.count+1)"
                            GlobalData.distinctBeacons.append(newBeacon)
                        }
                        NSKeyedArchiver.archiveRootObject(GlobalData.distinctBeacons, toFile: FilePath.distinctBeacon())
                    }
                    
                } catch{
                    print("Error parsing data to json: \(error.localizedDescription)")
                }
                
            }
            
            print(result.statusCode)
            return nil
        }
    }
    
    static func reportMissing(resident: Resident, remark: String, controller: UIViewController?=nil){
        let httpMethodName = "POST"
        let URLString = Constant.URLReportMissing
        let headerParameters = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        let httpBody: [String:Any] = [
            "resident_id": resident.id,
            "user_id": Constant.user_id,
            "remark": remark
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName, urlString: URLString, queryParameters: nil, headerParameters: headerParameters, httpBody: httpBody)
        
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_X2QIQAP347_ElderlytrackClient.register(with: serviceConfiguration!, forKey: "reportMissing")
        
        let invocationClient = AWSAPI_X2QIQAP347_ElderlytrackClient(forKey: "reportMissing")
        
        invocationClient.invoke(apiRequest).continueWith { (task:AWSTask) -> Any? in
            
            if let error = task.error{
                print("Error occured: \(error)")
                return nil
            }
            
            let result = task.result!
            if result.statusCode == 200{
                print("Report Successfully")
                DispatchQueue.main.async {
                    OperationQueue.main.addOperation {
                        if let controller = controller as? ResidentDetailController{
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
                
            }else{
                controller?.displayAlert(title: "Login failed", message: "Please try again later.")
            }
            
            print(result.statusCode)
            
            return nil
        }
    }
    
    static func reportFound(location:LocationHistory){
        let httpMethodName = "POST"
        let URLString = Constant.URLReportFound
        let headerParameters = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        let httpBody: [String:Any] = [
            "beacon_id": location.beaconId,
            "user_id" : Constant.user_id,
            "longitude" : location.long,
            "latitude" : location.lat
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName, urlString: URLString, queryParameters: nil, headerParameters: headerParameters, httpBody: httpBody)
        
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_X2QIQAP347_ElderlytrackClient.register(with: serviceConfiguration!, forKey: "reportFound")
        
        let invocationClient = AWSAPI_X2QIQAP347_ElderlytrackClient(forKey: "reportFound")
        
        invocationClient.invoke(apiRequest).continueWith { (task:AWSTask) -> Any? in
            
            if let error = task.error{
                print("Error occured: \(error)")
                return nil
            }
            
            let result = task.result!
            if result.statusCode == 200{
                
                print("Successfully report for \(location.userId)")
                
            }else{
            }
            
            print(result.statusCode)
            
            return nil
        }
    }
    
    static func disableBeacon(beacon:Beacon){
        let httpMethodName = "POST"
        let URLString = Constant.URLDisableBeacon
        let headerParameters = [
            "Content-Type" : "application/json",
            "Accept" : "application/json"
        ]
        let httpBody: [String: Any] = [
            "beacon_id" : beacon.id!
        ]
        
        let apiRequest = AWSAPIGatewayRequest(httpMethod: httpMethodName, urlString: URLString, queryParameters: nil, headerParameters: headerParameters, httpBody: httpBody)
        
        let serviceConfiguration = AWSServiceConfiguration(region: .APSoutheast1, credentialsProvider: AWSMobileClient.sharedInstance().getCredentialsProvider())
        
        AWSAPI_X2QIQAP347_ElderlytrackClient.register(with: serviceConfiguration!, forKey: "disableBeacon")
        
        let invocationClient = AWSAPI_X2QIQAP347_ElderlytrackClient(forKey: "disableBeacon")
        
        invocationClient.invoke(apiRequest).continueWith { (task:AWSTask) -> Any? in
            
            if let error = task.error{
                print("Error occured: \(error)")
                return nil
            }
            
            let result = task.result!
            if result.statusCode == 200{
                
                print("Successfully toggle beacon: \(beacon.id!)")
                DispatchQueue.main.async {
                    OperationQueue.main.addOperation {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshMissingResident"), object: nil)
                    }
                }
                
            }else{
            }
            
            print(result.statusCode)
            
            return nil
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

