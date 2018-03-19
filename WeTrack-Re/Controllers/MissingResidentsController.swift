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
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadMissingResident), name: Notification.Name("refreshMissingResident"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncData), name: Notification.Name(rawValue: "sync"), object: nil)
        
    }
    
    @objc private func loadMissingResident(){
        alamofire.loadMissingResidents(viewController: self)
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
            alamofire.loadMissingResidents(viewController: self)
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
        Constant.token = UserDefaults.standard.string(forKey: "token")!
        
    }
    
    private func loadLocalData(){
        
        if Constant.role != 5 && Constant.isLogin == false{
            
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: FilePath.allResidents()) as? [Resident]{
                
                GlobalData.allResidents = dict
                
            }
            
            if let dict = NSKeyedUnarchiver.unarchiveObject(withFile: FilePath.relativePath()) as? [Resident]{
                
                GlobalData.relativeList = dict
                
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
        
    }
    
    @objc private func startMonitor(){
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        if GlobalData.currentRegionList.count <= 20{
            
            for region in GlobalData.currentRegionList{
               self.locationManager.startMonitoring(for: region)
            }
            
        }else{
            
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
        self.performSegue(withIdentifier: "detailSegue", sender: residents?[indexPath.item])
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
                detailController.resident = resident
            }
        }
    }
 

}
