//
//  InsideTableViewViewController.swift
//  PannablePickerView
//
//  Created by Diego Alberto Cruz Castillo on 12/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import PannablePickerView

class InsideTableViewViewController: UITableViewController {
    //MARK: - Properties
    @IBOutlet weak var amountLabel: UILabel!
    
    //MARK: - Action methods
    @IBAction func valueChanged(sender: PannablePickerView) {
        let valueText = String(format: "%0.2f", sender.value)
        amountLabel.text = "$\(valueText)"
    }
}
