//
//  KumpeAppsSSO.swift
//  KumpeApps
//
//  Created by Justin Kumpe on 6/26/19.
//  Copyright © 2019 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import Base32
import OneTimePassword
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

//Note: The below imports will be required on any view controller using the API
//import Alamofire
//import SwiftyJSON
//import Alamofire_SwiftyJSON



class KumpeAppsSSO: UIViewController {

    
func postAccessLog(){
    let URL = "https://www.kumpeapps.com/api/access"
    let parameters: Parameters = ["_key":"DRgeJv9leTqdKNZacRk2","login":"\(self.username)","pass":"\(self.password)"]
    Alamofire.request(URL, method: .get, parameters: parameters, encoding: URLEncoding.default)
        .responseSwiftyJSON { dataResponse in
            let KappsArray = dataResponse.value!
            print(KappsArray)
            let Authenticated = KappsArray["ok"].stringValue
            self.QueryAccess = KappsArray["subscriptions"]["\(self.SSOQuery)"] != JSON.null
            self.FirstName = KappsArray["name_f"].stringValue
            self.LastName = KappsArray["name_l"].stringValue
            if(Authenticated == "true"){
                //Access Granted
                self.AccessGranted()
                self.view.endEditing(true)
            }else{
                print("\nError: \(KappsArray["msg"].stringValue)\n")
                //Configure Alert
                let alertController = UIAlertController(title: "Login Error", message:
                    "You have been denied access for the following reason(s): \(KappsArray["msg"]). \n\nPlease ensure you are using your KumpeApps username and password to login. If you need to reset your password please goto www.kumpeapps.com.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.destructive,handler: nil))
                
                //Display Alert
                self.present(alertController, animated: true, completion: nil)
                
                //Initiate Logoff
                self.Logout()
            }
            self.view.endEditing(true)
            self.activityIndicator.stopAnimating()
            
    }
    
    
    }
}
