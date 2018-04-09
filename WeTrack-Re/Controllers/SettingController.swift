//
//  SettingController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 7/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import AWSAuthCore

class SettingController: UITableViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameLabel.text = Constant.username
        emailLabel.text = Constant.email
        navigationItem.title = "Setting"
        
        if Constant.role != 5 && Constant.userphoto != nil{
            let photo = NSData(contentsOf: Constant.userphoto!)
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
        if sender.isOn{
            Constant.notification = true
        }else{
            Constant.notification = false
        }
    }

    @IBAction func signOutPressed(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "disableScanning"), object: nil)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "logout"), object: nil)
        Constant.email = ""
        UserDefaults.standard.removeObject(forKey: "email")
        UserDefaults.standard.removeObject(forKey: "role")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "username")
        AWSSignInManager.sharedInstance().logout { (success, error) in
            if error != nil{
                print("Error logging out: \(String(describing: error?.localizedDescription))")
            }else{
                if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
                    appdelegate.resetAppToFirstController()
                }
            }
        }
        
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
