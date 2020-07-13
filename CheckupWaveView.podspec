Pod::Spec.new do |s|
  s.name     = 'CheckupWaveView'
  s.version  = '1.0.1'
  s.platform = :ios, "7.0"
  s.summary  = 'UIView subclass that reproduces the waveform effect seen in Siri on iOS 7'
  s.homepage = 'https://github.com/hamzashahbaz/CheckupWaveView.git'
  s.author   = { 'Hamza Shahbaz' => 'hi@hamzashahbaz.dev' }
  s.source   = { :git => 'https://github.com/hamzashahbaz/CheckupWaveView.git', :tag => "v#{s.version}" }
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.source_files = 'src/*'
  s.requires_arc = true
  s.frameworks = 'UIKit', 'QuartzCore', 'CoreGraphics', 'Foundation', 'AVFoundation'
end
