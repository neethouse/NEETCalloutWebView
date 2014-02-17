Pod::Spec.new do |s|
  s.name             = "NEETCalloutWebView"
  s.version          = "1.0.0"
  s.summary          = "Extension to customize UIWebView long press action"
  s.description      = <<-DESC
                       This library is an extension to customize UIWebView long press action.
                       DESC
  s.homepage         = "https://github.com/neethouse/NEETCalloutWebView"
  s.license          = 'MIT'
  s.author           = { "mtmta" => "mtmta@501dev.org" }
  s.source           = { :git => "https://github.com/neethouse/NEETCalloutWebView.git", :tag => s.version.to_s }

  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*.[hm]'
  s.resources = nil

  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/*.h'
end
