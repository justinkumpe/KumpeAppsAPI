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
@_exported import struct LocalAuthentication.LAError

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
    
    public let bioAuth = BiometricAuthenticator()
    

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
        
        // check if the feature exists on the device
        if bioAuth.isTouchIdSupportedOnDevice() {
            // check if the feature is enabled
            if bioAuth.isTouchIdEnabledOnDevice() {
                self.buttonFingerPrint.isHidden = false
            }
        }

        // check if the feature exists on the device
        if bioAuth.isFaceIdSupportedOnDevice() {
            // check if the feature is enabled
            if bioAuth.isFaceIdEnabledOnDevice() {
                self.buttonFaceID.isHidden = false
            }
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
        let authenticated:Bool = bioAuth.authenticateWithBiometrics(localizedReason: "Authenticate via FaceID")
        if authenticated{
            alert(title: "Test", message: "FaceID Success")
        }else{
            alert(title: "Test", message: "FaceID Failure")
        }
    }
    
    @IBAction public func pressedFingerPrint(_ sender: Any) {
        let authenticated:Bool = bioAuth.authenticateWithBiometrics(localizedReason: "Authenticate via Finger")
        if authenticated{
            alert(title: "Test", message: "Finger Success")
        }else{
            alert(title: "Test", message: "Finger Failure")
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
        
        
}





public class BiometricAuthenticator {
    
    public init() {}
    
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
    public func authenticateWithBiometrics(localizedReason: String? = nil) -> Bool {
        var authResponse:Bool = false
        let context = LAContext()
        if #available(iOS 10, *) {
            context.localizedCancelTitle = defaultFallbackButtonTitle
        }
        context.localizedFallbackTitle = defaultFallbackAlertTitle
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: localizedReason ?? defaultAuthenticationReason) { (success, error) in
            authResponse = success
        }
        return authResponse
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
    public func authenticateWithPasscode(localizedReason: String? = nil) -> Bool {
           var authResponse:Bool = false
        let context = LAContext()
        if #available(iOS 10, *) {
            context.localizedCancelTitle = defaultFallbackButtonTitle
        }
        context.localizedFallbackTitle = defaultFallbackAlertTitle
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: localizedReason ?? defaultAuthenticationReason) { (success, error) in
            authResponse = success
        }
        return authResponse
    }
    
    /// Invalidates the current authentication context and cancels any pending authentication requests.
    /// - Note:
    ///     The cancelled evaluation will fail with the `systemCancelled` error code.
    public func invalidateAuthenticationContext() {
        let context = LAContext()
        context.invalidate()
    }
    
}
