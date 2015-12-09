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
    
    private let vpnConfig = VPNConfiguration()
    private let zbxConfig = ZabbixConfiguration()
    private let zbxManager = ZabbixManager.sharedInstance
    
    //MARK: - Outlents
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connButton: UIButton!
    @IBAction func connButtonTapped(sender: UIButton) {
        zbxManager.freshTempFor300Serv() { [unowned self] (fetchError: NSError?, res: JSON?) in
            guard fetchError == nil else {
                self.showAlertForError(fetchError!)
                return
            }
            self.addLog("\(res)")
            let array = res!.arrayValue
            for item in array {
                let formatter = NSDateFormatter()
                formatter.locale = NSLocale.currentLocale()
                formatter.dateFormat = "dd MMMM yyyy hh:mm:ss"
                self.addLog(formatter.stringFromDate(NSDate(timeIntervalSince1970: item["clock"].doubleValue)))
            }
        }
    }
    
    //MARK: - ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setNeedsStatusBarAppearanceUpdate()
        configureReveal()
        configureView()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    //MARK: - PrivateMethods
    
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
    
    private func showAlertForError(error: NSError) {
        let message = error.userInfo["NSLocalizedDescription"] as? String
        let alert = UIAlertController(title: error.domain, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}


