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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(title:String, text:String){
        cellTitle.text = title
        cellText.text = text
    }
    
}
