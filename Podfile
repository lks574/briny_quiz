# CocoaPods for React Native (Brownfield)

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
