//
//  ViewController.swift
//  WeTrack-Re
//
//  Created by Kyaw Lin on 28/2/18.
//  Copyright © 2018 Kyaw Lin. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import FirebaseAuth
import GoogleSignIn
import UserNotifications

class LoginController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    let alertController = UIAlertController(title: nil, message: "Please wait...\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.blue
        alertController.view.addSubview(spinnerIndicator)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.string(forKey: "device_token") == nil{
            spinnerIndicator.startAnimating()
            self.present(alertController, animated: true, completion: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(tokenRefreshed), name: Notification.Name.InstanceIDTokenRefresh, object: nil)
        }
    }
    
    @objc func tokenRefreshed(){
        self.alertController.dismiss(animated: true, completion: nil)
    }

    @IBAction func LoginAnonymous(_ sender: UIButton) {
        
        Constant.user_id = 0
        if UserDefaults.standard.string(forKey: "device_token") != nil{
            Constant.device_token = UserDefaults.standard.string(forKey: "device_token")!
            alamofire.createDeviceToken(viewController: self)
        }
        
        UserDefaults.standard.set("Anonymous", forKey: "username")
        UserDefaults.standard.set(Constant.user_id, forKey: "user_id")
        Constant.username = "Anonymous"
    }
    
    @IBAction func LoginGoogle(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        spinnerIndicator.startAnimating()
        
        if let error = error{
            print("Failed to log into Google: ", error)
            return
        }else{
            self.present(alertController, animated: true, completion: nil)
            print("Successfully log into Google", user)
            guard let idToken = user.authentication.idToken else {return}
            guard let accessToken = user.authentication.accessToken else {return}
            let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            Auth.auth().signIn(with: credentials, completion: { (user, error) in
                if let error = error{
                    print("Failed to create a Firebase User with Google account: ", error)
                    return
                }else{
                    guard let uid = user?.uid else {return}
                    print("user email login \(user?.email)")
                    
                    Constant.userphoto = user?.photoURL
                    
                    alamofire.loginWithEmail(email: (user?.email)!,viewController: self)
                }
            })
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}



