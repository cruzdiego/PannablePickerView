# PannablePickerView

[![Version](https://img.shields.io/cocoapods/v/PannablePickerView.svg?style=flat)](http://cocoapods.org/pods/PannablePickerView)
[![License](https://img.shields.io/cocoapods/l/PannablePickerView.svg?style=flat)](http://cocoapods.org/pods/PannablePickerView)
[![Platform](https://img.shields.io/cocoapods/p/PannablePickerView.svg?style=flat)](http://cocoapods.org/pods/PannablePickerView)

![](https://raw.githubusercontent.com/cruzdiego/PannablePickerView/master/Pod/Assets/Intro.gif)

PannablePickerView lets the user select a numeric value moving its finger up and down inside the control.

Built as a better way of handling value selection from a finite range (than UISlider and other alternatives), you can embed it to a full screen app, inline on a TableView or as a UITextField's inputView substitution! (read: awesome in-app custom keyboard). Check out the example project for more.

Customizable, you can change sizes, colors, units, prefix/suffix and more.

## Installation

- Via [CocoaPods](http://cocoapods.org):

```ruby
pod "PannablePickerView"
```

- Manually:

1. Clone this repo or download it as a .zip file
2. Drag and drop PannablePickerView.swift to your project

##Usage

- From Storyboard:

1. Drag and drop and UIView and name its Custom Class property as "PannablePickerView".
2. Asign an IBAction to its "Value Changed" control event.

- Programatically:

1. Create an instance of it and add it to a view.
2. You can either asign a frame to it or create NSLayoutConstraints.
3. Add a selector for its .ValueChanged control event.

##Properties

Thanks to @IBInspectables, you can customize its properties right on Storyboard:

![](https://raw.githubusercontent.com/cruzdiego/PannablePickerView/master/Pod/Assets/IBInspectables.png)

You can also always do it programatically, of course.

```swift
@IBInspectable public var continuous:Bool = false
```

Determines wether the picker's value moves continuously or in discrete steps. Default value is false.

```swift
@IBInspectable public var value:Double
```

Current selected value. Affected by 'continuous', it could be a decimal number. This is the property you should pay attention to at 'Value Changed' control event. Default value is 0.

```swift
@IBInspectable public var minValue:Double = 0
```

Minimun value. Default value is 0

```swift
@IBInspectable public var maxValue:Double = 100
```

Maximun value. Default value is 100

```swift
@IBInspectable public var minLabelSize:CGFloat = 30.0
```

Minimum font size for shown value at panning. Default value is 30

```swift
@IBInspectable public var maxLabelSize:CGFloat = 54.0
```

Maximum font size for shown value at the center. Default value is 54

```swift
@IBInspectable public var textColor:UIColor = UIColor.whiteColor()
```

Text color for presented value. Default value is white

```swift
@IBInspectable public var textPrefix:String = ""
```

Prefix for shown value. Default value is ""

```swift
@IBInspectable public var textSuffix:String = ""
```

Suffix for shown value.  Default value is ""

```swift
@IBInspectable public var unit:String = ""
```

Unit presented below shown value. Default is ""

```swift
@IBInspectable public var unitColor:UIColor = UIColor.whiteColor()
```

Text color for unit. Default is white

```swift
@IBInspectable public var unitSize:CGFloat = 14.0
```

Font size for unit. Default is 14

##Delegate methods

```swift
optional func pannablePickerViewDidBeginPanning(sender:PannablePickerView)
```

Triggered when user has began interacting with the control

```swift
optional func pannablePickerViewDidEndPanning(sender:PannablePickerView)
```

Triggered when users has ended interacting with the control

##Requirements

- Xcode 7.1 or later (Uses Swift 2.1 syntax)
- Autolayout should be enabled on Storyboard

## Author

Diego Cruz, diego.cruz@icloud.com

## License

PannablePickerView is available under the MIT license. See the LICENSE file for more info.
