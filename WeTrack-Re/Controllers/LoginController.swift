//
//  ViewController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 28/2/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import Alamofire
import UserNotifications
import AWSAuthUI
import AWSAuthCore
import GoogleSignIn

class LoginController: UIViewController {
    
    let alertController = UIAlertController(title: nil, message: "Please wait...\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.blue
        alertController.view.addSubview(spinnerIndicator)

    }
    
    override func viewDidAppear(_ animated: Bool) {
//        if UserDefaults.standard.string(forKey: "device_token") == nil{
//            spinnerIndicator.startAnimating()
//            self.present(alertController, animated: true, completion: nil)
//        }
    }
    
    @objc func tokenRefreshed(){
        self.alertController.dismiss(animated: true, completion: nil)
    }

    @IBAction func LoginAnonymous(_ sender: UIButton) {
        
        api.loginAnonymous(controller: self)
        Constant.userphoto = nil
    }
    
    @IBAction func LoginGoogle(_ sender: UIButton) {
        if !AWSSignInManager.sharedInstance().isLoggedIn {
            AWSAuthUIViewController
                .presentViewController(with: self.navigationController!,
                                       configuration: nil,
                                       completionHandler: { (provider: AWSSignInProvider, error: Error?) in
                                        if error != nil {
                                            print("Error occurred: \(String(describing: error))")
                                        } else {
                                            // Sign in successful.
                                            print("Sign in successful, useID: " + String(describing: GIDSignIn.sharedInstance().currentUser.profile.email))
                                            Constant.email = GIDSignIn.sharedInstance().currentUser.profile.email
                                            if GIDSignIn.sharedInstance().currentUser.profile.hasImage{
                                                Constant.userphoto = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 120)
                                                UserDefaults.standard.set(Constant.userphoto, forKey: "userphoto")
                                            }
                                            api.loginWithEmail(controller: self)
                                        }
                })
        }else{
            Constant.email = GIDSignIn.sharedInstance().currentUser.profile.email
            if GIDSignIn.sharedInstance().currentUser.profile.hasImage{
                Constant.userphoto = GIDSignIn.sharedInstance().currentUser.profile.imageURL(withDimension: 120)
            }
            api.loginWithEmail(controller: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? UITabBarController{
            if Constant.username == "Anonymous"{
                destination.tabBar.items![2].isEnabled = false
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



