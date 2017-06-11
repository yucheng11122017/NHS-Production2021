use_frameworks!
install! 'cocoapods', :deterministic_uuids => false

# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

abstract_target 'CocoaPods' do
  pod 'NSDate-HYPString'
  pod 'NSDictionary-HYPImmutable'
  pod 'HYPImagePicker'
  pod 'AFNetworking', '~> 3.1'
  pod 'RNCryptor', '~> 2.2'
  pod 'XLForm', :git => 'https://github.com/xmartlabs/XLForm.git'
  pod 'MBProgressHUD', '~> 1.0.0'
  pod 'SVProgressHUD', '~> 2.1'
  pod 'HTPressableButton', '~> 1.3'
  pod 'ACEDrawingView'
  pod 'FontAwesomeKit', '~> 2.2'
#  pod 'LiquidFloatingActionButton', '~> 1.2'

  target 'NHS' do
    # Uncomment this line if you're using Swift or would like to use dynamic frameworks
    # use_frameworks!
  end

  # Pods for NHS

  target 'NHSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'NHSUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
