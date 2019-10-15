//
//  KumpeAppsSSO.swift
//  KumpeApps
//
// This swift file adds the required functionality for apps within the KumpeApps domain for SSO Authentication
//
//  Created by Justin Kumpe on 10/13/19.
//  Copyright © 2019 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import Base32
import OneTimePassword

import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

//Note: The below imports will be required on any view controller using the API
//import Alamofire
//import SwiftyJSON
//import Alamofire_SwiftyJSON

public class KumpeAppsSSO: UIViewController {
public static let shared = KumpeAppsAPI()
public let url = "https://sql.kumpedns.us/API/mysql_v2.php"
public static let keychainSSOLegacy = KeychainWrapper(serviceName: "KumpeAppsSSO", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso")
public static let keychainSSOOTP = KeychainWrapper(serviceName: "KumpeAppsSSO_OTP", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.otp")
public static let keychainSSOSecure = KeychainWrapper(serviceName: "KumpeAppsSSO_Secure", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.secure")
public static let keychainSSOAccess = KeychainWrapper(serviceName: "KumpeAppsSSO_Access", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.access")
public static let keychainSSOUser = KeychainWrapper(serviceName: "KumpeAppsSSO_User", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.user")

    public func setParams(apikey: String){
    //KumpeApps API Settings
     let formatter = DateFormatter()
     // initially set the format based on your datepicker date / server String
     formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
     
     let myString = formatter.string(from: Date()) // string purpose I add here
     // convert your string to date
     let yourDate = formatter.date(from: myString)
     //then again set the date format whhich type of output you need
     formatter.dateFormat = "dd-MMM-yyyy"
     // again convert your date to string
    params.CurrentDate = formatter.string(from: yourDate!)
        params.apikey = apikey

}

//    Parameters
public struct params {
    public static var username = ""
    public static var FirstName = ""
    public static var LastName = ""
    public static var CurrentDate = ""
    public static var apikey = ""
}
    
    
    func PollKumpeApps(username: String, password: String){
        sleep(1)
        let URL = "https://www.kumpeapps.com/api/check-access/by-login-pass"
        let parameters: Parameters = ["_key":"\(params.apikey)","login":"\(username)","pass":"\(password)"]
        Alamofire.request(URL, method: .get, parameters: parameters, encoding: URLEncoding.default)
            .responseSwiftyJSON { dataResponse in
                if dataResponse.value != nil{
                    let KappsArray = dataResponse.value!
                print(KappsArray)
                let Authenticated = KappsArray["ok"].stringValue
                params.FirstName = KappsArray["name_f"].stringValue
                params.LastName = KappsArray["name_l"].stringValue
                if(Authenticated == "true"){
                   //Access Granted
                    self.AccessGranted(username: username, password: password)
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
                    self.logoff()
                }
                self.view.endEditing(true)
                }else{
                    let alertController = UIAlertController(title: "Error", message:
                        "KumpeApps SSO Servers are currently down.  Please try again in a few min.", preferredStyle: UIAlertController.Style.alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.destructive,handler: nil))
                    
                    //Display Alert
                    self.present(alertController, animated: true, completion: nil)
                }
                
        }
        
        
    }
    
    public func logoff(){
        _ = KumpeAppsSSO.keychainSSOAccess.removeAllKeys()
    }
    
    func AccessGranted(username: String, password: String){
     // _ = keychainSSOLegacy.removeAllKeys()
        _ = KumpeAppsSSO.keychainSSOAccess.removeAllKeys()
     
     //Start SecureSSO Keychain
        KumpeAppsSSO.keychainSSOSecure.set("\(username)", forKey: "Username")
        KumpeAppsSSO.keychainSSOSecure.set("\(password)", forKey: "Password")
        KumpeAppsSSO.keychainSSOSecure.set("\(params.CurrentDate)", forKey: "AuthDate")
     //End SecureSSO Keychain
     
     //Start SSOUser Keychain
     KumpeAppsSSO.keychainSSOUser.set("\(username)", forKey: "Username")
     KumpeAppsSSO.keychainSSOUser.set("\(params.FirstName)", forKey: "FirstName")
     KumpeAppsSSO.keychainSSOUser.set("\(params.LastName)", forKey: "LastName")
     KumpeAppsSSO.keychainSSOUser.set("\(params.CurrentDate)", forKey: "AuthDate")
     //End SSOUser Keychain
     
     //Start SSOAccess Keychain
     KumpeAppsSSO.keychainSSOAccess.set("\(params.CurrentDate)", forKey: "AuthDate")
     let sqlDatabase = "Apps_SSO"
     let sqlTable = "SSO_Access_List"
     let sqlSelect = "*"
     let sqlWhere = "username = '\(username)'"
     let sqlQuery = "SELECT \(sqlSelect) FROM \(sqlTable) WHERE \(sqlWhere)"
        let parameters: Parameters = ["sql_username":KumpeAppsAPI.params.sqlUser,"password":KumpeAppsAPI.params.sqlPass,"database":"\(sqlDatabase)","sql":"\(sqlQuery)","app_username":"\(username)","otp":KumpeAppsAPI.shared.getOTP()]
        Alamofire.request(KumpeAppsAPI.params.url, method: .post, parameters: parameters, encoding: URLEncoding.default)
         .responseSwiftyJSON { dataResponse in
             if dataResponse.value != nil{
                 let JSONArray = dataResponse.value!
             print("Response: \(JSONArray)")
             for i in 0 ..< JSONArray.count
             {
                 //Builds Access for each app pulled from KumpeApps with SSO Tag
                 let AccessTag = JSONArray[i]["product_id"].stringValue
//                 let OTP_Secret = JSONArray[i]["OTP_Secret"].stringValue

                 let SSOAccessTag = "AccessTo\(AccessTag)"
                 print("Count: \(JSONArray.count)")
                 //JSONArray[i]["Product_Name"].stringValue
                 
                 KumpeAppsSSO.keychainSSOAccess.set(true, forKey: "\(SSOAccessTag)")
                 print("AccessTo\(AccessTag)")
                 print("\(KumpeAppsSSO.keychainSSOAccess.bool(forKey: "\(SSOAccessTag)")!)")
//                 self.keychainSSOSecure.set("\(OTP_Secret)", forKey: "OTP_Secret")
                 
             }
             
             }else{
                
                let alertController = UIAlertController(title: "Error", message:
                    "KumpeApps SSO Servers are currently down.  Please try again in a few min.", preferredStyle: UIAlertController.Style.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.destructive,handler: nil))
                
                //Display Alert
                self.present(alertController, animated: true, completion: nil)
                
             }
     }
     //End SSOAccess Keychain
    
    
}
}
