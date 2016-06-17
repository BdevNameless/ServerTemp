//
//  StartupViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 20.05.16.
//  Copyright © 2016 Nikita Karaulov. All rights reserved.
//

import UIKit
import NetworkExtension
import SWRevealViewController

class StartupViewController: UIViewController {
    
    private var vpnConfig = VPNConfiguration()
    private var startingVPN: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        checkVPNUsage()
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        checkVPNUsage()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    internal func statusChanged(aNotif: NSNotification){
        guard startingVPN else {
            return
        }
        
        print(vpnConfig.connectionStatus.rawValue)
        
        switch vpnConfig.connectionStatus {
        case .Connected:
            self.moveForvard()
            break
        case .Disconnected:
            self.moveForvard(true)
            break
        case .Invalid:
            self.moveForvard(true)
            break
        default:
            break
        }
        
    }
    
    private func checkVPNUsage() {
//        vpnConfig.loadConfigugarion { [unowned self] (error) in
//            if error == nil {
//                if self.vpnConfig.managerEnabled && self.vpnConfig.connectionStatus != .Connected {
//                    self.startVPNTunnel()
//                }
//                else {
//                    self.moveForvard()
//                }
//            }
//        }
        moveForvard()
    }
    
    private func startVPNTunnel() {
        startingVPN = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StartupViewController.statusChanged(_:)), name: NEVPNStatusDidChangeNotification, object: nil)
        do {
            try vpnConfig.startVPN()
        }
        catch {
            print("ERROR WHILE STARTING VPN")
        }
    }
    
    private func moveForvard(withError: Bool = false) {
        let revealVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("revealVC") as! SWRevealViewController
    
        UIApplication.sharedApplication().keyWindow?.rootViewController = revealVC
        
        if withError == false {
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainPageViewController") as! MainPageViewController
            revealVC.setFrontViewController(vc, animated: true)
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
