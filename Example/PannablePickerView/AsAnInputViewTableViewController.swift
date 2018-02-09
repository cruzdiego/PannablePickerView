//
//  AsAnInputViewTableViewController.swift
//  PannablePickerView
//
//  Created by Diego Alberto Cruz Castillo on 12/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import PannablePickerView

class AsAnInputViewTableViewController: UITableViewController{
    //MARK: - Properties
    //MARK: IBOutlets
    @IBOutlet weak var yearTextField: UITextField?
    //MARK: Variables
    public lazy var pannablePickerView:UIView = {
        let pickerView = PannablePickerView()
        pickerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200)
        pickerView.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        pickerView.backgroundColor = UIColor(red: 0.180, green: 0.659, blue: 0.929, alpha: 1.00)
        pickerView.minValue = 2005
        pickerView.maxValue = 2015
        pickerView.value = 2015
        pickerView.unit = "year"
        return pickerView
    }()
    
    //MARK: - Public methods
    //MARK: View events
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        yearTextField?.becomeFirstResponder()
    }
    
    //MARK: - Private methods
    //MARK: Actions
    @objc private func valueChanged(_ sender:PannablePickerView){
        let valueText = String(format: "%0.0f", sender.value)
        yearTextField?.text = "\(valueText)"
    }
}

//MARK: - Delegate methods
//MARK: UITextFieldDelegate
extension AsAnInputViewTableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.inputView = pannablePickerView
        return true
    }
}
