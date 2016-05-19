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
    private var temp23663: ReportValue? = nil {
        didSet {
            if temp23663 != nil {
                leftScaleView.setValue(temp23663!.value!, animated: true)
                leftTempLabel.temperature = temp23663!.value!
            }
        }
    }
    private var temp23664: ReportValue? = nil {
        didSet {
            if temp23664 != nil {
                rightScaleView.setValue(temp23664!.value!, animated: true)
                rightTempLabel.temperature = temp23664!.value!
            }
        }
    }

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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.orientationChanged(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
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
        let fetchQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
        let fetchGroup = dispatch_group_create()
        var freshResult: [String: ReportValue]? = nil
        var historyResult: [ReportValue]? = nil
        dispatch_async(fetchQueue) { [unowned self] in
            dispatch_group_enter(fetchGroup)
            self.zbxManager.getFresh300Report() { (fetchError: NSError?, result: [String: ReportValue]?) in
                if fetchError != nil {
                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        self.showAlertForError(fetchError!)
                    }
                }
                if result != nil {
                    freshResult = result!
                }
                dispatch_group_leave(fetchGroup)
            }
            dispatch_group_enter(fetchGroup)
            self.zbxManager.get300History(10) { (fetchError: NSError?, result: [ReportValue]?) in
                if fetchError != nil {
                    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                        self.showAlertForError(fetchError!)
                    }
                }
                historyResult = [ReportValue(val: 24.5,clock: NSDate().dateByAddingTimeInterval(-3600*9)),
                ReportValue(val: 24.0,clock: NSDate().dateByAddingTimeInterval(-3600*8)),
                ReportValue(val: 25.0,clock: NSDate().dateByAddingTimeInterval(-3600*7)),
                ReportValue(val: 23.5,clock: NSDate().dateByAddingTimeInterval(-3600*6)),
                ReportValue(val: 23.5,clock: NSDate().dateByAddingTimeInterval(-3600*5)),
                ReportValue(val: 23.0,clock: NSDate().dateByAddingTimeInterval(-3600*4)),
                ReportValue(val: 24.0,clock: NSDate().dateByAddingTimeInterval(-3600*3)),
                ReportValue(val: 24.5,clock: NSDate().dateByAddingTimeInterval(-3600*2)),
                ReportValue(val: 25.0,clock: NSDate().dateByAddingTimeInterval(-3600)),
                ReportValue(val: 24.5,clock: NSDate())]
//                if result != nil {
//                    historyResult = result!
//                }
                dispatch_group_leave(fetchGroup)
            }
            dispatch_group_wait(fetchGroup, DISPATCH_TIME_FOREVER)
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                if self.progressHUD != nil {
                    self.progressHUD!.hide(true)
                }
                if freshResult != nil {
                    self.temp23663 = freshResult!["23663"]
                    self.temp23664 = freshResult!["23664"]
                }
                if historyResult != nil {
                    self.graphView.report = historyResult!
                    self.updateLabelsWithData(historyResult!)
                }
            }
        }
    }
    
    private func updateLabelsWithData(report: [ReportValue]) {
        guard report.count > 0 else {
            print("HISTORY REPORT IS EMPTY!!!")
            return
        }
        var temps: [Double] = []
        var aver: Double = 0
        for item in report {
            temps.append(item.value!)
            aver += item.value!
        }
        averageTempLabel.text = String(format: "%.2f ℃", aver / Double(temps.count))
        midTempLabel.text = String(format: "%.1f", 15 + ((temps.maxElement()! - 15) / 2))
        maxTempLabel.text = "\(temps.maxElement()!)"
        
    }
    
    private func showAlertForError(error: NSError) {
        let message = error.userInfo["NSLocalizedDescription"] as? String
        let alert = UIAlertController(title: error.domain, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}

