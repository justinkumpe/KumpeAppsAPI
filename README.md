# KumpeAppsAPI

Initial Setup:
Set the following Keychain Groups under Capabilities
com.kumpeapps.ios.sso.secure
com.kumpeapps.ios.sso.access
com.kumpeapps.ios.sso.user

Add Following values in PList
LSApplicationQueriesSchemes Type:Array
  Item0 Type:String kumpeappssso


Set Parameters in AppDelegate under didFinishLaunchingWithOptions

KumpeAppsAPI.shared.setParams(sqlUser: "yourAppSqlUser", sqlPass: "yourAppSqlPass", otpSecret: "yourAppOTPSecret", appName: "yourAppName", apikey: "yourAppAPIKey")
NOTE: apikey parameter is optional and only required if using KumpeApps SSO for login



