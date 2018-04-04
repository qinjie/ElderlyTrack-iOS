//
//  NearbyCell.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 4/4/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit

class NearbyCell: UITableViewCell {

  
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var beacon_id: UILabel!
    @IBOutlet var toggleSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchPressed(_ sender: UISwitch) {
        
    }
    
    func setData(beacon: Beacon){
        beacon_id.text = beacon.toString()
        let resident = GlobalData.allResidents.filter({$0.id == beacon.resident_id?.description}).first
        if resident?.isRelative == false{
            self.nameLabel.text = ""
            for _ in 0...(resident?.name.characters.count)!-1{
                self.nameLabel.text?.append("#")
            }
            imageView2.image = #imageLiteral(resourceName: "default_avatar")
        }else{
            self.nameLabel.text = resident?.name
            let url = URL(string: Constant.photoURL + (resident?.photo)!)
            imageView2.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "default_avatar"))
        }
    }
    
}
