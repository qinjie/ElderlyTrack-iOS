//
//  ResidentDetailController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 10/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit

class ResidentDetailController: UITableViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nricLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var status2Label: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    @IBOutlet weak var beaconDetectLabel: UILabel!
    @IBOutlet weak var beaconLocationLabel: UILabel!
    @IBOutlet weak var beaconBelongLabel: UILabel!
    
    var resident: Resident?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        
        if sender.isOn{
            
            let alertController = UIAlertController(title: "Report Missing Relative", message: "Remark", preferredStyle: UIAlertControllerStyle.alert)
            
            let reportAction = UIAlertAction(title: "Report", style: .default, handler: { (action:UIAlertAction) in
                let textField = alertController.textFields![0] as UITextField
                alamofire.reportMissingResident(resident: self.resident!, remark: textField.text!, viewController: self)
            })
            let cancelAction = UIAlertAction(title: "Calcel", style: .default, handler: { (action: UIAlertAction) in
                self.switchBtn.isOn = false
                self.statusLabel.text = "Available"
                self.statusLabel.textColor = UIColor.mainApp
                self.resident?.status = false
            })
            alertController.addAction(reportAction)
            alertController.addAction(cancelAction)
            alertController.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "Remark"
                textField.textAlignment = .center
            })
            self.present(alertController, animated: true, completion: nil)
            
        }else{
            alamofire.reportMissingResident(resident: self.resident!, remark: "", viewController: self)
        }
        
    }
    
    @IBAction func mapPressed(_ sender: UIButton) {
        
        let testURL = URL(string: "comgooglemaps://")
        
        if UIApplication.shared.canOpenURL(testURL!) && resident?.latestLocation != nil{
            let address = resident!.latestLocation!.address
            let latitude = resident!.latestLocation!.latitude
            let longitude = resident!.latestLocation!.longitude
            
            let directionRequest = "comgooglemaps://?q=\(address)&center=\(latitude),\(longitude)&zoom=15"
            let directionURL = URL(string: directionRequest)
            UIApplication.shared.open(directionURL!, options:[:], completionHandler: nil)
        }else{
            self.displayAlert(title: "Warning", message: "Address is not available!")
        }
        
    }
    
    private func setup(){
        if resident?.photo == nil || resident?.photo == ""{
            imageView.image = #imageLiteral(resourceName: "default_avatar")
        }else{
            if let url = NSURL(string: Constant.photoURL + (resident?.photo)!){
                let data = NSData(contentsOf: url as URL)
                if data != nil{
                    imageView.image = UIImage(data: data! as Data)
                }
            }
        }
        nameLabel.text = resident?.name
        statusLabel.text = resident?.status.description
        
        if resident?.status == true{
            statusLabel.text = "Missing"
            switchBtn.isOn = true
            status2Label.text = "Missing"
            status2Label.textColor = UIColor.redApp
        }else{
            statusLabel.text = "Available"
            switchBtn.isOn = false
            status2Label.text = "Available"
            status2Label.textColor = UIColor.mainApp
        }
        
        if !((resident?.isRelative)!){
            switchBtn.isHidden = true
        }
        
        var beacon : Beacon?
        
        if resident?.latestLocation != nil{
            addressLabel.text = resident?.latestLocation?.address
            beaconLocationLabel.text = resident?.latestLocation?.address
            
            let beacon_id = Int(resident!.latestLocation!.beacon_id)
            for item in (resident?.beacons)!{
                if item.id == beacon_id{
                    beacon = item
                    break
                }
            }
        }else{
            beaconLocationLabel.text = "Unknown"
        }
        
        if resident?.beacons?.count == 0 {
            beaconBelongLabel.text = "No beacon"
            beaconBelongLabel.textColor = UIColor.yellowApp
        }else{
            var text = ""
            if resident?.beacons != nil{
                for beacon in (resident?.beacons)!{
                    let str = beacon.toString()
                    text = text + " - " + str + "\n"
                }
                beaconBelongLabel.text = text
                beaconBelongLabel.textColor = UIColor.black
            }
        }
        
        if beacon != nil{
            beaconDetectLabel.text = beacon!.name
        }else{
            beaconDetectLabel.text = "Unknown"
        }
        
        nricLabel.text = resident?.nric
        dobLabel.text = resident?.dob
        remarkLabel.text = resident?.remark
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

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
