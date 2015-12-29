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
        let fetchQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        let fetchGroup = dispatch_group_create()
        var freshResult: [String: ReportValue]? = nil
        var historyResult: [ReportValue]? = nil
        dispatch_async(fetchQueue) { [unowned self] in
            dispatch_group_enter(fetchGroup)
            self.zbxManager.getFresh300Report() { (fetchError: NSError?, result: [String: ReportValue]?) in
                if result != nil {
                    freshResult = result!
                }
                dispatch_group_leave(fetchGroup)
            }
            dispatch_group_enter(fetchGroup)
            self.zbxManager.get300History(10) { (fetchError: NSError?, result: [ReportValue]?) in
                if result != nil {
                    historyResult = result!
                }
                dispatch_group_leave(fetchGroup)
            }
            dispatch_group_wait(fetchGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                if freshResult != nil {
                    for item in freshResult!.values {
                        self.addLog(item.description())
                    }
                }
                if historyResult != nil {
                    for item in historyResult! {
                        self.addLog(item.description())
                    }
                }
            }
        }
//        dispatch_group_async(fetchGroup, fetchQueue) { [unowned self] in
//            print("starting 1")
//            self.zbxManager.getFresh300Report() { (fetchError: NSError?, result: [String: ReportValue]?) in
//                if result != nil {
//                    freshResult = result!
//                }
//            }
//        }
//        dispatch_group_async(fetchGroup, fetchQueue) { [unowned self] in
//            print("startring 2")
//            self.zbxManager.get300History(10) { (fetchError: NSError?, result: [ReportValue]?) in
//                if result != nil {
//                    historyResult = result!
//                }
//            }
//        }
//        dispatch_group_notify(fetchGroup, dispatch_get_main_queue()) { [unowned self] in
//            print("LOLOLO")
//            if freshResult != nil {
//                for item in freshResult!.values {
//                    self.addLog(item.description())
//                }
//            }
//            if historyResult != nil {
//                for item in historyResult! {
//                    self.addLog(item.description())
//                }
//            }
//        }
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


