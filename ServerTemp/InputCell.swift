//
//  InputCell.swift
//  ServerTemp
//
//  Created by BdevNameless on 01.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

protocol InputCellDelegate {
    func checkChanges(sender: InputCell)
}

class InputCell: UITableViewCell, UITextFieldDelegate {
    
    // Outlets
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    var delegate: InputCellDelegate? = nil
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepareForReuse() {
        delegate = nil
    }
    
    internal func printAction() {
        if let del = delegate{
            del.checkChanges(self)
        }
    }
    
}
