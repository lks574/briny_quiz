# CocoaPods for React Native (Brownfield)

# Workaround: Xcode 26 project format (objectVersion 70) not recognized by
# older xcodeproj mapping shipped with CocoaPods.
begin
  require 'xcodeproj'
  compat = Xcodeproj::Constants::COMPATIBILITY_VERSION_BY_OBJECT_VERSION.dup
  compat[70] ||= 'Xcode 16.0'
  Xcodeproj::Constants.send(:remove_const, :COMPATIBILITY_VERSION_BY_OBJECT_VERSION)
  Xcodeproj::Constants.const_set(:COMPATIBILITY_VERSION_BY_OBJECT_VERSION, compat.freeze)
rescue LoadError
end

ENV['RCT_NEW_ARCH_ENABLED'] = '1'

require_relative './RN/node_modules/react-native/scripts/react_native_pods'

platform :ios, '17.0'
prepare_react_native_project!

react_native_path = './RN/node_modules/react-native'

target 'BrinyQuiz' do
  use_react_native!(
    :path => react_native_path,
    :hermes_enabled => true,
    :fabric_enabled => true,
    :app_path => "#{Pod::Config.instance.installation_root}/RN",
    :config_file_dir => "RN"
  )
end

post_install do |installer|
  react_native_post_install(installer, react_native_path)
end
