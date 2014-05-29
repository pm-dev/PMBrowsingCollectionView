Pod::Spec.new do |s|
  s.name             = "PMBrowsingCollectionView"
  s.version          = "0.0.3"
  s.summary          = "This subclass of UICollectionView implements an easy interaction for easily browsing through a collection of cells."
  s.homepage         = "https://github.com/petermeyers1/#{s.name}"
  s.license          = 'MIT'
  s.author           = { "Peter Meyers" => "petermeyers1@gmail.com" }
  s.source           = { :git => "https://github.com/petermeyers1/#{s.name}.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc     = true
  s.source_files     = 'Classes/**/*.{h,m}'
  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.public_header_files = 'Classes/**/*.h'
  s.frameworks       = 'Foundation', 'CoreGraphics', 'UIKit'
  s.dependency 'PMUtils'
  s.dependency 'PMCircularCollectionView'
end
