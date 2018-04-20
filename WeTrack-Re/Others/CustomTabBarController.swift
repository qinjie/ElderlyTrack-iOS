//
//  CustomTabBarController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 2/4/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //        let residentList = ResidentList(collectionViewLayout: UICollectionViewFlowLayout())
        //        let navigationController = UINavigationController(rootViewController: residentList)
        //        navigationController.title = "Missing Resident"
        //        navigationController.tabBarItem.image = UIImage(named: "residentf")
        //
        //
        //        let beaconController = BeaconController(collectionViewLayout: UICollectionViewFlowLayout())
        //        let secondNavigationController = UINavigationController(rootViewController: beaconController)
        //        secondNavigationController.title = "Beacon Detecting"
        //        secondNavigationController.tabBarItem.image = UIImage(named: "Onlinef")
        //
        //        let nearmeController = NearMeController(collectionViewLayout: UICollectionViewFlowLayout())
        //        let thirdNavigationController = UINavigationController(rootViewController: nearmeController)
        //        thirdNavigationController.title = "NearBy"
        //        thirdNavigationController.tabBarItem.image = UIImage(named: "Nearf")
        
        
        //        secondNavigationController.tabBarItem.image = UIImage(named: "geo")
        //        viewControllers = [navigationController, secondNavigationController]
        //        let messengerVC = UIViewController()
        //        let messengerNavigationController = UINavigationController(rootViewController: messengerVC)
        //        messengerNavigationController.title = "Messenger"
        //        messengerNavigationController.tabBarItem.image = UIImage(named: "messenger_icon")
        //
        //        let notificationsNavController = UINavigationController(rootViewController: UIViewController())
        //        notificationsNavController.title = "Notifications"
        //        notificationsNavController.tabBarItem.image = UIImage(named: "globe_icon")
        //
        //        let moreNavController = UINavigationController(rootViewController: UIViewController())
        //        moreNavController.title = "More"
        //        moreNavController.tabBarItem.image = UIImage(named: "more_icon")
        ////
        //          viewControllers = [navigationController, secondNavigationController, thirdNavigationController]
        
        
        
        tabBar.isTranslucent = false
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: 1000, height: 0.5)
        topBorder.backgroundColor = UIColor(red:0.90, green:0.91, blue:0.92, alpha:1.0).cgColor
        
        
        tabBar.layer.addSublayer(topBorder)
        tabBar.clipsToBounds = true
        Constant.role = UserDefaults.standard.integer(forKey: "role")
        
        if (Constant.role == 5){
            tabBar.items?[2].isEnabled = false
        }
        print("tabb \(tabBar.items?.count)")
        
        let selectedColor   = UIColor.selected
        let unselectedColor = UIColor.unselected
        //
        //        tabBar.unselectedItemTintColor = unselectedColor
        //
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: unselectedColor], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedStringKey.foregroundColor: selectedColor], for: .selected)
        
        
    }
    
    
    
    
    fileprivate func createDummyNavControllerWithTitle(_ title: String, imageName: String) -> UINavigationController {
        let viewController = UIViewController()
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = UIImage(named: imageName)
        return navController
    }
    
    
    
    
    // for important Data
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
