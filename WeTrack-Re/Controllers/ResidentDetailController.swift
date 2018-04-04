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
    var cellTitle = [String]()
    var cellText = [String]()
    var beaconsName = [String]()
    var section:Int?
    var hideSwitch: Bool = false
    
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
    
    func saveRelativeState(){
        if resident != nil{
            for i in 0...GlobalData.relativeList.count-1{
                if GlobalData.relativeList[i].id == resident?.id{
                    GlobalData.relativeList[i] = resident!
                }
            }
            NSKeyedArchiver.archiveRootObject(GlobalData.relativeList, toFile: FilePath.relativePath())
        }
    }
    
    func setup(){
        
        //Register for cell
        let nib = UINib(nibName: "ResidentDetailCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        
        cellTitle = ["NRIC","Birthday","Status","Remark"]
        cellText = [(resident?.nric)!,(resident?.dob)!,resident?.status == true ? "Missing":"Available",(resident?.remark.trimmingCharacters(in: .whitespaces))! == "" ? "No remark":(resident?.remark)!
            
        ]
        
        var beacon : Beacon?
        
        if resident?.latestLocation != nil{
            addressLabel.text = resident?.latestLocation?.address
            cellTitle.append("Beacon location")
            cellText.append((resident?.latestLocation?.address)!)
            
            let beacon_id = Int(resident!.latestLocation!.beacon_id)
            for item in (resident?.beacons)!{
                if item.id == beacon_id{
                    beacon = item
                    break
                }
            }
        }else{
            addressLabel.text = "No report"
        }
        
        if beacon != nil{
            cellTitle.append("Beacon detect")
            cellText.append(beacon!.name!)
        }
        
        if resident?.beacons?.count != 0 {
            beaconsName.removeAll()
            section = 2
            if resident?.beacons != nil{
                for beacon in (resident?.beacons)!{
                    let str = beacon.toString()
                    beaconsName.append(str)
                }
            }
        }else{
            section = 1
        }
        
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
            statusLabel.textColor = UIColor.redApp
            switchBtn.isOn = true
        }else{
            statusLabel.text = "Available"
            statusLabel.textColor = UIColor.mainApp
            switchBtn.isOn = false
        }
        
        if hideSwitch{
            switchBtn.isHidden = true
        }else{
            switchBtn.isHidden = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return section ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return cellTitle.count
        }else{
            return beaconsName.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0{
            return "ABOUT RESIDENT"
        }else{
            return "BEACONS LIST"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ResidentDetailCell
        
        if indexPath.section == 0{
            switch cellText[indexPath.row]{
            case "Missing":
                cell.cellText.textColor = UIColor.redApp
                break
            case "Available":
                cell.cellText.textColor = UIColor.mainApp
            default:
                cell.cellText.textColor = UIColor.black
            }
            
            if cellText[indexPath.row] != "" && cellTitle[indexPath.row] == "Remark"{
                cell.cellText.textColor = UIColor.redApp
            }
            
            if cellText[indexPath.row] == "No remark"{
                cell.cellText.textColor = UIColor.gray
            }
            
            cell.setData(title: cellTitle[indexPath.row], text: cellText[indexPath.row])
        }else{
            cell.setData(title: String(describing:"Beacon: "+String(describing:indexPath.row+1)), text: beaconsName[indexPath.row])
        }
        

        // Configure the cell...

        return cell
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
