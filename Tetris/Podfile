# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'TetrisClone' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for TetrisClone
  pod 'lottie-ios', '~> 3.1.5'
  pod 'TTTAttributedLabel', '~> 2.0.0'

  pre_install do |installer|
    def installer.verify_no_static_framework_transitive_dependencies; end
end

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['SWIFT_VERSION'] = '4.2'
    end
  end
end
end
