//
//  AppDelegate.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 28/2/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import UserNotifications
import CoreLocation
import AWSMobileClient
import AWSPinpoint

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    var pinpoint: AWSPinpoint?
    var window: UIWindow?
    var locationManager = CLLocationManager()
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    private var reachability : Reachability!
    var flag = false
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        AWSDDLog.sharedInstance.logLevel = .info
        
        pinpoint = AWSPinpoint(configuration: AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions))
        
        if let email = UserDefaults.standard.string(forKey: "email"){
            Constant.email = email
        }
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.reachability = Reachability()
        do{
            try self.reachability.startNotifier()
        }catch{
            print("\(error.localizedDescription)")
        }
        
        if UserDefaults.standard.string(forKey: "username") != nil{
            if let homeController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as? UITabBarController{
                self.window?.rootViewController = homeController
            }
        }else{
            self.resetAppToFirstController()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: ReachabilityChangedNotification, object: nil)
        
        print("pinpoint: " + String(describing: pinpoint?.targetingClient.currentEndpointProfile()))
        
        checkUpdate()
        
        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return AWSMobileClient.sharedInstance().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        //print("endPoint: \(pinpoint?.targetingClient.currentEndpointProfile().endpointId)")
        api.registerEndpoint(endpointID: (pinpoint?.targetingClient.currentEndpointProfile().endpointId)!)
        pinpoint!.notificationManager.interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        
    }
    
    func registerNotification(){
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert]) { (success, error) in
            if success{
                print("granted noti")
                UserDefaults.standard.set("true", forKey: "notification")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    
                }
            }else{
                print("denied noti")
                UserDefaults.standard.set("false", forKey: "notification")
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(
            userInfo, fetchCompletionHandler: completionHandler)
        
        if (application.applicationState == .active) {
//            let alert = UIAlertController(title: "Notification Received",
//                                          message: userInfo.description,
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//
//            UIApplication.shared.keyWindow?.rootViewController?.present(
//                alert, animated: true, completion:nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if let targetingClient = pinpoint?.targetingClient {
            targetingClient.addAttribute(["science", "politics", "travel"], forKey: "interests")
            targetingClient.updateEndpointProfile()
            let endpointId = targetingClient.currentEndpointProfile().endpointId
            print("Updated custom attributes for endpoint: \(endpointId)")
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("Get notification status")
        api.getNotificationStatus()
        checkUpdate()
        
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func checkUpdate(){
        if isInternetAvailable(){
            DispatchQueue.global().async {
                do{
                    let _ = try self.isUpdateAvailable(completion: { (update, error) in
                        if let error = error{
                            print(error)
                        }else if update == true{
                            DispatchQueue.main.async {
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    let url = NSURL(string: "itms-apps://itunes.apple.com/app/id1271974330")
                                    if UIApplication.shared.canOpenURL(url! as URL){
                                        UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
                                    }
                                })
                                self.window?.rootViewController?.displayAlert(title: "New update available on App Store", message: "Please update to the newer version.", actions: [alertAction])
                            }
                        }
                    })
                    
                }catch{
                    print(error)
                }
            }
        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func resetAppToFirstController() {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginController = (mainStoryboard.instantiateViewController(withIdentifier: "Login") as? UINavigationController)
        self.window?.rootViewController = loginController
    }
    
    @objc private func reachabilityChanged(notification: Notification){
        
        let reachability = notification.object as! Reachability
        if reachability.isReachable{
            if reachability.isReachableViaWiFi{
                print("Reachable via WiFi")
            }else{
                print("Reachable via Cellular")
            }
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: FilePath.offlineLocations()) as? [LocationHistory]{
                for location in dict{
                    
                    api.reportFound(location: location)
                }
            }
        }else{
            print("Network not reachable")
        }
        
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    func requestLocationService(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    //Location Manager
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("MonitoringDidFailForRegion - error: \(error.localizedDescription)")
        print("MonitoringDidFailForRegion - error: \(String(describing: region?.identifier))")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started monitoring for \(region.identifier) region")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("Determine state: \(region.identifier)")
        switch state{
        case .inside:
            print("Inside region \(region.identifier)")
            let info = region.identifier.components(separatedBy: "#")
            
            //Fetch the missing list once
            if flag==false{
                flag = true
                NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshMissingResident"), object: nil)
            }
            Timer.after(60) {
                self.flag = false
            }
            
            if info[0] != "common"{
                if GlobalData.reportedHistory.contains(where: {$0.regionIdentifier == region.identifier}){
                    let history = GlobalData.reportedHistory.filter({$0.regionIdentifier == region.identifier})
                    let latest = history.max(by: {a,b in a.time!<b.time!})
                    let currentDate = dateFormatter.formatDate(date: Date(), format: "yyyy-MM-dd HH:mm:ss")
                    let timeInterval = currentDate.timeIntervalSince((latest?.time!)!)
                    if timeInterval >= 180{
                        
                        Timer.after(5) {
                            self.reportRegion(info: info)
                        }
                        let newReportHistory = ReportedHistory()
                        newReportHistory.regionIdentifier = region.identifier
                        newReportHistory.time = dateFormatter.formatDate(date: Date(), format: "yyyy-MM-dd HH:mm:ss")
                        GlobalData.reportedHistory.append(newReportHistory)
                        NSKeyedArchiver.archiveRootObject(GlobalData.reportedHistory, toFile: FilePath.reportedHistory())
                    }
                }else{
                    self.reportRegion(info: info)
                    let newReportHistory = ReportedHistory()
                    newReportHistory.regionIdentifier = region.identifier
                    newReportHistory.time = dateFormatter.formatDate(date: Date(), format: "yyyy-MM-dd HH:mm:ss")
                    GlobalData.reportedHistory.append(newReportHistory)
                    NSKeyedArchiver.archiveRootObject(GlobalData.reportedHistory, toFile: FilePath.reportedHistory())
                }
            }
            
        case .outside:
            print("Outside region \(region.identifier)")
            if region is CLBeaconRegion{
                let info = region.identifier.components(separatedBy: "#")
                if info[0] != "common"{
                    GlobalData.nearMe = GlobalData.nearMe.filter({$0.id?.description != info[1]})
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "updateHistory"), object: nil)
                }
            }
        case .unknown:
            print("Region unknown")
        }
    }
    
    func reportRegion(info: [String]){
        let now = dateFormatter.now(format: "yyyy-MM-dd HH:mm:ss")
        if let notificationCheck = Bool(UserDefaults.standard.string(forKey: "notification")!){
            if notificationCheck{
                let role = Int(UserDefaults.standard.string(forKey: "role")!)
                if role == 5{
                    notification.presentNotification(title: "Beacon detected", body: "Missing people is nearby.", timeInterval: 1, repeats: false, identifier: info[0])
                }else{
                    notification.presentNotification(title: "Beacon detected", body: "\(info[0]) is nearby.", timeInterval: 1, repeats: false, identifier: info[0])
                }
            }
        }
        let beacon = GlobalData.beaconList.first(where: {$0.id?.description == info[1]})
        let resident = GlobalData.allResidents.first(where: {$0.id.description == info[2]})
        if beacon != nil{
            
            if !GlobalData.nearMe.contains(where: {$0.id == beacon?.id}){
                GlobalData.nearMe.append(beacon!)
            }
            
            if resident != nil{
                resident?.report = now
                beacon?.report = now
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "updateHistory"), object: nil)
        DispatchQueue.main.async {
            let lat = self.locationManager.location?.coordinate.latitude
            let long = self.locationManager.location?.coordinate.longitude
            let locationHistory = LocationHistory(bId: info[1], uId: info[2], newlat: String(describing: lat!), newlong: String(describing: long!))
            
            if let user = GlobalData.missingList.filter({$0.id == info[2]}).first{
                for i in 0...GlobalData.missingList.count-1{
                    if GlobalData.missingList[i].id == user.id{
                        var location = [String:Any]()
                        location["longitude"] = long
                        location["latitude"] = lat
                        location["user_id"] = Int(info[2])
                        location["beacon_id"] = Int(info[1])
                        let now = dateFormatter.now(format: "yyyy-MM-dd HH:mm:ss")
                        location["created_at"] = now
                        GlobalData.missingList[i].latestLocation = Location(arr: location)
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: Notification.Name(rawValue: "sync"), object: nil)
                        }
                    }
                }
            }
            
            if self.reachability.isReachable{
                api.reportFound(location: locationHistory)
            }else{
                GlobalData.offlineData.append(locationHistory)
                NSKeyedArchiver.archiveRootObject(GlobalData.offlineData, toFile: FilePath.offlineLocations())
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLBeaconRegion{
            print("Did enter region \(region.identifier)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLBeaconRegion{
            let info = region.identifier.components(separatedBy: "#")
            if info[0] != "common"{
                GlobalData.nearMe = GlobalData.nearMe.filter({$0.id?.description != info[1]})
                NotificationCenter.default.post(name: Notification.Name(rawValue: "updateHistory"), object: nil)
            }
        }
    }
    
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                let newVersion = Double(version)!
                let nowVersion = Double(currentVersion)!
                completion(newVersion >= nowVersion, nil)
                
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
}

