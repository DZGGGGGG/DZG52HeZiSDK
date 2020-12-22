#
# Be sure to run `pod lib lint DZG52HeZiSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DZG52HeZiSDK'
  s.version          = '1.0.8'
  s.summary          = '52hezei的DZG52HeZiSDK. 12.22版本'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/DZGGGGGG'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'HippySDK', :file => 'LICENSE' }
  s.author           = { '15913420136@163.com' => '1062005302@qq.com' }
  s.source           = { :git => 'https://DZGGGGGG:dingzhigang222@github.com/DZGGGGGG/DZG52HeZiSDK.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.source_files = ['DZG52HeZiSDK/Classes/HippySDK/ios/**/*.{h,m,c,mm,s,cpp,cc}', 'DZG52HeZiSDK/Classes/HippySDK/core/**/*.{h,cc,mm}','DZG52HeZiSDK/Classes/HippySDK/sendwebsocket/**/*.{h,m}']
  #s.exclude_files = ['core/napi/v8','core/js']
  s.libraries    = "c++"
   s.pod_target_xcconfig = {'USER_HEADER_SEARCH_PATHS' => '${PODS_TARGET_SRCROOT} ${PODS_TARGET_SRCROOT}/DZG52HeZiSDK/Classes/HippySDK/ios/sdk/**'}
   if ENV['hippy_use_frameworks']
   else
     s.user_target_xcconfig = {'OTHER_LDFLAGS' => '-force_load "${PODS_CONFIGURATION_BUILD_DIR}/DZG52HeZiSDK/libDZG52HeZiSDK.a"'}
   end
  # s.resource_bundles = {
  #   'DZG52HeZiSDK' => ['DZG52HeZiSDK/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'MyToolsClass' , '~> 1.0.8'
end
