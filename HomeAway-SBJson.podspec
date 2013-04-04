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
  s.version      = "1.0.11"
  s.summary      = "HomeAway customized version of SBJson that adds introspective marshalling/unmarshalling."
  s.homepage     = "http://github.wvrgroup.internal/MobileApps/SBJson"

  s.author       = { "Alex McCarrier" => "amccarrier@homeaway.com" }
  s.license      = {
        :type => 'Homeaway.com',
        :text => <<-LICENSE 
                        Copyright (C) 2007-2011 Stig Brautaset. All rights reserved.
                        Copyright Homeaway, Inc 2011-Present. All Rights Reserved.
                                        No unauthorized use of this software.
                                             LICENSE

  }

  s.source       = { :git => "git@github.wvrgroup.internal:MobileApps/SBJson.git", :tag => "#{s.version}" }
  s.source_files = 'Classes/**/*.{h,m}'

  s.public_header_files = 'Classes/**/*.h'
end
