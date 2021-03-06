Pod::Spec.new do |s|

# 1
s.platform = :ios
s.ios.deployment_target = '12.0'
s.name = "KumpeApps"
s.summary = "KumpeApps API Settings."
s.requires_arc = true

# 2
s.version = "0.2.0"

# 3
s.license = { :type => "MIT", :file => "LICENSE" }

# 4 - Replace with your name and e-mail address
s.author = { "Justin Kumpe" => "jakumpe@kumpes.com" }

# 5 - Replace this URL with your own GitHub page's URL (from the address bar)
s.homepage = "https://kumpeapps@bitbucket.org/kumpeapps"

# 6 - Replace this URL with your own Git URL from "Quick Setup"
s.source = { :git => "https://kumpeapps@bitbucket.org/kumpeapps/kumpeapps.git",
:tag => "#{s.version}" }

# 7
s.framework = "UIKit"
s.dependency 'Alamofire-SwiftyJSON'
s.dependency 'SwiftKeychainWrapper'
s.dependency 'Buglife'
s.dependency 'OneTimePassword'

# 8
s.source_files = "KumpeApps/**/*.{swift}"

# 9
s.resources = "KumpeApps/**/*.{png,jpeg,jpg,storyboard,xib,xcassets}"

# 10
s.swift_version = "4.2"

end
