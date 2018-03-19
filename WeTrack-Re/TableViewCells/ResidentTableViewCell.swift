//
//  ResidentTableViewCell.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 5/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import SDWebImage

class ResidentTableViewCell: UITableViewCell {

    @IBOutlet weak var lastSeenLabel: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var statusImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(resident: Resident, type: Int = 0){
        
        self.nameLabel.text = resident.name
        if resident.latestLocation != nil{
            self.addressLabel.text = resident.latestLocation!.address
            self.lastSeenLabel.text = "Last seen at " + resident.latestLocation!.created_at
        }
        
        let url = URL(string: Constant.photoURL + resident.photo)
        self.imgView.sd_setImage(with: url, placeholderImage: UIImage(named: "default_avatar"))
        if type == 0{
            self.statusImgView.isHidden = true
        }else{
            self.statusImgView.isHidden = false
        }
        if resident.status == "true"{
            self.statusImgView.image = #imageLiteral(resourceName: "CircleRed")
        }else{
            self.statusImgView.image = #imageLiteral(resourceName: "CircleBlue")
        }
    }
    
    func setData(resident: Resident, warning:Bool = false){
        self.nameLabel.text = resident.name                                                                                                                         
        if resident.latestLocation != nil{
            self.addressLabel.text = resident.latestLocation!.address
            self.lastSeenLabel.text = "Last seen at " + resident.latestLocation!.created_at
        }
        
        let url = URL(string: Constant.photoURL + resident.photo)
        self.imgView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "default_avatar"))
        if warning == false{
            self.statusImgView.isHidden = true
        }else{
            self.statusImgView.image = #imageLiteral(resourceName: "warning")
            self.statusImgView.isHidden = false
        }
    }
    
    func setData(resident: Resident){
        self.lastSeenLabel.isHidden = true
        self.statusImgView.isHidden = true
        self.addressLabel.text = "Nearby"
        self.nameLabel.text = resident.name
        let url = URL(string: Constant.photoURL + resident.photo)
        self.imgView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "default_avatar"))
    }
    
}
