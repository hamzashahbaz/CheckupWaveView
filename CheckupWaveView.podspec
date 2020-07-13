Pod::Spec.new do |s|
  s.name     = 'CheckupWaveView'
  s.version  = '1.0.0'
  s.platform = :ios, "7.0"
  s.summary  = 'UIView subclass that reproduces the waveform effect seen in Siri on iOS 7'
  s.homepage = 'https://github.com/hamzashahbaz/rn-checkup-visualizer'
  s.author   = { 'Hamza Shahbaz' => 'hi@hamzashahbaz.dev' }
  s.source   = { :git => 'https://github.com/hamzashahbaz/rn-checkup-visualizer.git' }
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.source_files = 'CheckupWaveView.{h,m,mm}'
  s.requires_arc = true
  s.frameworks = 'UIKit', 'QuartzCore', 'CoreGraphics', 'Foundation', 'AVFoundation'
end
