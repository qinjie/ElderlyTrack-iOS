//
//  AlertController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 10/3/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import MBProgressHUD
extension UIViewController{
    
    func displayAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert  )
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func displayAlert(title: String, message: String, actions: [UIAlertAction]){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        for action in actions{
            alertController.addAction(action)
        }
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showLoadingHUD(){
        let hud = MBProgressHUD.showAdded(to: self.view,animated: true)
        hud.backgroundColor = UIColor.clear
        hud.tintColor = UIColor.clear
        hud.shadowColor = UIColor.clear
        hud.contentColor = UIColor.mainApp
        hud.bezelView.color = UIColor.clear
        hud.bezelView.style = .solidColor
    }
    
    func hideLoadingHUD(){
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func convertUUID(string: String) -> UUID{
        return NSUUID(uuidString: string)! as UUID
    }
}
