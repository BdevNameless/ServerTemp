//
//  TestConnectionViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 02.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit
import NetworkExtension

class TestConnectionViewController: UIViewController {
    
    //MARK: - Outlents
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connButton: UIButton!
    @IBAction func connButtonTapped(sender: UIButton) {
        
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        confugureVPN()
    }
    
    private func configureView() {
        view.backgroundColor = UIColor.blackColor()
        connButton.layer.borderWidth = 2.0
        connButton.layer.cornerRadius = 15.0
        connButton.layer.borderColor = UIColor.greenColor().CGColor
        textView.userInteractionEnabled = false
        textView.backgroundColor = UIColor.blackColor()
        textView.layer.borderWidth = 3.0
        textView.layer.borderColor = UIColor.greenColor().CGColor
        textView.text = "⬆︎JUST TAP THIS FCKING BUTTON⬆︎"
    }
    
    private func confugureVPN() {
        let manager = NEVPNManager.sharedManager()
        manager.loadFromPreferencesWithCompletionHandler() { [unowned self] (error: NSError?) in
            if error != nil {
                self.textView.text = self.textView.text + "\n\(error)"
            }
            else{
                self.textView.text = self.textView.text + "\nVPN MANAGER УСПЕШНО ЗАГРУЖЕН"
            }
        }
    }
    
}
