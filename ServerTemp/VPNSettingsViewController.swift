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
    private var testCell: ButtonCell? = nil
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    internal func statusChanged(aNotif: NSNotification){
        print(vpnConfig.connectionStatus.rawValue)
        switch vpnConfig.connectionStatus.rawValue {
        case 3:
            // USPEX
            testCell?.label.text = "Подключено"
            let alertVC = UIAlertController(title: "Подключение VPN", message: "Подключение успешно установлено.", preferredStyle: .Alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alertVC, animated: true) { [unowned self] in
                self.vpnConfig.stopVPN()
            }
            break
        case 2:
            testCell?.label.text = "Подключаюсь"
            break
        case 1:
            view.userInteractionEnabled = true
            testCell?.spanner.stopAnimating()
            testCell?.label.text = "Проверить соединение"
            break
        default:
            break
        }
    }
    
    internal func testButtonTapped() {
        view.userInteractionEnabled = false
        testCell?.spanner.startAnimating()
        testCell?.spanner.hidden = false
        vpnConfig.testConnection()
    }
    
    internal func delButtonTapped() {
        let alertVC = UIAlertController(title: "Удаление", message: "Вы уверены что хотите удалить настройки?", preferredStyle: .Alert)
        alertVC.addAction(UIAlertAction(title: "Да", style: .Destructive) { (action: UIAlertAction) in
            print("DEL THIS")
        })
        alertVC.addAction(UIAlertAction(title: "Нет", style: .Default, handler: nil))
        presentViewController(alertVC, animated: true, completion: nil)
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
        if indexPath.section == 1 {
            testCell = cell
            cell.label.text = "Проверить соединение"
            cell.spanner.hidden = true
        }
        else {
            cell.label.text = "Удалить конфигурацию"
            cell.label.textColor = UIColor.redColor()
            cell.spanner.hidden = true
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
        switch indexPath.section {
        case 0:
            let aCell = tableView.cellForRowAtIndexPath(indexPath)
            (aCell as! InputCell).textField.becomeFirstResponder()
            break
        case 1:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            testButtonTapped()
            break
        case 2:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            delButtonTapped()
            break
        default:
            break
        }
    }
}
