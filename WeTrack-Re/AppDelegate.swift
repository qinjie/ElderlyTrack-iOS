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
    var locationManager : CLLocationManager!
    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
    private var reachability : Reachability!
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        AWSDDLog.sharedInstance.logLevel = .info
        
        pinpoint = AWSPinpoint(configuration: AWSPinpointConfiguration.defaultPinpointConfiguration(launchOptions: launchOptions))
        
        if let email = UserDefaults.standard.string(forKey: "email"){
            Constant.email = email
        }
        UIApplication.shared.statusBarStyle = .lightContent
        
        if UserDefaults.standard.string(forKey: "token") == nil {
            let loginController = mainStoryboard.instantiateViewController(withIdentifier: "Login") as! UINavigationController
            self.window?.rootViewController = loginController
        }else{
            let residentController = mainStoryboard.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
            self.window?.rootViewController = residentController
        }
        
        self.reachability = Reachability()
        do{
            try self.reachability.startNotifier()
        }catch{
            print("\(error.localizedDescription)")
        }
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: .alert) { (success, error) in
            if success{
                print("granted noti")
                UserDefaults.standard.set(true, forKey: "notification")
                
                DispatchQueue.main.async {
                    var userNotificationTypes : UIUserNotificationType
                    userNotificationTypes = [.alert, .badge, .sound]
                    let notificaitonSettings = UIUserNotificationSettings.init(types: userNotificationTypes, categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(notificaitonSettings)
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }else{
                print("denied noti")
                UserDefaults.standard.set(false, forKey: "notification")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(notification:)), name: ReachabilityChangedNotification, object: nil)
        
        
        application.registerForRemoteNotifications()
        
        print("pinpoint: " + String(describing: pinpoint?.targetingClient.currentEndpointProfile()))
        
        return AWSMobileClient.sharedInstance().interceptApplication(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return AWSMobileClient.sharedInstance().interceptApplication(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        pinpoint!.notificationManager.interceptDidRegisterForRemoteNotifications(withDeviceToken: deviceToken)
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pinpoint!.notificationManager.interceptDidReceiveRemoteNotification(userInfo, fetchCompletionHandler: completionHandler)
        
        if (application.applicationState == .active){
            let alert = UIAlertController(title: "Notification Received", message: userInfo.description, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
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
                    
                    alamofire.reportFoundResident(location: location)
                    
                }
            }
        }else{
            print("Network not reachable")
        }
        
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
            let now = dateFormatter.now(format: "yyyy-MM-dd HH:mm:ss")
            if let lastTime = GlobalData.residentStatus[info[2]]{
                let timeInterval = dateFormatter.format(string: now, format: "yyyy-MM-dd HH:mm:ss").timeIntervalSince(dateFormatter.format(string: lastTime, format: "yyyy-MM-dd HH:mm:ss"))
                if timeInterval >= 3600{
                    notification.presentNotification(title: "Beacon detected", body: "\(info[0]) is nearby.", timeInterval: 1, repeats: false, identifier: info[0])
                }
            }else{
                GlobalData.residentStatus[info[2]] = now
                notification.presentNotification(title: "Beacon detected", body: "\(info[0]) is nearby.", timeInterval: 1, repeats: false, identifier: info[0])
            }
            
            let beacon = GlobalData.beaconList.first(where: {$0.id?.description == info[1]})
            let resident = GlobalData.allResidents.first(where: {$0.id.description == info[2]})
            if beacon != nil && resident != nil{
                resident?.report = now
                beacon?.report = now
            }
            
            if !GlobalData.nearMe.contains(where: {$0.id == beacon?.id}){
                GlobalData.nearMe.append(beacon!)
            }
            
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateHistory"), object: nil)
            DispatchQueue.global().async {
                let lat = self.locationManager.location?.coordinate.latitude
                let long = self.locationManager.location?.coordinate.longitude
                let locationHistory = LocationHistory(bId: info[1], uId: info[2], newlat: String(describing: lat), newlong: String(describing: long))
                
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
                    alamofire.reportFoundResident(location: locationHistory)
                }else{
                    GlobalData.offlineData.append(locationHistory)
                    NSKeyedArchiver.archiveRootObject(GlobalData.offlineData, toFile: FilePath.offlineLocations())
                }
            }
        case .outside:
            print("Outside region \(region.identifier)")
        case .unknown:
            print("Region unknown")
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
            GlobalData.nearMe = GlobalData.nearMe.filter({$0.id?.description != info[2]})
            NotificationCenter.default.post(name: Notification.Name(rawValue: "updateHistory"), object: nil)
        }
    }
    
}

