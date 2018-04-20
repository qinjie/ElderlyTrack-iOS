//
//  ResidentDetailCell.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 4/4/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit

class ResidentDetailCell: UITableViewCell {
    
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellText: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    var beacon:Beacon?
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        toggleSwitch.isHidden = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(title:String, text:String){
        cellTitle.text = title
        cellText.text = text
    }
    
    func setData(title:String, beacon:Beacon){
        cellTitle.text = title
        self.beacon = beacon
        cellText.text = beacon.toString()
        switch beacon.status{
        case 2:
            toggleSwitch.isOn = false
        case 1:
            toggleSwitch.isOn = true
        default:
            toggleSwitch.isOn = false
        }
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        api.disableBeacon(beacon: beacon!)
    }
}
