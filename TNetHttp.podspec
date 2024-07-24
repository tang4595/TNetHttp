$version = "0.0.1"

Pod::Spec.new do |s|
  s.name         = "TNetHttp" 
  s.version      = $version
  s.summary      = "TNetHttp."
  s.description  = "TNetHttp."
  s.homepage     = "https://www.apple.com"
  
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "tang" => "tang@apple.com" }
  s.source       = { :git => "https://github.com/tang4595/", :tag => $version }
  s.source_files = "TNetHttp/Classes/**/*"
  s.resource_bundles = {
    'TNetHttpResource' => ['TNetHttp/Assets/*.{xcassets,json,plist}']
  }

  s.dependency 'SwiftyJSON'
  s.dependency 'RxSwift'
  s.dependency 'CryptoSwift'
  s.dependency 'FCUUID'
  s.dependency 'RxAlamofire', '~> 6.1.1'
  s.dependency 'Moya', '~> 14.0.0'
  s.dependency 'TAppBase'
  s.dependency 'TUtilExt'

  s.platform = :ios, "13.0"
  s.pod_target_xcconfig = { 'c' => '-Owholemodule' }
end

