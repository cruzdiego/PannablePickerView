//
//  PannablePickerView.swift
//  Pods
//
//  Created by Diego Alberto Cruz Castillo on 12/22/15.
//
//

import UIKit

@objc public protocol PannablePickerViewDelegate: class{
    @objc optional func pannablePickerViewDidBeginPanning(_ sender:PannablePickerView)
    @objc optional func pannablePickerViewDidEndPanning(_ sender:PannablePickerView)
}

@IBDesignable public class PannablePickerView: UIControl {
    //MARK: - Properties
    //MARK: UI
    //*** General ***
    private var bgView:UIView?
    //***************
    
    //*** Content ***
    private var contentView:UIView?
    private var valueParentView:UIView?
    private var valueLabel: UILabel?
    private var unitParentView:UIView?
    private var unitLabel: UILabel?
    //***************
    
    //MARK: Other Properties
    //*** Type ***
    @IBInspectable public var continuous:Bool = false{
        didSet{
            didSetContinuous()
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
        set{
            privateValue = continuous ? newValue : round(newValue)
        }
    }
    @IBInspectable public var minValue:Double = 0{
        didSet{
            didSetMinValue(oldValue: oldValue)
        }
    }
    @IBInspectable public var maxValue:Double = 100{
        didSet{
            didSetMaxValue(oldValue: oldValue)
        }
    }
    //************
    
    //*** Label ***
    @IBInspectable public var minLabelSize:CGFloat = 30.0
    @IBInspectable public var maxLabelSize:CGFloat = 54.0{
        didSet{
            didSetMaxLabelSize()
        }
    }
    @IBInspectable public var textColor:UIColor = UIColor.white{
        didSet{
            didSetTextColor()
        }
    }
    @IBInspectable public var textPrefix:String = ""{
        didSet{
            didSetTextPrefix()
        }
    }
    @IBInspectable open var textSuffix:String = ""{
        didSet{
            didSetTextSuffix()
        }
    }
    //*************
    
    //*** Unit ***
    @IBInspectable open var unit:String = ""{
        didSet{
            didSetUnit()
        }
    }
    @IBInspectable open var unitColor:UIColor = UIColor.white{
        didSet{
            didSetUnitColor()
        }
    }
    @IBInspectable open var unitSize:CGFloat = 14.0{
        didSet{
            didSetUnitSize()
        }
    }
    //*************
    
    public var delegate:PannablePickerViewDelegate?
    
    //MARK: Private Properties
    //General
    private var panEnabled = false
    //Value
    private var privateValue:Double = 0{
        didSet{
            didSetPrivateValue(oldValue: oldValue)
        }
    }
    //Transition
    private let transitionDuration:CFTimeInterval = 0.15
    fileprivate var transitionAnimation: CABasicAnimation?
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
            guard   let contentView = contentView,
                let valueLabel = valueLabel else {
                    return 0.0
            }
            
            return contentView.bounds.maxY - (valueLabel.bounds.height * minLabelSize/maxLabelSize)
        }
    }
    private var currentYPosition: CGFloat = 0{
        didSet{
            didSetCurrentYPosition()
        }
    }
    //Touch
    private var touchBeganPoint:CGPoint?
    
    //MARK: - Public methods
    //MARK: Init
    init(){
        super.init(frame: CGRect.zero)
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
    
    //MARK: Touches events
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        func areMinMaxValuesValid()->Bool{
            return minValue<maxValue
        }
        
        //
        if areMinMaxValuesValid(){
            if let point = touches.first?.location(in: contentView){
                touchBeganPoint = point
                goToCurrentValuePosition(animated: true)
            }
        }else{
            NSLog("WARNING: PannablePickerView does not support a minValue equal or greater than maxValue")
        }
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let initialPoint = touchBeganPoint, let point = touches.first?.location(in: contentView), panEnabled{
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
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        goToCenter(animated: true)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchBeganPoint = nil
        goToCenter(animated: true)
    }
    
    //MARK: - Private methods
    //MARK: didSet
    private func didSetContinuous() {
        refreshLabel()
    }
    
    private func didSetMinValue(oldValue: Double) {
        if oldValue != minValue{
            correctValueIfNeeded()
        }
    }
    
    private func didSetMaxValue(oldValue: Double) {
        if oldValue != maxValue{
            correctValueIfNeeded()
        }
    }
    
    private func didSetMaxLabelSize() {
        valueLabel?.font = UIFont.systemFont(ofSize: maxLabelSize)
        setUnitLabelCenterXConstraints()
    }
    
    private func didSetTextColor() {
        valueLabel?.textColor = textColor
    }
    
    private func didSetTextPrefix() {
        refreshLabel()
    }
    
    private func didSetTextSuffix() {
        refreshLabel()
    }
    
    private func didSetUnit() {
        refreshUnitLabel()
        setValueLabelCenterConstraints()
    }
    
    private func didSetUnitColor() {
        unitLabel?.textColor = unitColor
    }
    
    private func didSetUnitSize() {
        unitLabel?.font = UIFont.systemFont(ofSize: unitSize, weight: UIFont.Weight.semibold)
        if let valueLabel = valueLabel {
            setCenterConstraints(valueLabel)
        }
    }
    
    private func didSetPrivateValue(oldValue: Double) {
        if oldValue != privateValue{
            correctValueIfNeeded()
            sendActions(for: .valueChanged)
            refreshLabel()
        }
    }
    
    private func didSetCurrentYPosition() {
        if panEnabled{
            setValueLabelLeftAlignedConstraints(currentYPosition)
            refreshValue()
        }
    }
    
    //MARK: Configure
    private func configure(){
        func configureBGView(){
            bgView = newUIView()
            guard let bgView = bgView else {
                return
            }
            
            addAndSetFullSizeConstraints(bgView, parentView: self)
        }
        
        func configureContentView(){
            //ContentView
            contentView = newUIView()
            guard let contentView = contentView else {
                return
            }
            
            addAndSetFullSizeConstraints(contentView, parentView: self,padding: 16)
        }
        
        func configureValueLabel(){
            //Parent
            valueParentView = newUIView()
            guard   let contentView = contentView,
                let valueParentView = valueParentView else {
                    return
            }
            
            addAndSetFullSizeConstraints(valueParentView, parentView: contentView)
            
            //Value
            valueLabel = UILabel(frame:CGRect.zero)
            if let valueLabel = valueLabel {
                valueLabel.translatesAutoresizingMaskIntoConstraints = false
                valueLabel.font = UIFont.systemFont(ofSize: maxLabelSize)
                valueLabel.textColor = self.textColor
                refreshLabel()
                valueParentView.addSubview(valueLabel)
                setValueLabelCenterConstraints()
            }
        }
        
        func configureUnitLabel(){
            //Parent
            unitParentView = newUIView()
            guard   let contentView = contentView,
                let unitParentView = unitParentView else {
                    return
            }
            
            addAndSetFullSizeConstraints(unitParentView, parentView: contentView)
            //Unit
            unitLabel = UILabel(frame: CGRect.zero)
            if let unitLabel = unitLabel {
                unitLabel.translatesAutoresizingMaskIntoConstraints = false
                unitLabel.font = UIFont.systemFont(ofSize: unitSize, weight: UIFont.Weight.semibold)
                unitLabel.textColor = self.unitColor
                refreshUnitLabel()
                unitParentView.addSubview(unitLabel)
                setUnitLabelCenterXConstraints()
            }
        }
        
        //
        configureBGView()
        configureContentView()
        configureValueLabel()
        configureUnitLabel()
    }
    
    //MARK: Util
    private func goToCurrentValuePosition(animated:Bool=false){
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
        UIView.animate(withDuration: duration(), animations: { () -> Void in
            let newScale = self.minLabelSize/self.maxLabelSize
            self.valueLabel?.transform = CGAffineTransform(scaleX: newScale, y: newScale)
            self.valueLabel?.alpha = 0.9
            self.unitLabel?.alpha = 0.0
            self.setValueLabelLeftAlignedConstraints(self.currentYPosition)
            self.valueParentView?.layoutIfNeeded()
        }, completion: {(completed)-> () in
            self.panEnabled = true
        })
    }
    
    private func goToCenter(animated:Bool=false){
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
        UIView.animate(withDuration: duration(), animations: { () -> Void in
            self.valueLabel?.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.valueLabel?.alpha = 1.0
            self.unitLabel?.alpha = 1.0
            self.setValueLabelCenterConstraints()
            self.valueParentView?.layoutIfNeeded()
        }, completion: {(completed) -> () in
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.unitLabel?.alpha = 1.0
            })
            
        })
    }
    
    private func newUIView()->UIView{
        let newView = UIView(frame: CGRect.zero)
        return newView
    }
    
    //MARK: NSLayoutConstraints
    //Add and Set
    fileprivate func addAndSetFullSizeConstraints(_ view:UIView,parentView:UIView, padding:CGFloat = 0){
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)
        //
        let metrics = ["padding":padding]
        let views = ["subview":view]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-padding-[subview]-padding-|", options: [], metrics: metrics, views: views)
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-padding-[subview]-padding-|", options: [], metrics: metrics, views: views)
        parentView.addConstraints(hConstraints)
        parentView.addConstraints(vConstraints)
    }
    
    fileprivate func addAndSetCenterConstraints(_ view:UIView,parentView:UIView){
        view.translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(view)
        setCenterConstraints(view)
    }
    
    //Set
    fileprivate func setCenterConstraints(_ view:UIView,yOffset:CGFloat=0.0){
        if let parentView = view.superview{
            let centerXConstraint = NSLayoutConstraint(item: parentView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            let centerYConstraint = NSLayoutConstraint(item: parentView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: yOffset)
            parentView.addConstraints([centerXConstraint,centerYConstraint])
        }
    }
    
    //Set - Unit Label
    fileprivate func setUnitLabelCenterXConstraints(){
        func centerYOffset()->CGFloat{
            return -1 * (maxLabelSize + unitVerticalSpacing)/2
        }
        
        //
        if  let unitLabel = unitLabel,
            let parentView = unitLabel.superview{
            parentView.removeConstraints(parentView.constraints)
            setCenterConstraints(unitLabel, yOffset: centerYOffset())
        }
    }
    
    //Set - Value Label
    fileprivate func setValueLabelCenterConstraints(){
        func centerYOffset()->CGFloat{
            if unit == ""{
                return 0.0
            }else{
                return (unitSize + unitVerticalSpacing)/2
            }
        }
        
        //
        if  let valueLabel = valueLabel,
            let parentView = valueLabel.superview{
            parentView.removeConstraints(parentView.constraints)
            setCenterConstraints(valueLabel, yOffset: centerYOffset())
        }
    }
    
    fileprivate func setValueLabelLeftAlignedConstraints(_ yPosition:CGFloat){
        guard let valueLabel = valueLabel else {
            return
        }
        
        func leading()->CGFloat{
            let newScale = self.minLabelSize/self.maxLabelSize
            let spaceScale = (1 - newScale)/2
            return -1 * spaceScale * valueLabel.bounds.width
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
            let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-leading-[label]", options: [], metrics: metrics, views: views)
            let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-y-[label]", options: [], metrics: metrics, views: views)
            parentView.addConstraints(hConstraints)
            parentView.addConstraints(vConstraints)
        }
    }
    
    //MARK: Refreshing
    fileprivate func refreshLabel(){
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
        valueLabel?.text = "\(textPrefix)\(valueText)\(textSuffix)"
    }
    
    fileprivate func refreshUnitLabel(){
        let correctedUnit = unit.trimmingCharacters(in: CharacterSet(charactersIn: " ")).uppercased()
        unitLabel?.text = correctedUnit
    }
    
    fileprivate func refreshValue(){
        privateValue = Double(convertCGFloat(currentYPosition, min1: minYPosition, max1: maxYPosition, min2: CGFloat(minValue), max2: CGFloat(maxValue)))
    }
    
    fileprivate func refreshYPosition(){
        currentYPosition = CGFloat(convertDouble(privateValue, min1: minValue, max1: maxValue, min2: Double(minYPosition), max2: Double(maxYPosition)))
    }
    
    //MARK: - Misc methods
    fileprivate func convertDouble(_ value:Double,min1:Double,max1:Double,min2:Double,max2:Double)->Double{
        let range2 = max2 - min2
        let range1 = max1 - min1
        return (((value - min1) * range2) / range1) + min2
    }
    
    fileprivate func convertCGFloat(_ value:CGFloat,min1:CGFloat,max1:CGFloat,min2:CGFloat,max2:CGFloat)->CGFloat{
        let range2 = max2 - min2
        let range1 = max1 - min1
        return (((value - min1) * range2) / range1) + min2
    }
    
    fileprivate func correctValueIfNeeded(){
        privateValue = min(maxValue,max(minValue,privateValue))
    }
    
    open override var intrinsicContentSize : CGSize {
        return CGSize(width: superview?.bounds.width ?? 320.0, height: 200)
    }
}

//MARK: - Delegate methods
//MARK: CAAnimationDelegate
extension PannablePickerView: CAAnimationDelegate{
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag{
            transitionAnimation = nil
        }
    }
}
