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
    private var delCell: ButtonCell? = nil
    private var vpnSwitch: UISwitch? = nil
    private var isChecking: Bool = false
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "statusChanged:", name: NEVPNStatusDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NEVPNStatusDidChangeNotification, object: nil)
        vpnConfig.saveConfiguration()
    }
    
    //MARK: - Internal Handlers
    internal func changeSwitchValue() {
        vpnSwitch!.setOn(!vpnSwitch!.on, animated: true)
        switchChanged()
    }
    
    internal func switchChanged() {
        print("SWITCH CHANGED TRIGGERED")
        vpnConfig.managerEnabled = vpnSwitch!.on
    }
    
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
    
    internal func statusChanged(aNotif: NSNotification){
        guard isChecking else {
            return
        }
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
            view.userInteractionEnabled = false
            testCell?.spanner.startAnimating()
            testCell?.spanner.hidden = false
            testCell?.label.text = "Подключаюсь"
            break
        case 1:
            isChecking = false
            view.userInteractionEnabled = true
            testCell?.spanner.stopAnimating()
            testCell?.label.text = "Проверить соединение"
            break
        default:
            break
        }
    }
    
    //MARK: - Private Methods
    private func canTest() -> Bool {
        return (vpnConfig.managerEnabled)&&(vpnConfig.connectionStatus.rawValue != 0)
    }
    
    private func testButtonTapped() {
        isChecking = true
        vpnConfig.saveConfiguration() { [unowned self] (saveError: NSError?) in
            if saveError == nil {
                if (self.vpnConfig.connectionStatus.rawValue != 0) {
                    try! self.vpnConfig.startVPN()
                }
                else {
                    self.isChecking = false
                    let alert = UIAlertController(title: "Подключение VPN", message: "Некорректные данные", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
            else {
                self.isChecking = false
                self.showAlertForError(saveError!)
                self.tableView.reloadData()
            }
        }
    }
    
    private func delButtonTapped() {
        let alertVC = UIAlertController(title: "Удаление", message: "Вы уверены что хотите удалить настройки?", preferredStyle: .Alert)
        alertVC.addAction(UIAlertAction(title: "Да", style: .Destructive) { [unowned self] (action: UIAlertAction) in
            self.view.userInteractionEnabled = false
            self.delCell?.spanner.hidden = false
            self.delCell?.spanner.startAnimating()
            self.vpnConfig.removeConfiguration() { [unowned self] (error: NSError?) in
                self.delCell?.spanner.stopAnimating()
                self.view.userInteractionEnabled = true
                if error == nil {
                    self.vpnConfig.loadConfigugarion()
                    self.performAfterDelay(0.8) { [unowned self] in
                        self.tableView.reloadData()
                    }
                }
                else {
                    self.showAlertForError(error!)
                }
            }
        })
        alertVC.addAction(UIAlertAction(title: "Нет", style: .Default, handler: nil))
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    private func showAlertForError(error: NSError) {
        let message = error.userInfo["NSLocalizedDescription"] as? String
        let alert = UIAlertController(title: error.domain, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func performAfterDelay(delay: Double, block: () -> ()) {
        dispatch_after(
            dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            block
        )
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
        if section == 1 {
            return 2
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let aCell = tableView.dequeueReusableCellWithIdentifier("InputCell") as! InputCell
            configureInputCell(aCell, forIndexPath: indexPath)
            return aCell
        }
        else if ((indexPath.section == 1)&&(indexPath.row == 0)) {
            let aCell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
            aCell.label.text = "Использовать VPN"
            vpnSwitch = aCell.ui_switch
            aCell.ui_switch.on = vpnConfig.managerEnabled
            aCell.ui_switch.addTarget(self, action: "switchChanged", forControlEvents: .ValueChanged)
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
            delCell = cell
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
            cell.textField.keyboardAppearance = .Dark
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
            if vpnConfig.managerEnabled {
                testButtonTapped()
            }
            else {
                let alert = UIAlertController(title: "Подключение VPN", message: "Для тестирования подключения необходимо разрешить использование VPN. Разрешить?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Да", style: .Default) { [unowned self] (action: UIAlertAction) in
                    self.changeSwitchValue()
                    self.testButtonTapped()
                })
                alert.addAction(UIAlertAction(title: "Нет", style: .Default, handler: nil))
                presentViewController(alert, animated: true, completion: nil)
            }
            break
        case 2:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            delButtonTapped()
            break
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40.0
        }
        return super.tableView(tableView, heightForHeaderInSection: section)
    }
}
