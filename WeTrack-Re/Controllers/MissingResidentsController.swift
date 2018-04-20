//
//  MissingResidentsController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 6/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications
import SwiftyTimer

class MissingResidentsController: UITableViewController, CLLocationManagerDelegate {
    
    fileprivate let cellID = "ResidentTableViewCell"
    
    var newRegionList = [CLBeaconRegion]()
    var residents : [Resident]?
    var monitorLimit = 20
    
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        requestLocationService()
        setupTableView()
        loadUserDefaults()
        loadLocalData()
        
        self.loadMissingResident()
        api.loadDistinctUUID(controller: self)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore{
            print("First launch, setting Userdefault.")
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
                    appdelegate.registerNotification()
            }
            GlobalData.showNotification = false
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMissingResident), name: Notification.Name("refreshMissingResident"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncData), name: Notification.Name(rawValue: "sync"), object: nil)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if GlobalData.showNotification == true{
            let actionAllow = UIAlertAction(title: "Allow", style: .default, handler: { (_) in
                print("allowed")
                UIApplication.shared.registerForRemoteNotifications()
                UserDefaults.standard.set("true", forKey: "notification")
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (setting) in
                    if setting.alertSetting.rawValue == 2{
                        //Enabled
                    }else{
                        //Not Enabled
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl){
                            UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                                print("Success")
                            })
                        }
                    }
                })
            })
            let actionDenied = UIAlertAction(title: "Don't Allow", style: .default, handler: { (_) in
                print("denied")
                UIApplication.shared.unregisterForRemoteNotifications()
                UserDefaults.standard.set("false", forKey: "notification")
            })
            self.displayAlert(title: "\"ElderlyTrack\" Would Like to Send You Notifications", message: "Notifications may include alerts, sounds and icon badges. These can be configured in Settings.", actions: [actionDenied, actionAllow])
            GlobalData.showNotification = false
        }
    }
    
    @objc private func loadMissingResident(){
        api.loadMissingResidents(controller: self)
    }
    
    @objc private func syncData(){
        self.residents = GlobalData.missingList
        self.tableView.reloadData()
    }
    
    private func setupTableView(){
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
    }
    
    @objc func reloadData(){
        
        Timer.after(1) {
            api.loadMissingResidents(controller: self)
            api.loadDistinctUUID(controller: self)
        }
        
        Timer.after(6) {
            if (self.tableView.refreshControl?.isRefreshing)!{
                self.tableView.refreshControl?.endRefreshing()
            }
        }
        
    }
    
    private func requestLocationService(){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate{
            appDelegate.requestLocationService()
        }
    }
    
    private func loadUserDefaults(){
        
        Constant.username = UserDefaults.standard.string(forKey: "username")!
        Constant.user_id = UserDefaults.standard.integer(forKey: "user_id")
        Constant.role = UserDefaults.standard.integer(forKey: "role")
        //Constant.token = UserDefaults.standard.string(forKey: "token")!
        
    }
    
    private func loadLocalData(){
        
        if Constant.role != 5 && Constant.isLogin == false{
            
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: FilePath.allResidents()) as? [Resident]{
                GlobalData.allResidents = dict
            }
            
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: FilePath.relativePath()) as? [Resident]{
                GlobalData.relativeList = dict
            }
            
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: FilePath.beaconList()) as? [Beacon]{
                GlobalData.beaconList = dict
            }
            
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: FilePath.distinctBeacon()) as? [Beacon]{
                GlobalData.distinctBeacons = dict
            }
            
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: FilePath.reportedHistory()) as? [ReportedHistory]{
                GlobalData.reportedHistory = dict
            }
            
        }
        
    }
    
    private func setupNotifications(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(startMonitor), name: Notification.Name(rawValue: "enableScanning"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopMonitor), name: Notification.Name(rawValue:"disableScanning"), object: nil)
        
    }
    
    func switchMornitoringList(){
        
        for region in locationManager.monitoredRegions{
            locationManager.stopMonitoring(for: region)
        }
        
        if newRegionList.count > 0 {
            
            GlobalData.currentRegionList = newRegionList
            startMonitor()
            
        }
        
        if GlobalData.distinctBeacons.count > 0{
            
            startMonitorCommon()
            
        }
        
    }
    
    @objc func startMonitorCommon(){
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        if GlobalData.distinctBeacons.count <= 20{
            for i in 0...GlobalData.distinctBeacons.count-1{
                let uuid = NSUUID(uuidString: GlobalData.distinctBeacons[i].uuid!)! as UUID
                let identifier = GlobalData.distinctBeacons[i].identifier
                let commonRegion = CLBeaconRegion(proximityUUID: uuid, identifier: identifier!)
                self.locationManager.startMonitoring(for: commonRegion)
            }
        }
        
    }
    
    @objc private func startMonitor(){
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        if (GlobalData.currentRegionList.count + GlobalData.distinctBeacons.count) <= monitorLimit{
            
            for region in GlobalData.currentRegionList{
               self.locationManager.startMonitoring(for: region)
            }
            
        }else{
            
            GlobalData.backgroundStartTime = Date()
            GlobalData.totalGroup = GlobalData.currentRegionList.count/(monitorLimit-GlobalData.distinctBeacons.count) + (GlobalData.currentRegionList.count%(monitorLimit-GlobalData.distinctBeacons.count) > 0 ? 1:0)
            GlobalData.currentGroup = 1
            for i in 0...(monitorLimit-1-GlobalData.distinctBeacons.count){
                locationManager.startMonitoring(for: GlobalData.currentRegionList[i])
            }
            refreshList()
        }
        
    }
    
    private func refreshList(){
        
        let time = GlobalData.backgroundStartTime
        let now = Date()
        let timeInterval = now.timeIntervalSince(time)
        if timeInterval < 60{
            print("Time remaining \(60 - timeInterval)")
            print("Current group \(GlobalData.currentGroup)")
            stopMonitorSpecific()
            var check = Bool()
            for i in 1...GlobalData.totalGroup{
                if GlobalData.currentGroup == i{
                    if i == GlobalData.totalGroup && check == false{
                        GlobalData.currentGroup = 1
                        check = false
                    }else{
                        if check == false{
                            GlobalData.currentGroup = i + 1
                            check = true
                        }
                    }
                }
            }
            print("Next group \(GlobalData.currentGroup)")
            let limit = (monitorLimit - GlobalData.distinctBeacons.count)
            let start = (GlobalData.currentGroup - 1)*limit
            if (GlobalData.currentRegionList.count - start) > limit{
                for i in 0...limit-1{
                    locationManager.startMonitoring(for: GlobalData.currentRegionList[i+start])
                }
            }else{
                if GlobalData.currentRegionList.count > 0 {
                    for i in 0...(GlobalData.currentRegionList.count - start) - 1{
                        locationManager.startMonitoring(for: GlobalData.currentRegionList[i+start])
                    }
                }
            }
            
        }
        Timer.after(3) {
            self.refreshList()
        }
        
    }
    
    private func stopMonitorSpecific(){
        for region in self.locationManager.monitoredRegions{
            let info = region.identifier.components(separatedBy: "#")
            if info[0] != "common"{
                self.locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    @objc private func stopMonitor(){
        NotificationCenter.default.post(name: Notification.Name(rawValue: "stopMonitor"), object: nil)
        for region in self.locationManager.monitoredRegions{
            self.locationManager.stopMonitoring(for: region)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return residents?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ResidentTableViewCell
        // Configure the cell...
        let type = (self.residents?[indexPath.row].beacons?.count)! > 0 ? false : true
        cell.setData(resident: (self.residents?[indexPath.row])!, warning: type)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (residents?[indexPath.item].isRelative)!{
            self.performSegue(withIdentifier: "detailSegue", sender: residents?[indexPath.item])
        }else{
            self.performSegue(withIdentifier: "detailAnonymousSegue", sender: residents?[indexPath.item])
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let resident = sender as? Resident{
            if let detailController = segue.destination as? ResidentDetailController{
                detailController.hideSwitch = true
                detailController.resident = resident
            }
            if let detailAnonumous = segue.destination as? ResidentDetailAnonumousController{
                detailAnonumous.resident = resident
            }
        }
    }
 

}
