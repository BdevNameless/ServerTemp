//
//  FetchSettingsViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 17.06.16.
//  Copyright © 2016 Nikita Karaulov. All rights reserved.
//

import UIKit

class FetchSettingsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    //MARK: - Private attributes
    
    static private let kEnableBackgroundFetch = "enableBackgroundFetch"
    static private let kNotifyAboutTempIncrease = "notifyAboutTempIncrease"
    
    private var historyValue: Int {
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("historyValue")
        }
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "historyValue")
        }
    }
//    private var historyUnit: Int {
//        get {
//            return NSUserDefaults.standardUserDefaults().integerForKey("historyUnit")
//        }
//        set {
//            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "historyUnit")
//        }
//    }
    
    private var pickerVisible: Bool = false
    
    private let possibleValues = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24]
    
    //MARK: - Outlets
    
    @IBOutlet weak var fetchCell: SwitchCell!
    @IBOutlet weak var notifCell: SwitchCell!
    @IBOutlet weak var pickerCell: PickerCell!
    @IBOutlet weak var historyPicker: UIPickerView!
    @IBOutlet weak var historyLabel: UILabel!

    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        
        configureView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Private methods
    
    private func configureView() {
        
        // Switches
        let defaults = NSUserDefaults.standardUserDefaults()
        let fetchEnabled = defaults.boolForKey(FetchSettingsViewController.kEnableBackgroundFetch)
        let notifEnabled = defaults.boolForKey(FetchSettingsViewController.kNotifyAboutTempIncrease)
        fetchCell.ui_switch.on = fetchEnabled
        notifCell.ui_switch.on = notifEnabled
        fetchCell.ui_switch.addTarget(self, action: #selector(FetchSettingsViewController.switchValueChanged(_:)), forControlEvents: .ValueChanged)
        notifCell.ui_switch.addTarget(self, action: #selector(FetchSettingsViewController.switchValueChanged(_:)), forControlEvents: .ValueChanged)
        notifCell.label.enabled = fetchEnabled
        notifCell.ui_switch.enabled = fetchEnabled
        
        // Picker
        historyPicker.delegate = self
        historyPicker.dataSource = self
        historyPicker.selectRow(possibleValues.indexOf(historyValue)!, inComponent: 0, animated: false)
//        historyPicker.selectRow(historyUnit, inComponent: 1, animated: false)
        
        // historyLabel
        historyLabel.text = Utils.realtiveStringForHours(historyValue)
        
    }
    
    @objc private func switchValueChanged(sender: UISwitch) {
        let defaults = NSUserDefaults.standardUserDefaults()
        switch sender {
        case fetchCell.ui_switch:
            let newValue = fetchCell.ui_switch.on
            defaults.setBool(newValue, forKey: FetchSettingsViewController.kEnableBackgroundFetch)
            notifCell.label.enabled = newValue
            notifCell.ui_switch.enabled = newValue
            break
        case notifCell.ui_switch:
            defaults.setBool(notifCell.ui_switch.on, forKey: FetchSettingsViewController.kNotifyAboutTempIncrease)
            break
        default:
            break
        }
        defaults.synchronize()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        }
        return 1
    }
    
    //MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0&&indexPath.row == 0 {
            pickerVisible = !pickerVisible
            tableView.beginUpdates()
            tableView.endUpdates()
            UIView.animateWithDuration(0.25) { [unowned self] in
                self.historyPicker.alpha = self.pickerVisible ? 1.0 : 0.0
            }
            if !pickerVisible {
                historyValue = possibleValues[historyPicker.selectedRowInComponent(0)]
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 1 {
            return pickerVisible ? 140 : 0
        }
        return 44
    }
    
    //MARK: - UIPicker Data Source
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
//        return 2
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return possibleValues[component].count
        return possibleValues.count
    }
    
    //MARK: - UIPicker Delegate
    
    func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let s_title = "\(possibleValues[row])"
//        let s_title = Utils.realtiveStringForHours(possibleValues[row])
        return NSAttributedString(string: s_title, attributes: [NSForegroundColorAttributeName: UIColor.lightGrayColor()])
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        print("\(possibleValues[component][row])")
        historyLabel.text = Utils.realtiveStringForHours(possibleValues[row])
    }

}
