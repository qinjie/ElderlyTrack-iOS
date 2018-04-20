//
//  SettingController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 7/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import AWSAuthCore
import UserNotifications

class SettingController: UITableViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = Constant.username
        emailLabel.text = Constant.email
        navigationItem.title = "Setting"
        
        let photoURL = UserDefaults.standard.url(forKey: "userphoto")
        
        if photoURL != nil{
            let photo = NSData(contentsOf: photoURL!)
            if photo != nil{
                imageView.image = UIImage(data: photo! as Data)
            }
        }else{
            imageView.image = #imageLiteral(resourceName: "default_avatar")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let notification = Bool(UserDefaults.standard.string(forKey: "notification")!){
            if notification == true{
                notificationSwitch.isOn = true
            }else{
                notificationSwitch.isOn = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteData(){
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "role")
        UserDefaults.standard.removeObject(forKey: "email")
    }
    
    @IBAction func switchNotiPressed(_ sender: UISwitch) {
        api.disableEndpoint(controller: self)
    }
    
    func setSwitch(){
        notificationSwitch.isOn = true
        Constant.notification = true
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (setting) in
            if setting.alertSetting.rawValue == 2{
                //Enabled
            }else{
                //Not Enabled
                let actionOK = UIAlertAction(title: "Setting", style: .default) { (_) in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl){
                        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: { (success) in
                            print("Success")
                        })
                    }
                }
                self.displayAlert(title: "Notification", message: "Please allow the notification in the setting", actions: [actionOK])
            }
        })
        UserDefaults.standard.set(String(describing: notificationSwitch.isOn), forKey: "notification")
    }
    
    func unsetSwitch(){
        notificationSwitch.isOn = false
        Constant.notification = true
        UIApplication.shared.unregisterForRemoteNotifications()
        UserDefaults.standard.set(String(describing: notificationSwitch.isOn), forKey: "notification")
    }

    @IBAction func signOutPressed(_ sender: UIButton) {
        
        self.showLoadingHUD()
        
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
            if !appdelegate.isInternetAvailable(){
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                self.displayAlert(title: "Internet not available", message: "Please check your internet before continue.", actions: [alertAction])
                return
            }
        }
        
        AWSSignInManager.sharedInstance().logout { (success, error) in
            self.hideLoadingHUD()
            if error != nil{
                print("Error logging out: \(String(describing: error?.localizedDescription))")
            }else{
                NotificationCenter.default.post(name: Notification.Name(rawValue: "disableScanning"), object: nil)
                NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
                Constant.email = ""
                UserDefaults.standard.removeObject(forKey: "email")
                UserDefaults.standard.removeObject(forKey: "role")
                UserDefaults.standard.removeObject(forKey: "token")
                UserDefaults.standard.removeObject(forKey: "user_id")
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.removeObject(forKey: "userphoto")
                if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
                    appdelegate.resetAppToFirstController()
                }
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
