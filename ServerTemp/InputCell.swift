//
//  InputCell.swift
//  ServerTemp
//
//  Created by BdevNameless on 01.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit


class InputCell: UITableViewCell, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
