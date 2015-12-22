//
//  TempLabel.swift
//  CG
//
//  Created by BdevNameless on 11.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

@IBDesignable class TempLabel: UILabel {
    @IBInspectable var temperature: Double = 20 {
        didSet{
            updateTemp()
        }
    }
    
    private func updateTemp() {
        text = "\(temperature)"
    }
}
