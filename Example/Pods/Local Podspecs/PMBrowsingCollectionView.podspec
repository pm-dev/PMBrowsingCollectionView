Pod::Spec.new do |s|
  s.name             = "PMBrowsingCollectionView"
  s.version          = "0.9.1"
  s.summary          = "PMBrowsingCollectionView is a subclass of UICollectionView that introduces expanded vs. collapsed sections."
  s.homepage         = "https://github.com/pm-dev/#{s.name}"
  s.license          = 'MIT'
  s.author           = { "Peter Meyers" => "petermeyers1@gmail.com" }
  s.source           = { :git => "https://github.com/pm-dev/#{s.name}.git", :tag => s.version.to_s }
  s.platform         = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc     = true
  s.source_files     = 'Classes/**/PMBrowsingCollectionView.{h,m}'
  s.ios.exclude_files = 'Classes/osx'
  s.osx.exclude_files = 'Classes/ios'
  s.frameworks       = 'Foundation', 'CoreGraphics', 'UIKit'
  s.dependency 'PMUtils'
  s.dependency 'PMCircularCollectionView'
      
  s.subspec 'PMStickyHeaderFlowLayout' do |ss|
  	ss.source_files = 'Classes/ios/PMStickyHeaderFlowLayout/PMStickyHeaderFlowLayout.{h,m}'
  end
  
end
