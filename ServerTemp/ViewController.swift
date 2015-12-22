//
//  ViewController.swift
//  CG
//
//  Created by BdevNameless on 10.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var leftScaleView: AnimatedScale!
    @IBOutlet weak var leftTempLabel: TempLabel!
    @IBOutlet weak var rightScaleView: AnimatedScale!
    @IBOutlet weak var rightTempLabel: TempLabel!
    @IBOutlet weak var averageTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var midTempLabel: UILabel!
    @IBOutlet weak var graphView: GraphView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureReveal()
        leftScaleView.setValue(0, animated: false)
        rightScaleView.setValue(0, animated: false)
        rightScaleView.animationDuration = 2
        leftScaleView.animationDuration = 2
        
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(
            time,
            dispatch_get_main_queue()) { [unowned self] in
                self.leftScaleView.setValue(22, animated: true)
                self.rightScaleView.setValue(19, animated: true)
        }

        // Do any additional setup after loading the view, typically from a nib.
        configureView()
    }
    
    private func configureReveal() {
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }

    private func configureView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "orientationChanged:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    internal func orientationChanged(aNofif: NSNotification) {
        leftScaleView.setNeedsDisplayInRect(leftScaleView.bounds)
        rightScaleView.setNeedsDisplayInRect(rightScaleView.bounds)
        graphView.setNeedsDisplayInRect(graphView.bounds)
    }

}

