//
//  FetchSettingsViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 17.06.16.
//  Copyright © 2016 Nikita Karaulov. All rights reserved.
//

import UIKit

class FetchSettingsViewController: UITableViewController {
    
    // Private attributes
    
    static private let kEnableBackgroundFetch = "enableBackgroundFetch"
    static private let kNotifyAboutTempIncrease = "notifyAboutTempIncrease"
    private var pickerVisible: Bool = false
    
    // Outlets
    
    @IBOutlet weak var fetchCell: SwitchCell!
    @IBOutlet weak var notifCell: SwitchCell!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private methods
    
    private func updateView() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let fetchEnabled = defaults.boolForKey(FetchSettingsViewController.kEnableBackgroundFetch)
        let notifEnabled = defaults.boolForKey(FetchSettingsViewController.kNotifyAboutTempIncrease)
        fetchCell.ui_switch.on = fetchEnabled
        notifCell.ui_switch.on = notifEnabled
        fetchCell.ui_switch.addTarget(self, action: #selector(FetchSettingsViewController.switchValueChanged(_:)), forControlEvents: .ValueChanged)
        notifCell.ui_switch.addTarget(self, action: #selector(FetchSettingsViewController.switchValueChanged(_:)), forControlEvents: .ValueChanged)
        notifCell.label.enabled = fetchEnabled
        notifCell.ui_switch.enabled = fetchEnabled
    }
    
    @objc private func switchValueChanged(sender: UISwitch) {
        
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }

}
