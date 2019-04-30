# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def base_pods
  use_frameworks!

  pod 'RxSwift', '~> 4.5.0'
  pod 'RxCocoa', '~> 4.5.0'
end

target 'RxSwiftPractice' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  

  # Pods for RxSwiftPractice
  # inherit! :search_paths
  base_pods
  pod 'SnapKit', '~> 5.0.0'
end


target 'RxSwiftPracticeTests' do
    inherit! :search_paths
    base_pods
    pod "RxNimble"
    pod "RxTest"
end