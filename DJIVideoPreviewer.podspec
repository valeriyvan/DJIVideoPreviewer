#
# Be sure to run `pod lib lint DJIVideoPreviewer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DJIVideoPreviewer'
  s.version          = '1.0'
  s.summary          = 'DJIVideoPreviewer for DJI iOS Mobile SDK'
  s.homepage         = 'https://github.com/dji-sdk/DJIVideoPreviewer'
  s.license      = { :type => 'CUSTOM', :text => <<-LICENSE
****************************************************************************************************************************

DJI Mobile SDK for iOS is offered under DJI's END USER LICENSE AGREEMENT. You can obtain the license from the below link:

http://developer.dji.com/policies/eula/

****************************************************************************************************************************
    LICENSE
  }
  s.author           = { 'DJI SDK' => 'dev@dji.com' }
  s.source           = { :git => 'https://github.com/dji-sdk/DJIVideoPreviewer', :tag => s.version.to_s, :submodules => true }
  s.requires_arc = true
  s.platform     = :ios, '8.0'
  s.source_files = 'DJIVideoPreviewer/**/*'
  s.ios.library = 'z'
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  s.private_header_files = 'DJIVideoPreviewer/ffmpeg/include/**/*.h'
  s.public_header_files = 'DJIVideoPreviewer/*.h', 'DJIVideoPreviewer/Lb2AUDHack/*.h', 'DJIVideoPreviewer/H1Camera/*.h', 'DJIVideoPreviewer/Helper/*.h', 'DJIVideoPreviewer/Render/**/*.h'
  s.xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(inherited) "${PODS_ROOT}/../../DJIVideoPreviewer/ffmpeg/include"'
  }
  s.vendored_libraries  = 'DJIVideoPreviewer/ffmpeg/lib/*.a'
  s.libraries = 'avcodec', 'avdevice', 'avfilter', 'avformat', 'avresample', 'avutil', 'swresample', 'swscale'
end
