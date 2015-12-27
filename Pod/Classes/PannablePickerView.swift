//
//  PannablePickerView.swift
//  Pods
//
//  Created by Diego Alberto Cruz Castillo on 12/22/15.
//
//

import UIKit

@objc public protocol PannablePickerViewDelegate{
    optional func pannablePickerViewDidBeginPanning(sender:PannablePickerView)
    optional func pannablePickerViewDidEndPanning(sender:PannablePickerView)
}

@IBDesignable public class PannablePickerView: UIControl {
    //MARK: - Properties
    //MARK: UI
    //BG
    private var bgView:UIView!
    //Content
    private var contentView:UIView!
    private var valueParentView:UIView!
    private var valueLabel: UILabel!
    private var unitParentView:UIView!
    private var unitLabel: UILabel!
    //MARK: Public Variables
    //Type
    @IBInspectable public var continuous:Bool = false{
        didSet{
            refreshLabel()
        }
    }
    @IBInspectable public var value:Double{
        get{
            if continuous{
                return privateValue
            }else{
                return round(privateValue)
            }
        }
        set(newValue){
            let correctedValue:Double
            if continuous{
                correctedValue = newValue
            }else{
                correctedValue = round(newValue)
            }
            privateValue = correctedValue
        }
    }
    @IBInspectable public var minValue:Double = 0{
        didSet{
            if oldValue != minValue{
                correctValueIfNeeded()
            }
        }
    }
    @IBInspectable public var maxValue:Double = 100{
        didSet{
            if oldValue != maxValue{
                correctValueIfNeeded()
            }
        }
    }
    //Label
    @IBInspectable public var minLabelSize:CGFloat = 30.0
    @IBInspectable public var maxLabelSize:CGFloat = 54.0{
        didSet{
            valueLabel.font = UIFont.systemFontOfSize(maxLabelSize)
            setUnitLabelCenterXConstraints()
        }
    }
    @IBInspectable public var textColor:UIColor = UIColor.whiteColor(){
        didSet{
            valueLabel.textColor = textColor
        }
    }
    @IBInspectable public var textPrefix:String = ""{
        didSet{
            refreshLabel()
        }
    }
    @IBInspectable public var textSuffix:String = ""{
        didSet{
            refreshLabel()
        }
    }
    //Unit
    @IBInspectable public var unit:String = ""{
        didSet{
            refreshUnitLabel()
            setValueLabelCenterConstraints()
        }
    }
    @IBInspectable public var unitColor:UIColor = UIColor.whiteColor(){
        didSet{
            unitLabel.textColor = unitColor
        }
    }
    @IBInspectable public var unitSize:CGFloat = 14.0{
        didSet{
            unitLabel.font = UIFont.systemFontOfSize(unitSize, weight: UIFontWeightSemibold)
            setCenterConstraints(view: valueLabel)
        }
    }
    public var delegate:PannablePickerViewDelegate?
    //MARK: Private Variables
    //General
    private var panEnabled = false
    //Value
    private var privateValue:Double = 0{
        didSet{
            if oldValue != privateValue{
                correctValueIfNeeded()
                sendActionsForControlEvents(.ValueChanged)
                refreshLabel()
            }
        }
    }
    //Transition
    private let transitionDuration:CFTimeInterval = 0.15
    private var transitionAnimation: CABasicAnimation?
    //Unit
    private var unitVerticalSpacing:CGFloat = 8.0
    //yPosition
    private var minYPosition:CGFloat{
        get{
            return 0.0
        }
    }
    private var maxYPosition:CGFloat{
        get{
            return contentView.bounds.maxY - (valueLabel.bounds.height * minLabelSize/maxLabelSize)
        }
    }
    private var currentYPosition: CGFloat = 0{
        didSet{
            if panEnabled{
                setValueLabelLeftAlignedConstraints(yPosition: currentYPosition)
                refreshValue()
            }
        }
    }
    //Touch
    private var touchBeganPoint:CGPoint?
    
    //MARK: - Init methods
    init(){
        super.init(frame: CGRectZero)
        configure()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    //MARK: Configure
    private func configure(){
        func configureBGView(){
            bgView = newUIView()
            addAndSetFullSizeConstraints(view: bgView, parentView: self)
        }
        
        func configureContentView(){
            //ContentView
            contentView = newUIView()
            addAndSetFullSizeConstraints(view: contentView, parentView: self,padding: 16)
        }
        
        func configureValueLabel(){
            //Parent
            valueParentView = newUIView()
            addAndSetFullSizeConstraints(view: valueParentView, parentView: contentView)
            //Value
            valueLabel = UILabel(frame:CGRectZero)
            valueLabel.translatesAutoresizingMaskIntoConstraints = false
            valueLabel.font = UIFont.systemFontOfSize(maxLabelSize)
            valueLabel.textColor = self.textColor
            refreshLabel()
            valueParentView.addSubview(valueLabel)
            setValueLabelCenterConstraints()
        }
        
        func configureUnitLabel(){
            //Parent
            unitParentView = newUIView()
            addAndSetFullSizeConstraints(view: unitParentView, parentView: contentView)
            //Unit
            unitLabel = UILabel(frame: CGRectZero)
            unitLabel.translatesAutoresizingMaskIntoConstraints = false
            unitLabel.font = UIFont.systemFontOfSize(unitSize, weight: UIFontWeightSemibold)
            unitLabel.textColor = self.unitColor
            refreshUnitLabel()
            unitParentView.addSubview(unitLabel)
            setUnitLabelCenterXConstraints()
        }
        
        //
        configureBGView()
        configureContentView()
        configureValueLabel()
        configureUnitLabel()
    }
    
    //MARK: - Touches events methods
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        func areMinMaxValuesValid()->Bool{
            return minValue<maxValue
        }
        
        //
        if areMinMaxValuesValid(){
            if let point = touches.first?.locationInView(contentView){
                touchBeganPoint = point
                goToCurrentValuePosition(animated: true)
            }
        }else{
            NSLog("WARNING: PannablePickerView does not support a minValue equal or greater than maxValue")
        }
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let initialPoint = touchBeganPoint, let point = touches.first?.locationInView(contentView) where panEnabled{
            let y = point.y
            let initialY = initialPoint.y
            let newPosition = currentYPosition + (y - initialY)
            if newPosition > maxYPosition{
                currentYPosition = maxYPosition
            }else if newPosition < minYPosition{
                currentYPosition = minYPosition
            }else{
                currentYPosition = newPosition
                touchBeganPoint = point
            }
        }
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        goToCenter(animated: true)
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touchBeganPoint = nil
        goToCenter(animated:true)
    }
    
    public func goToCurrentValuePosition(animated animated:Bool=false){
        func duration()->CFTimeInterval{
            if animated{
                return transitionDuration
            }else{
                return 0.0
            }
        }
        
        //
        delegate?.pannablePickerViewDidBeginPanning?(self)
        refreshYPosition()
        UIView.animateWithDuration(duration(), animations: { () -> Void in
            let newScale = self.minLabelSize/self.maxLabelSize
            self.valueLabel.transform = CGAffineTransformMakeScale(newScale, newScale)
            self.valueLabel.alpha = 0.9
            self.unitLabel.alpha = 0.0
            self.setValueLabelLeftAlignedConstraints(yPosition: self.currentYPosition)
            self.valueParentView.layoutIfNeeded()
            }, completion: {(completed)-> () in
                self.panEnabled = true
        })
    }
    
    public func goToCenter(animated animated:Bool=false){
        func duration()->CFTimeInterval{
            if animated{
                return transitionDuration
            }else{
                return 0.0
            }
        }
        
        //
        delegate?.pannablePickerViewDidEndPanning?(self)
        panEnabled = false
        UIView.animateWithDuration(duration(), animations: { () -> Void in
            self.valueLabel.transform = CGAffineTransformMakeScale(1, 1)
            self.valueLabel.alpha = 1.0
            self.unitLabel.alpha = 1.0
            self.setValueLabelCenterConstraints()
            self.valueParentView.layoutIfNeeded()
            }, completion: {(completed) -> () in
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.unitLabel.alpha = 1.0
            })
                
        })
    }
    
    
    
    //MARK: - Utility methods
    //MARK: Creation
    private func newUIView()->UIView{
        let newView = UIView(frame: CGRectZero)
        return newView
    }
    
    //MARK: NSLayoutConstraints
    //Add and Set
    private func addAndSetFullSizeConstraints(view view:UIView,parentView:UIView, padding:CGFloat = 0){
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)
        //
        let metrics = ["padding":padding]
        let views = ["subview":view]
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-padding-[subview]-padding-|", options: [], metrics: metrics, views: views)
        let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-padding-[subview]-padding-|", options: [], metrics: metrics, views: views)
        parentView.addConstraints(hConstraints)
        parentView.addConstraints(vConstraints)
    }
    
    private func addAndSetCenterConstraints(view view:UIView,parentView:UIView){
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)
        setCenterConstraints(view: view)
    }
    
    //Set
    private func setCenterConstraints(view view:UIView,yOffset:CGFloat=0.0){
        if let parentView = view.superview{
            let centerXConstraint = NSLayoutConstraint(item: parentView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1, constant: 0)
            let centerYConstraint = NSLayoutConstraint(item: parentView, attribute: .CenterY, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1, constant: yOffset)
            parentView.addConstraints([centerXConstraint,centerYConstraint])
        }
    }
    
    //Set - Unit Label
    private func setUnitLabelCenterXConstraints(){
        func centerYOffset()->CGFloat{
            return -1 * (maxLabelSize + unitVerticalSpacing)/2
        }
        
        //
        if let parentView = unitLabel.superview{
            parentView.removeConstraints(parentView.constraints)
            setCenterConstraints(view: unitLabel, yOffset: centerYOffset())
        }
        
    }
    
    //Set - Value Label
    private func setValueLabelCenterConstraints(){
        func centerYOffset()->CGFloat{
            if unit == ""{
                return 0.0
            }else{
                return (unitSize + unitVerticalSpacing)/2
            }
        }
        
        //
        if let parentView = valueLabel.superview{
            parentView.removeConstraints(parentView.constraints)
            setCenterConstraints(view: valueLabel, yOffset: centerYOffset())
        }
    }
    
    private func setValueLabelLeftAlignedConstraints(yPosition yPosition:CGFloat){
        func leading()->CGFloat{
            let newScale = self.minLabelSize/self.maxLabelSize
            let spaceScale = (1 - newScale)/2
            return -1 * spaceScale * self.valueLabel.bounds.width
        }
        
        func initialTop()->CGFloat{
            let newScale = self.minLabelSize/self.maxLabelSize
            let spaceScale = (1 - newScale)/2
            return spaceScale * self.maxLabelSize
        }
        
        if let parentView = valueLabel.superview{
            parentView.removeConstraints(parentView.constraints)
            let metrics = ["y":yPosition - initialTop(),"leading":leading()]
            let views = ["label":valueLabel]
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-leading-[label]", options: [], metrics: metrics, views: views)
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-y-[label]", options: [], metrics: metrics, views: views)
            parentView.addConstraints(hConstraints)
            parentView.addConstraints(vConstraints)
        }
    }
    
    //MARK: Refreshing
    private func refreshLabel(){
        let valueFormat:String
        let correctedValue:Double
        if continuous{
            valueFormat = "%0.2f"
            correctedValue = privateValue
        }else{
            valueFormat = "%0.0f"
            correctedValue = round(privateValue)
        }
        let valueText = String(format: valueFormat, correctedValue)
        valueLabel.text = "\(textPrefix)\(valueText)\(textSuffix)"
    }
    
    private func refreshUnitLabel(){
        let correctedUnit = unit.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: " ")).uppercaseString
        unitLabel.text = correctedUnit
    }
    
    private func refreshValue(){
        privateValue = Double(convertCGFloat(currentYPosition, min1: minYPosition, max1: maxYPosition, min2: CGFloat(minValue), max2: CGFloat(maxValue)))
    }
    
    private func refreshYPosition(){
        currentYPosition = CGFloat(convertDouble(privateValue, min1: minValue, max1: maxValue, min2: Double(minYPosition), max2: Double(maxYPosition)))
    }
    
    //MARK: - Misc methods
    private func convertDouble(value:Double,min1:Double,max1:Double,min2:Double,max2:Double)->Double{
        let range2 = max2 - min2
        let range1 = max1 - min1
        return (((value - min1) * range2) / range1) + min2
    }
    
    private func convertCGFloat(value:CGFloat,min1:CGFloat,max1:CGFloat,min2:CGFloat,max2:CGFloat)->CGFloat{
        let range2 = max2 - min2
        let range1 = max1 - min1
        return (((value - min1) * range2) / range1) + min2
    }
    
    private func correctValueIfNeeded(){
        privateValue = min(maxValue,max(minValue,privateValue))
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(superview?.bounds.width ?? 320.0, 200)
    }
}

extension PannablePickerView{
    public override func animationDidStop(anim: CAAnimation, finished flag: Bool) {
        if flag{
            transitionAnimation = nil
        }
    }
}