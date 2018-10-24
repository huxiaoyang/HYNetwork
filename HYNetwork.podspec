Pod::Spec.new do |s|
  s.name         = 'HYNetwork'
  s.summary      = 'A simple network is based on AFNetwork.'
  s.version      = '2.1.1'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'huxiaoyang' => 'yohuyang@gmail.com' }
  s.homepage     = 'https://github.com/huxiaoyang/HYNetwork'
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/huxiaoyang/HYNetwork.git', :tag => s.version.to_s }

  s.requires_arc = true

  s.frameworks = 'UIKit', 'QuartzCore', 'Foundation'
  s.module_name = 'HYNetwork'

  s.dependency "AFNetworking"
  s.dependency "YYModel"
  s.dependency "libextobjc"

  s.default_subspec = 'All'
  s.subspec 'All' do |ss|
    ss.dependency 'HYNetwork/Base'
    ss.source_files = 'HYNetwork/BSRequestBlockAdapter/*.{h,m}'
  end

  s.subspec 'Base' do |ss|
    ss.source_files = 'HYNetwork/BSModel/*.{h,m}', 'HYNetwork/BSNetwork/*.{h,m}'
  end

end
