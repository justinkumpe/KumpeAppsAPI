# KumpeAppsAPI <img src="https://img.shields.io/maintenance/no/2020"/>

<u><b>Initial Setup:</b></u><br>
<br>
<u><b>Set the following Keychain Groups under Capabilities</b></u><br>
<br>
com.kumpeapps.ios.sso.secure<br>
com.kumpeapps.ios.sso.access<br>
com.kumpeapps.ios.sso.user<br>
<br>
<u><b>Add Following values in PList</b></u><br>
<br>
LSApplicationQueriesSchemes Type:Array<br>
<ensp>  Item0 Type:String Value: kumpeappssso<br>
Privacy - Face ID Usage Description Type: String Value: FaceID is requried for remembered passwords<br>
URL types Type: Array<br>
  Item 0 Type: Dictionary<br>
    URL Identifier Type: String Value: your_app_identifier<br>
    URL Schemes Type: Array<br>
     Item 0 Type: String Value: your_app_scheme<br>
<br>
<br>
<u><b>Set Parameters in AppDelegate under didFinishLaunchingWithOptions</b></u><br>
<br>
KumpeAppsAPI.shared.setParams(sqlUser: "yourAppSqlUser", sqlPass: "yourAppSqlPass", otpSecret: "yourAppOTPSecret", appName: "yourAppName", apikey: "yourAppAPIKey", appScheme: "yourAppURLScheme", productCode: "yourAppsProductCode In KumpeApps") <br>
NOTE: apikey, appScheme, and productCode parameters is optional and only required if using KumpeApps SSO for login <br>
<br>
<br>
<br>
<u><b>KumpeApps SSO</u></b><br>

Place This in viewDidAppear<br>
        let access = KumpeAppsSSO.shared.confirmAccess()<br>
        if access == "AccessGranted"{<br>
            self.AccessGranted()<br>
        }else if access == "AccessDenied"{<br>
            self.AccessDenied()<br>
        }else{<br>
            show(KumpeAppsSSO.params.loginvc, sender: self)<br>
        }<br>
