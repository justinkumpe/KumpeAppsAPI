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
import BiometricAuthentication
import SwiftKeychainWrapper
import Alamofire
import SwiftyJSON
import Alamofire_SwiftyJSON

//Note: The below imports will be required on any view controller using the API
//import Alamofire
//import SwiftyJSON
//import Alamofire_SwiftyJSON

public class KumpeAppsSSO: UIViewController {
public static let shared = KumpeAppsSSO()
public let url = "https://sql.kumpedns.us/API/mysql_v2.php"
let keychainSSOSecure = KeychainWrapper(serviceName: "KumpeAppsSSO_Secure", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.secure")
public static let keychainSSOAccess = KeychainWrapper(serviceName: "KumpeAppsSSO_Access", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.access")
public static let keychainSSOUser = KeychainWrapper(serviceName: "KumpeAppsSSO_User", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.user")
    
    
    
    @IBOutlet weak public var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak public var fieldUsername: UITextField!
    @IBOutlet weak public var fieldPassword: UITextField!
    
    @IBOutlet weak public var buttonLogin: UIButton!
    @IBOutlet weak public var buttonFaceID: UIButton!
    @IBOutlet weak public var buttonFingerPrint: UIButton!
    

//    Parameters
public struct params {
    public static var username = ""
    public static var FirstName = ""
    public static var LastName = ""
    public static var CurrentDate = ""
    public static var apikey = ""
    public static var pollMessage = ""
    public static var appScheme = ""
    public static var productCode = ""
    public static let s = UIStoryboard (
        name: "Main", bundle: Bundle(for: KumpeAppsSSO.self)
    )
    public static let loginvc = s.instantiateInitialViewController()!
}
    
    override public func viewDidLoad() {
        print("SSO View Did Load")
        
        if BioMetricAuthenticator.shared.faceIDAvailable() &&  self.keychainSSOSecure.string(forKey: "Username") != nil &&  self.keychainSSOSecure.string(forKey: "Password") != nil{
            self.buttonFaceID.isHidden = false
        }
        
        if BioMetricAuthenticator.shared.touchIDAvailable() &&  self.keychainSSOSecure.string(forKey: "Username") != nil &&  self.keychainSSOSecure.string(forKey: "Password") != nil {
            self.buttonFingerPrint.isHidden = false
        }
        
        self.activityIndicator.stopAnimating()
        self.fieldPassword.text = ""
        if params.apikey == "Disable"{
            alert(title: "KumpeAppsSSO API Key is missing.", message: "The developer of this app has not set the apikey parameter. This parameter must be set to utilize KumpeApps signon")
            sleep(3)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @IBAction public func actionUsername(_ sender: Any) {
        self.fieldPassword.becomeFirstResponder()
    }
    
    @IBAction public func actionPassword(_ sender: Any) {
//        self.activityIndicator.startAnimating()
        PollKumpeApps(username: self.fieldUsername.text!, password: self.fieldPassword.text!)
    }
    
    @IBAction public func pressedLogin(_ sender: Any) {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        PollKumpeApps(username: self.fieldUsername.text!, password: self.fieldPassword.text!)
    }
    
    @IBAction public func pressedFaceID(_ sender: Any) {
        if BioMetricAuthenticator.canAuthenticate() {

            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
                switch result {
                case .success( _):
                    let username = self.keychainSSOSecure.string(forKey: "Username")!
                           let password = self.keychainSSOSecure.string(forKey: "Password")!
                    self.PollKumpeApps(username: username, password: password)
                    print("Authentication Successful")
                case .failure(let error):
                    print("Authentication Failed \(error)")
                }
            }
        }
    }
    
    @IBAction public func pressedFingerPrint(_ sender: Any) {
       if BioMetricAuthenticator.canAuthenticate() {

            BioMetricAuthenticator.authenticateWithBioMetrics(reason: "") { (result) in
                switch result {
                case .success( _):
                    let username = self.keychainSSOSecure.string(forKey: "Username")!
                           let password = self.keychainSSOSecure.string(forKey: "Password")!
                    self.PollKumpeApps(username: username, password: password)
                    print("Authentication Successful")
                case .failure(let error):
                    print("Authentication Failed \(error)")
                }
            }
        }
    }
    
    
    public func PollKumpeApps(username: String, password: String){
        self.activityIndicator.startAnimating()
        sleep(1)
        params.pollMessage = "Pending"
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
                            
                         // _ = keychainSSOLegacy.removeAllKeys()
                            _ = KumpeAppsSSO.keychainSSOAccess.removeAllKeys()
                         
                         //Start SecureSSO Keychain
                            self.keychainSSOSecure.set("\(username)", forKey: "Username")
                            self.keychainSSOSecure.set("\(password)", forKey: "Password")
                            self.keychainSSOSecure.set("\(params.CurrentDate)", forKey: "AuthDate")
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
                                 params.pollMessage = "AccessGranted"
                                 print(params.pollMessage)
                                    self.navigationController?.popViewController(animated: true)
                                    self.activityIndicator.stopAnimating()
                                    self.fieldPassword.text = ""
                                    self.dismiss(animated: true, completion: nil)
                                    
                                 }else{
                                    
                                    params.pollMessage = "KumpeApps SSO Servers are currently down.  Please try again in a few min."
                                    self.activityIndicator.stopAnimating()
                                    self.alert(title: "Error", message: params.pollMessage)
                                    print(params.pollMessage)
                                    
                                 }
                            }
                         //End SSOAccess Keychain
                        
                        
                }else{
                    params.pollMessage =
                        "You have been denied access for the following reason(s): \(KappsArray["msg"]). \n\nPlease ensure you are using your KumpeApps username and password to login. If you need to reset your password please goto www.kumpeapps.com."
                    print(params.pollMessage)
                    _ = KumpeAppsSSO.keychainSSOAccess.removeAllKeys()
                    _ = KumpeAppsSSO.keychainSSOUser.removeAllKeys()
                    _ = self.keychainSSOSecure.removeAllKeys()
                    self.activityIndicator.stopAnimating()
                    self.alert(title: "Access Denied", message: params.pollMessage)
                    
                }
                self.view.endEditing(true)
                }else{
                    params.pollMessage = "KumpeApps SSO Servers are currently down.  Please try again in a few min."
                    print(params.pollMessage)
                    self.activityIndicator.stopAnimating()
                   self.alert(title: "Error", message: params.pollMessage)
                }
                
        }
        
        
    }
    
    public func confirmAccess(productCode: String = params.productCode, appScheme: String = params.appScheme) -> String{
        let formatter = DateFormatter()
         // initially set the format based on your datepicker date / server String
         formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
         
         let myString = formatter.string(from: Date()) // string purpose I add here
         // convert your string to date
         let yourDate = formatter.date(from: myString)
         //then again set the date format whhich type of output you need
         formatter.dateFormat = "dd-MMM-yyyy"
         // again convert your date to string
        let CurrentDate = formatter.string(from: yourDate!)
        var username = ""
        var SSOAuthDate = ""
        var SSOAccessGranted:Bool = false
        let enableSSO:Bool = schemeAvailable(scheme: "kumpeappssso://")
        var returnMessage = ""
        
        if KumpeAppsSSO.keychainSSOUser.string(forKey: "Username") != nil{
            username = KumpeAppsSSO.keychainSSOUser.string(forKey: "Username")!
        }
        
        if self.keychainSSOSecure.string(forKey: "AuthDate") != nil{
            SSOAuthDate = KumpeAppsSSO.keychainSSOUser.string(forKey: "Authdate")!
        }
        
        if KumpeAppsSSO.keychainSSOAccess.bool(forKey: "AccessTo\(productCode)") != nil{
            SSOAccessGranted = KumpeAppsSSO.keychainSSOUser.bool(forKey: "AccessTo\(productCode)")!
        }
        
        if username != "" && SSOAuthDate == CurrentDate && SSOAccessGranted{
//            AccessGranted
            returnMessage = "AccessGranted"
        //If User is signed in to KumpeApps SSO and session not expired but Access to This App is not approved then Deny Access
        } else if username != "" && SSOAuthDate == CurrentDate{
//            AccessDenied
            returnMessage = "AccessDenied"
        //If User is not signed in to KumpeApps SSO or session is expired then open KumpeApps SSO
        } else if enableSSO{
            returnMessage = "NotLoggedIn"
            self.launchSSO(appScheme: appScheme)
        } else if !enableSSO{
            returnMessage = "NotLoggedIn"
        }
        return returnMessage
    }
    
    public func launchSSO(appScheme: String = params.appScheme, productCode: String = params.productCode){
        open(scheme: "kumpeappssso://\(appScheme)?\(productCode)")
    }
    
    public func alert(title: String, message: String){
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.destructive,handler: nil))
        
        //Display Alert
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func logoff(){
        _ = KumpeAppsSSO.keychainSSOAccess.removeAllKeys()
        _ = KumpeAppsSSO.keychainSSOUser.removeAllKeys()
        _ = self.keychainSSOSecure.removeAllKeys()
    }
    
    public  func open(scheme: String) {
        if let url = URL(string: scheme) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: {
                (success) in
                print("Open \(scheme): \(success)")
            })
        }
    }
    
    public  func schemeAvailable(scheme: String) -> Bool {
        if let url = URL(string: scheme) {
            return UIApplication.shared.canOpenURL(url)
        }
        return false
    }
    
    //MARK: Hide Keyboard
       //Hides Keyboard when user touches outside of text field
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           self.view.endEditing(true)
       }

     
     // Helper function inserted by Swift 4.2 migrator.
    public func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
}
