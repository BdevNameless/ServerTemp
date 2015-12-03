//
//  VPNSettingsViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 03.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit
import NetworkExtension
import MBProgressHUD

class VPNSettingsViewController: UITableViewController, InputCellDelegate {

    //MARK: - Instance Variables
    private let VPNSettings = ["Адрес сервера", "Имя группы", "Общий ключ", "Учетная запись", "Пароль"]
    private let vpnConfig = VPNConfiguration()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    internal func statusChanged(aNotif: NSNotification){
        if vpnConfig.connectionStatus.rawValue == 3 {
            // USPEX
            let alertVC = UIAlertController(title: "Подключение VPN", message: "Подключение по VPN установлено.", preferredStyle: .Alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertVC, animated: true) { [unowned self] in
                self.vpnConfig.stopVPN()
            }
        }
    }
    
    internal func testButtonTapped() {
        do {
            try vpnConfig.testConnection()
        }
        catch {
            print("\(error)")
        }
    }
    
    internal func delButtonTapped() {
        print("DEL THIS")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusChanged:", name: NEVPNStatusDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NEVPNStatusDidChangeNotification, object: nil)
        vpnConfig.saveConfiguration()
        vpnConfig.stopVPN()
    }
    
    //MARK: - Private Methods
    
    func checkChanges(sender: InputCell) {
        switch sender.label.text! {
            case "Адрес сервера":
                vpnConfig.serverAddress = sender.textField.text
                break
            case "Имя группы":
                vpnConfig.groupName = sender.textField.text
                break
            case "Общий ключ":
                vpnConfig.sharedKey = sender.textField.text
                break
            case "Учетная запись":
                vpnConfig.username = sender.textField.text
                break
            case "Пароль":
                vpnConfig.password = sender.textField.text
                break
            default:
                break
        }
    }
    
    private func setValueForVPNField(fieldName: String, cell: InputCell) {
        switch fieldName {
        case "Адрес сервера":
            cell.textField.text = vpnConfig.serverAddress
            break
        case "Имя группы":
            cell.textField.text = vpnConfig.groupName
            break
        case "Общий ключ":
            cell.textField.text = vpnConfig.sharedKey
            break
        case "Учетная запись":
            cell.textField.text = vpnConfig.username
            break
        case "Пароль":
            cell.textField.text = vpnConfig.password
            break
        default:
            break
        }
    }
    
    
    //MARK: - TabelView Delegate
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return VPNSettings.count
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let aCell = tableView.dequeueReusableCellWithIdentifier("InputCell") as! InputCell
            configureInputCell(aCell, forIndexPath: indexPath)
            return aCell
        }
        let aCell = tableView.dequeueReusableCellWithIdentifier("ButtonCell") as! ButtonCell
        configureButtonCell(aCell, forIndexPath: indexPath)
        return aCell
    }
    
    private func configureButtonCell(cell: ButtonCell, forIndexPath indexPath: NSIndexPath) {
        cell.selectionStyle = .None
        if indexPath.section == 1 {
            cell.button.setTitle("Проверить соединение", forState: .Normal)
            cell.button.addTarget(self, action: "testButtonTapped", forControlEvents: .TouchUpInside)
        }
        else {
            cell.button.setTitle("Удалить конфигурацию", forState: .Normal)
            cell.button.setTitleColor(UIColor.redColor(), forState: .Normal)
            cell.button.addTarget(self, action: "delButtonTapped", forControlEvents: .TouchUpInside)
        }
    }
    
    private func configureInputCell(cell: InputCell, forIndexPath indexPath: NSIndexPath) {
        let secureFields: Set<String> = ["Общий ключ", "Пароль"]
        let setting = VPNSettings[indexPath.row]
        setValueForVPNField(setting, cell: cell)
        cell.label.text = setting
        if secureFields.contains(setting) {
            cell.textField.secureTextEntry = true
        }
        cell.selectionStyle = .None
        cell.textField.delegate = cell
        cell.textField.addTarget(cell, action: "printAction", forControlEvents: .EditingDidEnd)
        cell.delegate = self
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            let aCell = tableView.cellForRowAtIndexPath(indexPath)
            (aCell as! InputCell).textField.becomeFirstResponder()
        }
    }
}
