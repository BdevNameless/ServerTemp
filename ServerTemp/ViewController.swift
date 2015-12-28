//
//  ViewController.swift
//  CG
//
//  Created by BdevNameless on 10.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit
import MBProgressHUD

class ViewController: UIViewController {
    @IBOutlet weak var leftScaleView: AnimatedScale!
    @IBOutlet weak var leftTempLabel: TempLabel!
    @IBOutlet weak var rightScaleView: AnimatedScale!
    @IBOutlet weak var rightTempLabel: TempLabel!
    @IBOutlet weak var averageTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var midTempLabel: UILabel!
    @IBOutlet weak var graphView: GraphView!
    private var progressHUD: MBProgressHUD? = nil
    private let zbxManager = ZabbixManager.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        configureReveal()
        configureView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    private func configureReveal() {
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    private func configureView() {
        leftScaleView.setValue(0, animated: false)
        rightScaleView.setValue(0, animated: false)
        rightScaleView.animationDuration = 1.5
        leftScaleView.animationDuration = 1.5
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
        progressHUD = MBProgressHUD(view: view)
    }
    
    internal func orientationChanged(aNofif: NSNotification) {
        leftScaleView.setNeedsDisplayInRect(leftScaleView.bounds)
        rightScaleView.setNeedsDisplayInRect(rightScaleView.bounds)
        graphView.setNeedsDisplayInRect(graphView.bounds)
    }
    
    private func updateData() {
        if progressHUD != nil {
            view.addSubview(progressHUD!)
            progressHUD!.removeFromSuperViewOnHide = true
            progressHUD!.show(true)
        }
        zbxManager.getFresh300Report() { [unowned self] (fetchError: NSError?, result: [String: ReportValue]?) in
            if self.progressHUD != nil {
                self.progressHUD!.hide(true)
            }
            guard fetchError == nil else {
                self.showAlertForError(fetchError!)
                return
            }
            self.leftScaleView.setValue(result!["23663"]!.value!, animated: true)
            self.leftTempLabel.temperature = result!["23663"]!.value!
            self.rightScaleView.setValue(result!["23664"]!.value!, animated: true)
            self.rightTempLabel.temperature = result!["23664"]!.value!
        }
    }
    
    private func showAlertForError(error: NSError) {
        let message = error.userInfo["NSLocalizedDescription"] as? String
        let alert = UIAlertController(title: error.domain, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}

