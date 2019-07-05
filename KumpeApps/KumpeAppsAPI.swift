//
//  API.swift
//  KumpeApps
//
// This swift file adds the required functionality for apps within the KumpeApps domain to access the KumpeApps mySQL API V2
//
//  Created by Justin Kumpe on 12/20/18.
//  Copyright © 2018 Justin Kumpe. All rights reserved.
//

import Foundation
import UIKit
import Base32
import OneTimePassword

//Note: The below imports will be required on any view controller using the API
//import Alamofire
//import SwiftyJSON
//import Alamofire_SwiftyJSON

class KumpeAppsAPI: UIViewController {
    
    let url = "https://sql.kumpedns.us/API/mysql_v2.php"
    
    let sqlUser = UserDefaults.standard.string(forKey: "sqlUser")!
    let sqlPass = UserDefaults.standard.string(forKey: "sqlPass")!
    
    var username = ""
    
    func setParams(sqlUser: String, sqlPass: String, otpSecret: String, appName: String){
        //KumpeApps API Settings
         UserDefaults.standard.set(sqlUser, forKey: "sqlUser")
         UserDefaults.standard.set(sqlPass, forKey: "sqlPass")
         UserDefaults.standard.set(otpSecret, forKey: "OTP_Secret")
         UserDefaults.standard.set(sqlPass, forKey: "App_Name")
    }
    
    
    
    func getOTP() -> String{
        
        let OTP_Secret = UserDefaults.standard.string(forKey: "OTP_Secret")!
        let name = UserDefaults.standard.string(forKey: "App_Name")!
        let issuer = "KumpeApps"
        let secretString = OTP_Secret
        
        guard let secretData = MF_Base32Codec.data(fromBase32String: secretString),
            !secretData.isEmpty else {
                print("Invalid OTP Secret")
                
                return ""
        }
        
        guard let generator = Generator(
            factor: .timer(period: 30),
            secret: secretData,
            algorithm: .sha1,
            digits: 6) else {
                print("Invalid generator parameters")
                return ""
        }
        
        let token = Token(name: name, issuer: issuer, generator: generator)
        print("Token: \(token)")
        let password = token.currentPassword
        print("Password: \(password!)")
        return password!
    }
    
    
    
    //Template for SQL to JSON Pull
    //    func sqlTemplate(){
    //        self.KidArray = Array < String >()
    //        let sqlDatabase = "Apps_KKids"
    //        let sqlTable = "Users"
    //        let sqlSelect = "*"
    //        let sqlWhere = "Master_Account = '' AND isAdmin != 'Yes' AND isDisabled != 'Yes'"
    //        let sqlQuery = "SELECT \(sqlSelect) FROM \(sqlTable) WHERE \(sqlWhere)"
    //        print(sqlQuery)
    //        let parameters: Parameters = ["sql_username":API().sqlUser,"password":API().sqlPass,"database":"\(sqlDatabase)","sql":"\(sqlQuery)","app_username":"\(self.username)","otp":API().getOTP()]
    //       Alamofire.request(API().url, method: .post, parameters: parameters, encoding: URLEncoding.default)
    //           .responseSwiftyJSON { dataResponse in
    //               if dataResponse.value != nil{
    //                   let KidJSON = dataResponse.value!
    //                   print("Counts: \(KidJSON.count)")
    //                   for i in 0 ..< KidJSON.count
    //                   {
    //
    //                       self.KidArray.append(KidJSON[i]["Username"].stringValue)
    //
    //                   }
    //                   self.tableview.isHidden = false
    //                   self.tableview.reloadData()
    //                   self.ActivityIndicator.stopAnimating()
    //               }else{
    //                   let alertController = UIAlertController(title: "Error", message:
    //                       "No Data Found", preferredStyle: UIAlertController.Style.alert)
    //                   alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.destructive,handler: nil))
    //
    //                   //Display Alert
    //                   self.present(alertController, animated: true, completion: nil)
    //               }
    //       }
    //   }
    
    
}
