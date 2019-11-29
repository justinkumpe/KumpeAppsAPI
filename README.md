# KumpeAppsAPI

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
<ensp>  Item 0 Type: Dictionary<br>
<ensp><ensp>    URL Identifier Type: String Value: your_app_identifier<br>
<ensp><ensp>    URL Schemes Type: Array<br>
 <ensp><ensp><ensp>     Item 0 Type: String Value: your_app_scheme<br>
<br>
<br>
<u><b>Set Parameters in AppDelegate under didFinishLaunchingWithOptions</b></u><br>
<br>
KumpeAppsAPI.shared.setParams(sqlUser: "yourAppSqlUser", sqlPass: "yourAppSqlPass", otpSecret: "yourAppOTPSecret", appName: "yourAppName", apikey: "yourAppAPIKey", appScheme: "yourAppURLScheme", productCode: "yourAppsProductCode In KumpeApps") <br>
NOTE: apikey, appScheme, and productCode parameters is optional and only required if using KumpeApps SSO for login <br>



