//
//  AsAnInputViewTableViewController.swift
//  PannablePickerView
//
//  Created by Diego Alberto Cruz Castillo on 12/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import PannablePickerView

class AsAnInputViewTableViewController: UITableViewController, UITextFieldDelegate{
    //MARK: - Properties
    //MARK: IBOutlets
    @IBOutlet weak var yearTextField: UITextField!
    //MARK: Variables
    lazy var pannablePickerView:UIView = {
        let pickerView = PannablePickerView()
        pickerView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 200)
        pickerView.addTarget(self, action: "valueChanged:", forControlEvents: .ValueChanged)
        pickerView.minValue = 2005
        pickerView.maxValue = 2015
        pickerView.value = 2015
        pickerView.unit = "year"
        return pickerView
    }()
    
    
    //MARK: - View events methods
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        yearTextField.becomeFirstResponder()
    }
    
    //MARK: - UITextField delegate methods
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        textField.inputView = pannablePickerView
        return true
    }
    
    //MARK: - Action methods
    func valueChanged(sender:PannablePickerView){
        let valueText = String(format: "%0.0f", sender.value)
        yearTextField.text = "\(valueText)"
    }
}
