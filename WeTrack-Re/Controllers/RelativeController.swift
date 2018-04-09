//
//  RelativeController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 7/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import SwiftyTimer

class RelativeController: UITableViewController {
    
    var relatives : [Resident]?
    
    fileprivate let cellID = "ResidentTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.refreshControl?.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        
        navigationItem.title = "Your relatives"
        
        self.relatives = GlobalData.relativeList
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshRelative), name: Notification.Name(rawValue: "refreshMissingResident"), object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc private func refreshRelative(){
        self.relatives = GlobalData.relativeList
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func reloadData(){
        Timer.after(1) {
            api.loadRelative(controller: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = sender as? IndexPath{
            
            let relative = relatives?[indexPath.item]
            
            let detailPage = segue.destination as! ResidentDetailController
            detailPage.toggleSwitch = true
            detailPage.resident = GlobalData.allResidents.filter({$0.id == relative?.id}).first!
            
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = relatives?.count{
            return count
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ResidentTableViewCell
        cell.setData(resident: (relatives?[indexPath.row])!, type: 1)

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detailSegue2", sender: indexPath)
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

}
