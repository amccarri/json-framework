#
# Be sure to run `pod spec lint HomeAway-SBJson.podspec' to ensure this is a
# valid spec.
#
# Remove all comments before submitting the spec. Optional attributes are commented.
#
# For details see: https://github.com/CocoaPods/CocoaPods/wiki/The-podspec-format
#
Pod::Spec.new do |s|
  s.name         = "HomeAway-SBJson"
  s.version      = "1.0.2"
  s.summary      = "HomeAway customized version of SBJson that adds introspective marshalling/unmarshalling."
  s.homepage     = "http://github.wvrgroup.internal/MobileApps/SBJson"

  s.author       = { "Alex McCarrier" => "amccarrier@homeaway.com" }

  s.source       = { :git => "git@github.wvrgroup.internal:MobileApps/SBJson.git", :tag => "1.0.2" }
  s.source_files = 'Classes/**/*.{h,m}'

  s.public_header_files = 'Classes/**/*.h'
end
