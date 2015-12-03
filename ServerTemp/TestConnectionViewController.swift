//
//  TestConnectionViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 02.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit
import NetworkExtension
import SWRevealViewController

class TestConnectionViewController: UIViewController {
    
    private let vpnManager = VPNConfiguration()
    
    //MARK: - Outlents
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connButton: UIButton!
    @IBAction func connButtonTapped(sender: UIButton) {
        do {
            try vpnManager.startVPN()
        } catch let error {
            textView.text = textView.text + "\n>НЕ УДАЛОСЬ УСТАНОВИТЬ СОЕДИНЕНИЕ. ERROR CODE: \(error)."
            return
        }
        textView.text = textView.text + "\n>ПОДКЛЮЧЕНИЕ УСПЕШНО УСТАНОВЛЕНО."
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureReveal()
        configureView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        vpnManager.stopVPN()
    }
    
    //MARK: - PrivateMethods
    
    private func configureReveal() {
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
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
        textView.text = ""
    }
}
