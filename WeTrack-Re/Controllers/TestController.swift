//
//  TestController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 7/4/61 BE.
//  Copyright © 2561 Kyaw Lin. All rights reserved.
//

import UIKit
import AWSAuthCore

class TestController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        Constant.user_id = UserDefaults.standard.integer(forKey: "user_id")
        if Constant.userphoto != nil{
            let photo = NSData(contentsOf: Constant.userphoto!)
            if photo != nil{
                imageView.image = UIImage(data: photo! as Data)
            }
        }else{
            imageView.image = #imageLiteral(resourceName: "default_avatar")
        }
        let location = LocationHistory(bId: "5", uId: "1", newlat: "1", newlong: "1")
        api.reportFound(location: location)
        
    }

    @IBAction func signOut(_ sender: UIButton) {
        AWSSignInManager.sharedInstance().logout { (success, error) in
            if let error = error{
                print("\(error.localizedDescription)")
            }else{
                print("Successfully logged out")
                if let appdelegate = UIApplication.shared.delegate as? AppDelegate{
                    appdelegate.resetAppToFirstController()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
