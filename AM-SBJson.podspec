Pod::Spec.new do |s|
  s.name         = "AM-SBJson"
  s.version      = "1.0.0"
  s.summary      = "Fork of Stig Brautaset's SBJson that adds introspective marshalling/unmarshalling."
  s.homepage     = "https://github.com/amccarri/json-framework"

  s.author       = { "Alex McCarrier" => "alx@acm.org" }
  s.source       = { :git => "git://github.com/amccarri/json-framework.git", :tag => "#{s.version}" }
  s.source_files = 'Classes/**/*.{h,m}'

  s.public_header_files = 'Classes/**/*.h'
end
