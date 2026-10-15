#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint zego_zimkit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'zego_zimkit'
  # zego_zimkit:
  s.version          = '2.0.1' # zego_zimkit:
  s.summary          = 'A new Flutter project.'
  s.description      = <<-DESC
A new Flutter project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'zego_zimkit/Sources/zego_zimkit/**/*'
  s.public_header_files = 'zego_zimkit/Sources/zego_zimkit/include/zego_zimkit/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '14.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
