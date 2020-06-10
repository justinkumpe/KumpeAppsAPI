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
import LocalAuthentication
import OnePasswordExtension

@_exported import struct LocalAuthentication.LAError

public typealias BAFailureBlock = ((_ error: LAError?) -> Void)?
public typealias BASuccessBlock = (() -> Void)?

//Note: The below imports will be required on any view controller using the API
//import Alamofire
//import SwiftyJSON
//import Alamofire_SwiftyJSON

public class KumpeAppsSSO: UIViewController {
public static let shared = KumpeAppsSSO()
public let url = "https://sql.kumpedns.us/API/mysql_v3.php"
let keychainSSOSecure = KeychainWrapper(serviceName: "KumpeAppsSSO_Secure", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.secure")
public static let keychainSSOAccess = KeychainWrapper(serviceName: "KumpeAppsSSO_Access", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.access")
public static let keychainSSOUser = KeychainWrapper(serviceName: "KumpeAppsSSO_User", accessGroup: "2T42Z3DM34.com.kumpeapps.ios.sso.user")
    
    
    
    @IBOutlet weak public var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak public var fieldEmail: UITextField!
    @IBOutlet weak public var fieldLastName: UITextField!
    @IBOutlet weak public var fieldFirstName: UITextField!
    @IBOutlet weak public var fieldUsername: UITextField!
    @IBOutlet weak public var fieldPassword: UITextField!
    
    @IBOutlet weak public var buttonLogin: UIButton!
    @IBOutlet weak public var buttonFaceID: UIButton!
    @IBOutlet weak public var buttonFingerPrint: UIButton!
    @IBOutlet weak public var buttonResetCreds: UIButton!
    @IBOutlet weak public var buttonRegister: UIButton!
    @IBOutlet weak public var buttonNewUser: UIButton!
    @IBOutlet weak public var button1Password: UIButton!
    
    

//    Parameters
public struct params {
    public static var username = ""
    public static var FirstName = ""
    public static var LastName = ""
    public static var CurrentDate = ""
    public static var CurrentDate2 = ""
    public static var apikey = ""
    public static var pollMessage = ""
    public static var appScheme = ""
    public static var productCode = ""
    public static var UserID = ""
    public static let s = UIStoryboard (
        name: "Main", bundle: Bundle(for: KumpeAppsSSO.self)
    )
    public static let loginvc = s.instantiateInitialViewController()!
    public static var enableRegistration:Bool = false
    public static var enableBiometrics:Bool = true
    public static var enableResetCreds:Bool = true
    public static var enableFreeAccessWithRegistration:Bool = false
    public static var enableRememberPassword:Bool = false
    public static var enable1Password:Bool = false
    public static var enableDebug:Bool = false
}
    
    override public func viewDidLoad() {
    print("SSO View Did Load")
    let formatter = DateFormatter()
     // initially set the format based on your datepicker date / server String
     formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
     
     let myString = formatter.string(from: Date()) // string purpose I add here
     // convert your string to date
     let yourDate = formatter.date(from: myString)
     //then again set the date format whhich type of output you need
     formatter.dateFormat = "yyyy-MM-dd"
     // again convert your date to string
    params.CurrentDate2 = formatter.string(from: yourDate!)
        print("SSO View Did Load")
        self.buttonRegister.isHidden = true
        self.fieldEmail.isHidden = true
        self.fieldLastName.isHidden = true
        self.fieldFirstName.isHidden = true
        self.buttonLogin.isHidden = false
        self.buttonResetCreds.isHidden = false
        self.buttonNewUser.isHidden = false
        
        if !params.enableRegistration{
            self.buttonNewUser.isHidden = true
            self.buttonNewUser.isEnabled = false
            self.buttonRegister.isEnabled = false
        }
        
        if !params.enableResetCreds{
            self.buttonResetCreds.isHidden = true
            self.buttonResetCreds.isEnabled = false
        }
        
        if schemeAvailable(scheme: "kumpeappssso://"){
            self.launchSSO(appScheme: params.appScheme)
        }
        
        if self.keychainSSOSecure.string(forKey: "Username") != nil && self.keychainSSOSecure.string(forKey: "Username") != "apple"{
            self.buttonNewUser.isHidden = true
        }
        
        if params.enable1Password{
            
            if OnePasswordExtension.shared().isAppExtensionAvailable() == false {
                self.button1Password.isHidden = true
            }else{
                self.button1Password.isHidden = false
            }
            
        }else{
            self.button1Password.isHidden = true
        }


        // check if the feature exists on the device
        if isFaceIdSupportedOnDevice() && params.enableBiometrics{
            // check if the feature is enabled
            if isFaceIdEnabledOnDevice() {
                self.buttonFaceID.isHidden = false
                self.buttonFingerPrint.isHidden = true
            }
        }else if isTouchIdSupportedOnDevice() && params.enableBiometrics{
                    // check if the feature exists on the device
            // check if the feature is enabled
            if isTouchIdEnabledOnDevice() {
                self.buttonFingerPrint.isHidden = false
                self.buttonFaceID.isHidden = true
            }
        }
        
        self.activityIndicator.stopAnimating()
        self.fieldPassword.text = ""
        if params.apikey == "Disable"{
            _ = SweetAlert().showAlert("KumpeAppsSSO API Key is missing.", subTitle: "The developer of this app has not set the apikey parameter. This parameter must be set to utilize KumpeApps signon", style: AlertStyle.error)
            sleep(3)
            self.dismiss(animated: true, completion: nil)
        }
        
        if self.keychainSSOSecure.string(forKey: "Username") != nil{
            self.fieldUsername.text = self.keychainSSOSecure.string(forKey: "Username")!
            if self.keychainSSOSecure.string(forKey: "Password") != nil && params.enableRememberPassword{
                self.fieldPassword.text = self.keychainSSOSecure.string(forKey: "Password")!
            }
        }
    }
    
    
    @IBAction public func actionUsername(_ sender: Any) {
        self.fieldPassword.becomeFirstResponder()
    }
    
    @IBAction public func actionPassword(_ sender: Any) {
        if !self.buttonLogin.isHidden && self.buttonRegister.isHidden{
            PollKumpeApps(username: self.fieldUsername.text!, password: self.fieldPassword.text!)
        }
    }
    
    @IBAction public func pressedLogin(_ sender: Any) {
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        PollKumpeApps(username: self.fieldUsername.text!, password: self.fieldPassword.text!)
    }
    
    @IBAction public func pressedFaceID(_ sender: Any) {
        var username = ""
        var password = ""
        if self.keychainSSOSecure.string(forKey: "Username") != nil{
            username = self.keychainSSOSecure.string(forKey: "Username")!
            if self.keychainSSOSecure.string(forKey: "Password") != nil{
                password = self.keychainSSOSecure.string(forKey: "Password")!
                authenticateWithBiometrics(localizedReason: "Let's authenticate with biometrics!", successBlock: {
                    
                    DispatchQueue.global(qos: .background).async {

                        // Background Thread

                        DispatchQueue.main.async {
                            self.PollKumpeApps(username: username, password: password)
                        }
                    }
                    
                    
                }, failureBlock: { (error) in
                    if let error = error {
                        switch error {
                        default:
                        // use the LAError code to handle the different error scenarios
                        print("error: \(error.code)")
                        }
                    }
                })
            }else{
                _ = SweetAlert().showAlert("Error", subTitle: "Please login first. FaceID can be used for future logins provided you do not click logout.", style: AlertStyle.error)
            }
        }
    }
    
    @IBAction public func pressedFingerPrint(_ sender: Any) {
      var username = ""
      var password = ""
      if self.keychainSSOSecure.string(forKey: "Username") != nil{
          username = self.keychainSSOSecure.string(forKey: "Username")!
          if self.keychainSSOSecure.string(forKey: "Password") != nil{
              password = self.keychainSSOSecure.string(forKey: "Password")!
              authenticateWithBiometrics(localizedReason: "Let's authenticate with biometrics!", successBlock: {
                  
                  DispatchQueue.global(qos: .background).async {

                      // Background Thread

                      DispatchQueue.main.async {
                          self.PollKumpeApps(username: username, password: password)
                      }
                  }
                  
                  
              }, failureBlock: { (error) in
                  if let error = error {
                      switch error {
                      default:
                      // use the LAError code to handle the different error scenarios
                      print("error: \(error.code)")
                      }
                  }
              })
          }else{
            _ = SweetAlert().showAlert("Error", subTitle: "Please login first. Biometrics can be used for future logins provided you do not click logout.", style: AlertStyle.error)
          }
      }
    }
    
    @IBAction func pressed1Password(_ sender: Any) {
        OnePasswordExtension.shared().findLogin(forURLString: "https://www.kumpeapps.com", for: self, sender: sender, completion: { (loginDictionary, error) in
            guard let loginDictionary = loginDictionary else {
                if let error = error as NSError?, error.code != AppExtensionErrorCode.cancelledByUser.rawValue {
                    print("Error invoking 1Password App Extension for find login: \(String(describing: error))")
                }
                return
            }
            
            self.fieldUsername.text = loginDictionary[AppExtensionUsernameKey] as? String
            self.fieldPassword.text = loginDictionary[AppExtensionPasswordKey] as? String
            self.PollKumpeApps(username: self.fieldUsername.text!, password: self.fieldPassword.text!)

            
        })
        
    }
    
    @IBAction public func pressedResetCredentials(_ sender: Any) {
        self.logoff(resetCreds: true)
    }
    
    @IBAction func actionFirstName(_ sender: Any) {
        self.fieldLastName.becomeFirstResponder()
    }
    
    @IBAction func actionLastName(_ sender: Any) {
        self.fieldEmail.becomeFirstResponder()
    }
    
    @IBAction func actionEmail(_ sender: Any) {
        self.fieldUsername.becomeFirstResponder()
    }
    
    @IBAction func pressedRegister(_ sender: Any) {
        if self.fieldFirstName.text! != "" && self.fieldLastName.text! != "" && self.fieldUsername.text! != "" && self.fieldEmail.text! != "" && self.fieldPassword.text! != ""{
            self.Register(firstName: self.fieldFirstName.text!, lastName: self.fieldLastName.text!, email: self.fieldEmail.text!, password: self.fieldPassword.text!, username: self.fieldUsername.text!)
        }
    }
    
    @IBAction func pressedNewUser(_ sender: Any) {
        self.fieldFirstName.isHidden = false
        self.fieldLastName.isHidden = false
        self.fieldEmail.isHidden = false
        self.buttonNewUser.isHidden = true
        self.buttonLogin.isHidden = true
        self.buttonResetCreds.isHidden = true
        self.buttonRegister.isHidden = false
    }
    
    public func Register(firstName: String, lastName: String, email:String, password: String, username: String){
        self.activityIndicator.startAnimating()
        self.fieldFirstName.isHidden = true
        self.fieldLastName.isHidden = true
        self.fieldEmail.isHidden = true
        self.buttonNewUser.isHidden = false
        self.buttonLogin.isHidden = false
        self.buttonResetCreds.isHidden = false
        self.buttonRegister.isHidden = true
        
        
        let url = "https://www.kumpeapps.com/api/users"
               
        let parameters: Parameters = ["_key":params.apikey,"login":username,"pass":password,"email":email,"name_f":firstName,"name_l":lastName,"_format":"json"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
                   .responseSwiftyJSON { dataResponse in
                       if dataResponse.value != nil{
                           let JSON = dataResponse.value!
                           print(JSON)
                        if JSON["error"].stringValue == "true"{
                            _ = SweetAlert().showAlert("Error!", subTitle: "An Error Occured. This is probably because your username or email is already in use!", style: AlertStyle.error)
                        }else{
                            if params.enableFreeAccessWithRegistration{
                                print("Free Access")
                                
                                let userid = JSON[0]["user_id"].stringValue
                                let url = "https://www.kumpeapps.com/api/access"
                                
                                print(url)
                                print(params.CurrentDate)
                                
                                let parameters: Parameters = ["_key":params.apikey,"user_id":userid,"product_id":params.productCode,"begin_date":params.CurrentDate2,"expire_date":"2037-12-31"]
                                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
                                           .responseSwiftyJSON { dataResponse in
                                            if dataResponse.value != nil{
                                                let JSON = dataResponse.value!
                                                self.successAlert(title: "Success", message: "Your KumpeApps SSO account has been created")
                                                print(JSON)
                                                self.activityIndicator.stopAnimating()
                                            }
                                }
                                
                            }else{
                                self.successAlert(title: "Success", message: "Your KumpeApps SSO account has been created")
                                self.activityIndicator.stopAnimating()
                            }
                        }
                       }else{
                        _ = SweetAlert().showAlert("Error", subTitle: "An Unknown Error Occurred", style: AlertStyle.error)
                       }
               }

    }
    
    public func freeAccess(productCode:String = params.productCode){
        
        let url = "https://www.kumpeapps.com/api/access"
        
        print(url)
        print(params.CurrentDate)
        
        let parameters: Parameters = ["_key":params.apikey,"user_id":params.UserID,"product_id":productCode,"begin_date":params.CurrentDate2,"expire_date":"2037-12-31"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
                   .responseSwiftyJSON { dataResponse in
                    if dataResponse.value != nil{
                        let JSON = dataResponse.value!
                        self.successAlert(title: "Success", message: "Your KumpeApps SSO account has been created")
                        print(JSON)
                        self.activityIndicator.stopAnimating()
                        _ = self.confirmAccess(productCode: productCode, reAuth: true)
                    }
        }
    }
    
    public func resetPassword(){
        if self.fieldUsername.text != ""{
            let url = "https://www.kumpeapps.com/api/check-access/sendpass"
                          
            let parameters: Parameters = ["_key":params.apikey,"login":self.fieldUsername.text!]
                   Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
                              .responseSwiftyJSON { dataResponse in
                                  if dataResponse.value != nil{
                                      let JSON = dataResponse.value!
                                      print(JSON)
                                    _ = SweetAlert().showAlert("Password Reset", subTitle: "If your username is valid then an email has been sent to you to reset your password.", style: AlertStyle.error)
                                }
            }
        }else{
            _ = SweetAlert().showAlert("Error", subTitle: "Username is required to reset password", style: AlertStyle.error)
        }
    }
    
    public func PollKumpeApps(username: String, password: String){
        
        if params.enableDebug{
            print("DEBUG PollKumpeApps")
        }
        
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
                params.UserID = KappsArray["user_id"].stringValue
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
                            self.keychainSSOSecure.set("\(params.UserID)", forKey: "UserID")
                         //End SecureSSO Keychain
                         
                         //Start SSOUser Keychain
                         KumpeAppsSSO.keychainSSOUser.set("\(username)", forKey: "Username")
                         KumpeAppsSSO.keychainSSOUser.set("\(params.FirstName)", forKey: "FirstName")
                         KumpeAppsSSO.keychainSSOUser.set("\(params.LastName)", forKey: "LastName")
                         KumpeAppsSSO.keychainSSOUser.set("\(params.CurrentDate)", forKey: "AuthDate")
                         KumpeAppsSSO.keychainSSOUser.set("\(params.UserID)", forKey: "UserID")
                         //End SSOUser Keychain
                         
                         //Start SSOAccess Keychain
                         KumpeAppsSSO.keychainSSOAccess.set("\(params.CurrentDate)", forKey: "AuthDate")
                    
                        for (key, value) in KappsArray["subscriptions"] {
                            
                            KumpeAppsSSO.keychainSSOAccess.set("\(value.stringValue)", forKey: "\(key)Expiration")
                            KumpeAppsSSO.keychainSSOAccess.set(true, forKey: "AccessTo\(key)")
                            
                            if params.enableDebug{
                                print("AccessTo\(key)")
                            }
                        }
                    
                        for (key, value) in KappsArray["categories"] {
                        
                            KumpeAppsSSO.keychainSSOAccess.set("\(value.stringValue)", forKey: "Category\(key)Expiration")
                            KumpeAppsSSO.keychainSSOAccess.set(true, forKey: "AccessToCategory\(key)")
                            
                            if params.enableDebug{
                                print("AccessToCategory\(key)")
                            }
                        }
                    
                                 params.pollMessage = "AccessGranted"
                                 print(params.pollMessage)
                                    self.navigationController?.popViewController(animated: true)
                                    self.activityIndicator.stopAnimating()
                                    self.fieldPassword.text = ""
                                    self.dismiss(animated: true, completion: nil)
                        
                        
                }else{
                    params.pollMessage =
                        "You have been denied access for the following reason(s): \(KappsArray["msg"]). \n\nPlease ensure you are using your KumpeApps username and password to login. If you need to reset your password please goto www.kumpeapps.com."
                    print(params.pollMessage)
                    _ = KumpeAppsSSO.keychainSSOAccess.removeAllKeys()
                    _ = KumpeAppsSSO.keychainSSOUser.removeAllKeys()
                    _ = self.keychainSSOSecure.removeAllKeys()
                    self.activityIndicator.stopAnimating()
                    _ = SweetAlert().showAlert("Access Denied!", subTitle: params.pollMessage, style: AlertStyle.error)
                    
                }
                self.view.endEditing(true)
                }else{
                    params.pollMessage = "KumpeApps SSO Servers are currently down.  Please try again in a few min."
                    print(params.pollMessage)
                    self.activityIndicator.stopAnimating()
                   _ = SweetAlert().showAlert("Access Denied!", subTitle: params.pollMessage, style: AlertStyle.error)
                }
                
        }
        
        
    }
    
    public func confirmAccess(ignoreDate: Bool = false, productCode: String = params.productCode, appScheme: String = params.appScheme, registerFreeIfDenied: Bool = false, reAuth: Bool = false, AccessType: String = "product") -> String{
        
        if params.enableDebug{
            print("DEBUG: confirmAccess")
            print(productCode)
        }
        var AccessString = "AccessTo"
        if AccessType == "category"{
            AccessString = "AccessToCategory"
        }
        
        if params.enableDebug{
            print("AccessString: \(AccessString)")
        }
        
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
            KumpeAppsSSO.params.username = KumpeAppsSSO.keychainSSOUser.string(forKey: "Username")!
        }
        
        if KumpeAppsSSO.keychainSSOUser.string(forKey: "AuthDate") != nil{
            SSOAuthDate = KumpeAppsSSO.keychainSSOUser.string(forKey: "AuthDate")!
        }
        
        if KumpeAppsSSO.keychainSSOUser.string(forKey: "UserID") != nil{
            KumpeAppsSSO.params.UserID = KumpeAppsSSO.keychainSSOUser.string(forKey: "UserID")!
        }
        
        if reAuth{
            params.pollMessage = "Pending"
            let URL = "https://www.kumpeapps.com/api/check-access/by-login"
            let parameters: Parameters = ["_key":"\(params.apikey)","login":"\(username)"]
            Alamofire.request(URL, method: .get, parameters: parameters, encoding: URLEncoding.default)
                .responseSwiftyJSON { dataResponse in
                    if dataResponse.value != nil{
                        let KappsArray = dataResponse.value!
                    print(KappsArray)
                    let Authenticated = KappsArray["ok"].stringValue
                    params.FirstName = KappsArray["name_f"].stringValue
                    params.LastName = KappsArray["name_l"].stringValue
                    params.UserID = KappsArray["user_id"].stringValue
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
                             
                             //Start SSOUser Keychain
                             KumpeAppsSSO.keychainSSOUser.set("\(username)", forKey: "Username")
                             KumpeAppsSSO.keychainSSOUser.set("\(params.FirstName)", forKey: "FirstName")
                             KumpeAppsSSO.keychainSSOUser.set("\(params.LastName)", forKey: "LastName")
                             KumpeAppsSSO.keychainSSOUser.set("\(params.CurrentDate)", forKey: "AuthDate")
                             KumpeAppsSSO.keychainSSOUser.set("\(params.UserID)", forKey: "UserID")
                             //End SSOUser Keychain
                             
                             //Start SSOAccess Keychain
                             KumpeAppsSSO.keychainSSOAccess.set("\(params.CurrentDate)", forKey: "AuthDate")
                        
                            
//                        Set Access Permissions for Product Subscriptions
                            for (key, value) in KappsArray["subscriptions"] {
                                
                                KumpeAppsSSO.keychainSSOAccess.set("\(value.stringValue)", forKey: "\(key)Expiration")
                                KumpeAppsSSO.keychainSSOAccess.set(true, forKey: "AccessTo\(key)")

                            }
                            
//                        Set Access Permissions for Product Categories
                            for (key, value) in KappsArray["categories"] {
                                
                                KumpeAppsSSO.keychainSSOAccess.set("\(value.stringValue)", forKey: "Category\(key)Expiration")
                                KumpeAppsSSO.keychainSSOAccess.set(true, forKey: "AccessToCategory\(key)")

                            }
                        
                                     
                                             
                                             if KumpeAppsSSO.keychainSSOAccess.bool(forKey: "\(AccessString)\(productCode)") != nil{
                                                 SSOAccessGranted = KumpeAppsSSO.keychainSSOAccess.bool(forKey: "\(AccessString)\(productCode)")!
                                             }
                                             
                                             if username != "" && (SSOAuthDate == CurrentDate || ignoreDate) && SSOAccessGranted{
                                     //            AccessGranted
                                                 returnMessage = "AccessGranted"
                                                 self.recordLogin(section: "KumpeApps Login")
                                             //If User is signed in to KumpeApps SSO and session not expired but Access to This App is not approved then Deny Access
                                             } else if username != "" && SSOAuthDate == CurrentDate && !SSOAccessGranted{
                                     //            AccessDenied
                                                 if registerFreeIfDenied{
                                                     print("Free Access")
                                                     
                                                     let userid = params.UserID
                                                     let url = "https://www.kumpeapps.com/api/access"
                                                     
                                                     print(url)
                                                     print(params.CurrentDate)
                                                     
                                                     let parameters: Parameters = ["_key":params.apikey,"user_id":userid,"product_id":productCode,"begin_date":params.CurrentDate2,"expire_date":"2037-12-31"]
                                                     Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
                                                                .responseSwiftyJSON { dataResponse in
                                                                 if dataResponse.value != nil{
                                                                     let JSON = dataResponse.value!
                                                                     print(JSON)
                                                                     returnMessage = "RegisteredFree"
                                                                     self.activityIndicator.stopAnimating()
                                                                 }
                                                     }
                                                     
                                                 }else{
                                                     returnMessage = "AccessDenied"
                                                 }
                                                 
                                     //        Session Expired
                                             }else if username != "" && SSOAuthDate != CurrentDate{
                                                 returnMessage = "SessionExpired"
                                             //If User is not signed in to KumpeApps SSO
                                             } else if enableSSO{
                                                 returnMessage = "NotLoggedIn"
                                                 self.launchSSO(appScheme: appScheme)
                                             } else if !enableSSO{
                                                 returnMessage = "NotLoggedIn"
                                             }
                            
                            
                    }else{
                        params.pollMessage =
                            "You have been denied access for the following reason(s): \(KappsArray["msg"]). \n\nPlease ensure you are using your KumpeApps username and password to login. If you need to reset your password please goto www.kumpeapps.com."
                        print(params.pollMessage)
                        _ = KumpeAppsSSO.keychainSSOAccess.removeAllKeys()
                        _ = KumpeAppsSSO.keychainSSOUser.removeAllKeys()
                        _ = self.keychainSSOSecure.removeAllKeys()
                        self.activityIndicator.stopAnimating()
                        _ = SweetAlert().showAlert("Access Denied!", subTitle: params.pollMessage, style: AlertStyle.error)
                        
                    }
                    self.view.endEditing(true)
                    }else{
                        params.pollMessage = "KumpeApps SSO Servers are currently down.  Please try again in a few min."
                        print(params.pollMessage)
                        self.activityIndicator.stopAnimating()
                       _ = SweetAlert().showAlert("Access Denied!", subTitle: params.pollMessage, style: AlertStyle.error)
                    }
                    
            }
        }else{
        
        if KumpeAppsSSO.keychainSSOAccess.bool(forKey: "\(AccessString)\(productCode)") != nil{
            SSOAccessGranted = KumpeAppsSSO.keychainSSOAccess.bool(forKey: "\(AccessString)\(productCode)")!
        }
            
        if params.enableDebug{
            print("SSOAccessGranted: \(SSOAccessGranted)")
        }
        
        if username != "" && (SSOAuthDate == CurrentDate || ignoreDate) && SSOAccessGranted{
//            AccessGranted
            returnMessage = "AccessGranted"
            self.recordLogin(section: "KumpeApps Login")
        //If User is signed in to KumpeApps SSO and session not expired but Access to This App is not approved then Deny Access
        } else if username != "" && SSOAuthDate == CurrentDate && !SSOAccessGranted{
//            AccessDenied
            if registerFreeIfDenied{
                print("Free Access")
                
                let userid = params.UserID
                let url = "https://www.kumpeapps.com/api/access"
                
                print(url)
                print(params.CurrentDate)
                
                let parameters: Parameters = ["_key":params.apikey,"user_id":userid,"product_id":productCode,"begin_date":params.CurrentDate2,"expire_date":"2037-12-31"]
                Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default)
                           .responseSwiftyJSON { dataResponse in
                            if dataResponse.value != nil{
                                let JSON = dataResponse.value!
                                print(JSON)
                                returnMessage = "RegisteredFree"
                                self.activityIndicator.stopAnimating()
                            }
                }
                
            }else{
                returnMessage = "AccessDenied"
            }
            
//        Session Expired
        }else if username != "" && SSOAuthDate != CurrentDate{
            returnMessage = "SessionExpired"
        //If User is not signed in to KumpeApps SSO
        } else if enableSSO{
            returnMessage = "NotLoggedIn"
            self.launchSSO(appScheme: appScheme)
        } else if !enableSSO{
            returnMessage = "NotLoggedIn"
        }
            
        }
        return returnMessage
        
    }
    
    public func launchSSO(appScheme: String = params.appScheme, productCode: String = params.productCode){
        open(scheme: "kumpeappssso://\(appScheme)?\(productCode)")
    }
    
    public func alert(title: String, message: String){
        _ = SweetAlert().showAlert(message)
    }
    
    public func errorAlert(title: String, message: String){
        _ = SweetAlert().showAlert(title, subTitle: message, style: AlertStyle.error)
    }
    
    public func successAlert(title: String, message: String){
        _ = SweetAlert().showAlert(title, subTitle: message, style: AlertStyle.success)
    }
    
    public func logoff(resetCreds: Bool = false){
        _ = KumpeAppsSSO.keychainSSOAccess.removeAllKeys()
        _ = KumpeAppsSSO.keychainSSOUser.removeAllKeys()
        if resetCreds{
            _ = self.keychainSSOSecure.removeAllKeys()
            self.fieldUsername.text = ""
            self.fieldPassword.text = ""
        }
    }
    
    public func recordLogin(section: String){
        let referrer = "\(KumpeAppsSSO.params.appScheme)://"
        let userID = KumpeAppsSSO.params.UserID
        let url = URL(string: "https://api.ipify.org")
        var ip = ""
        do {
            if let url = url {
                let ipAddress = try String(contentsOf: url)
                print("My public IP address is: " + ipAddress)
                ip = ipAddress
            }
        } catch let error {
            print(error)
        }
        
        
        
                let sqlDatabase = "Core_KumpeApps"
                let sqlTable = "am_access_log"
                let sqlQuery = "INSERT INTO \(sqlTable) SET user_id = '\(userID)', url = '\(section)', time = NOW(), referrer = '\(referrer)', remote_addr = '\(ip)'"
                print(sqlQuery)
        let parameters: Parameters = ["sql_username":KumpeAppsAPI.params.sqlUser,"password":KumpeAppsAPI.params.sqlPass,"database":"\(sqlDatabase)","sql":"\(sqlQuery)","app_username":"API_Access_Log","otp":KumpeAppsAPI.shared.getOTP()]
        Alamofire.request(KumpeAppsAPI.params.url, method: .post, parameters: parameters, encoding: URLEncoding.default)
                   .responseSwiftyJSON { dataResponse in
                       
               }
        
    }
    
    public  func open(scheme: String) {
        if let url = URL(string: scheme) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
        
        



    

    
    /// The localized reason presented to the user for authentication.
    public var defaultAuthenticationReason: String = "Use Biometrics!"
    
    /// The localized title for the fallback button in the dialog presented to the user during authentication.
    /// - Note:
    ///     This attribute will only be applied when running on iOS 10 or higher
    public var defaultFallbackButtonTitle: String? = nil
    
    /// The localized title for the fallback dialog presented to the user during authentication.
    public var defaultFallbackAlertTitle: String? = nil
    
    /// Checks if the current device model can support Touch ID.
    ///
    /// - Returns: True if the device is known to support Touch ID.
    public func isTouchIdSupportedOnDevice() -> Bool {
        return UIDevice.current.supportsTouchId()
    }
    
    /// CHecks if the device can support Touch ID and whether or not Touch ID is enabled.
    ///
    /// - Returns: True if the device can support Touch ID and the feature is enabled.
    public func isTouchIdEnabledOnDevice() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && isTouchIdSupportedOnDevice()
    }
    
    /// Checks if the current device model can support Face ID.
    ///
    /// - Returns: True if the device is known to support Face ID.
    public func isFaceIdSupportedOnDevice() -> Bool {
        return UIDevice.current.supportsFaceId()
    }
    
    /// CHecks if the device can support Face ID and whether or not Face ID is enabled.
    ///
    /// - Returns: True if the device can support Face ID and the feature is enabled.
    public func isFaceIdEnabledOnDevice() -> Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) && isFaceIdSupportedOnDevice()
    }
    
    /// Use this function to authenticate a user if biometric authentication is enabled on the user's phone.
    ///
    /// - Parameters:
    ///   - localizedReason: The string displayed to the user explaining why the application is requesting authentication (defaults to `defaultAuthenticationReason`).
    ///   - successBlock: A function or block of code executed if authentication succeeds.
    ///   - failureBlock: A function or block of code executed if authentication fails. The function takes a single LAError as
    ///                   a parameter. Use the error code provided in the LAError object to handle the authentication failure
    ///                   appropriately.
    public func authenticateWithBiometrics(localizedReason: String? = nil, successBlock: BASuccessBlock, failureBlock: BAFailureBlock) {
        let context = LAContext()
        if #available(iOS 10, *) {
            context.localizedCancelTitle = defaultFallbackButtonTitle
        }
        context.localizedFallbackTitle = defaultFallbackAlertTitle
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason ?? defaultAuthenticationReason) { (success, error) in
            if success {
                successBlock?()
            } else {
                guard let error = error as? LAError else {
                    failureBlock?(nil)
                    return
                }
                failureBlock?(error)
            }
        }
    }
    
    /// Use this function to authenticate a user if biometric authentication isn't enabled on the user's phone.
    ///
    /// - Note:
    ///     If the provided functions for determining whether or not biometric capabilities are available on the device
    ///     return true, ```authenticateWithBiometrics``` should be called instead.
    ///
    /// - Parameters:
    ///   - localizedReason: The string displayed to the user explaining why the application is requesting authentication (defaults to `defaultAuthenticationReason`).
    ///   - successBlock: A function or block of code executed if authentication succeeds.
    ///   - failureBlock: A function or block of code executed if authentication fails. The function takes a single LAError as
    ///                   a parameter. Use the error code provided in the LAError object to handle the authentication failure
    ///                   appropriately.
    public func authenticateWithPasscode(localizedReason: String? = nil, successBlock: BASuccessBlock, failureBlock: BAFailureBlock) {
        let context = LAContext()
        if #available(iOS 10, *) {
            context.localizedCancelTitle = defaultFallbackButtonTitle
        }
        context.localizedFallbackTitle = defaultFallbackAlertTitle
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason ?? defaultAuthenticationReason) { (success, error) in
            if success {
                successBlock?()
            } else {
                guard let error = error as? LAError else {
                    failureBlock?(nil)
                    return
                }
                failureBlock?(error)
            }
        }
    }
    
    /// Invalidates the current authentication context and cancels any pending authentication requests.
    /// - Note:
    ///     The cancelled evaluation will fail with the `systemCancelled` error code.
    public func invalidateAuthenticationContext() {
        let context = LAContext()
        context.invalidate()
    }
    
}
