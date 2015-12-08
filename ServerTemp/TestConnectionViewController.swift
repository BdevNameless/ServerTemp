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
import Alamofire
import SwiftyJSON

class TestConnectionViewController: UIViewController {
    
    private let vpnManager = VPNConfiguration()
    private let zbxManager = ZabbixConfiguration()
    
    //MARK: - Outlents
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connButton: UIButton!
    @IBAction func connButtonTapped(sender: UIButton) {
        ZabbixManager.sharedInstance.login() { [unowned self] (loginError: NSError?) in
            self.addLog("\(loginError)")
        }
    }
    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        addHandlers()
        configureReveal()
        configureView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        removeHandlers()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - Internal Handlers
    
    internal func vpnStatusChanged(aNotif: NSNotification) {
        addLog("\(vpnManager.connectionStatus.rawValue)")
    }
    
    //MARK: - PrivateMethods
    
    private func addHandlers() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "vpnStatusChanged:", name: NEVPNStatusDidChangeNotification, object: nil)
    }
    
    private func removeHandlers() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func addLog(string: String) {
        textView.text = textView.text + ">" + string + "\n"
    }
    
    private func configureReveal() {
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    private func configureView() {
        view.backgroundColor = UIColor.blackColor()
        connButton.setTitle("BUTTON", forState: .Normal)
        connButton.layer.borderWidth = 2.0
        connButton.layer.cornerRadius = 15.0
        connButton.layer.borderColor = UIColor.greenColor().CGColor
        textView.userInteractionEnabled = true
        textView.backgroundColor = UIColor.blackColor()
        textView.layer.borderWidth = 3.0
        textView.layer.borderColor = UIColor.greenColor().CGColor
        textView.text = ""
    }
}


