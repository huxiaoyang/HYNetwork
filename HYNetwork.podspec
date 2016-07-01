Pod::Spec.new do |s|
  s.name         = 'HYNetwork'
  s.summary      = 'A simple network is based on AFNetwork.'
  s.version      = '0.0.2'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { 'huxiaoyang' => 'yohuyang@gmail.com' }
  s.homepage     = 'https://github.com/huxiaoyang/HYNetwork'
  s.platform     = :ios, '8.0'
  s.ios.deployment_target = '8.0'
  s.source       = { :git => 'https://github.com/huxiaoyang/HYNetwork.git', :tag => s.version.to_s }

  s.requires_arc = true
  s.source_files = 'HYNetwork/**/*.{h,m}'

  s.frameworks = 'UIKit', 'QuartzCore', 'Foundation'
  s.module_name = 'HYNetwork'

  s.dependency "AFNetworking", "~> 3.0.4"
  s.dependency "YYModel", "~> 0.9.12"

end
