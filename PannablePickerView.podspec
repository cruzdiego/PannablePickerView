#
# Be sure to run `pod lib lint PannablePickerView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PannablePickerView"
  s.version          = "1.0.0"
  s.summary          = "Custom picker view inspired by Rise (http://rise.simplebots.co) and Timely (https://timelyapp.com) apps"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
  PannablePickerView lets the user select a numeric value moving its finger up and down inside the control.

Built as a better way of handling value selection from a finite range (than UISlider and other alternatives), you can embed it to a full screen app, inline on a TableView or as a UITextField's inputView substitution! (read: awesome in-app custom keyboard). Check out the example project for more.

Customizable, you can change sizes, colors, units, prefix/suffix and more.
                       DESC

  s.homepage         = "https://github.com/cruzdiego/PannablePickerView"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Diego Cruz" => "diego.cruz@icloud.com" }
  s.source           = { :git => "https://github.com/cruzdiego/PannablePickerView.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.2'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PannablePickerView' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
