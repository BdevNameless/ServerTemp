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
    private var vpnStatusSwitch: UISwitch? = nil
    private var vpnStatusLabel: UILabel? = nil
    private var progressHUD: MBProgressHUD? = nil
    private var isChangingVPNStatus: Bool = false {
        didSet {
            if isChangingVPNStatus {
                self.view.userInteractionEnabled = false
                navigationController?.navigationBar.userInteractionEnabled = false
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                
            }
            else {
                self.view.userInteractionEnabled = true
                navigationController?.navigationBar.userInteractionEnabled = true
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                if progressHUD != nil {
                    progressHUD!.hide(true)
                }
            }
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VPNSettingsViewController.statusChanged(_:)), name: NEVPNStatusDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NEVPNStatusDidChangeNotification, object: nil)
        vpnConfig.saveConfiguration()
    }
    
    //MARK: - Internal Handlers
    internal func changeSwitchValue() {
        vpnSwitch!.setOn(!vpnSwitch!.on, animated: true)
        switchChanged(vpnSwitch!)
    }
    
    internal func switchChanged(sender: UISwitch) {
        switch sender {
        case vpnSwitch!:
            vpnConfig.managerEnabled = sender.on
            break
        case vpnStatusSwitch!:
            isChangingVPNStatus = true
            if sender.on {
                tryStartVPNTunnel()
            }
            else {
                vpnConfig.stopVPN()
            }
            break
        default:
            break
        }
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
        
        switch vpnConfig.connectionStatus {
        case .Connected:
            vpnStatusSwitch?.setOn(true, animated: true)
            isChangingVPNStatus = false
            vpnStatusLabel?.text = "Подключено"
            break
        case .Disconnected:
            vpnStatusSwitch?.setOn(false, animated: true)
            isChangingVPNStatus = false
            vpnStatusLabel?.text = "Отключено"
            break
        case .Connecting:
            vpnStatusLabel?.text = "Подключаюсь..."
            break
        default:
            break
        }
        
    }
    
    //MARK: - Private Methods
    
    private func tryStartVPNTunnel() {
        vpnConfig.saveConfiguration() { [unowned self] (error) in
            do {
                try self.vpnConfig.startVPN()
            }
            catch VPNError.InvalidVPNConfoguration {
                
            }
            catch VPNError.ErrorWhileStartingVPNTunnel(let error) {
                print(error)
            }
            catch {
                print("WTF IS THAT")
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
        else if indexPath.section == 1 {
            let aCell = tableView.dequeueReusableCellWithIdentifier("SwitchCell") as! SwitchCell
            aCell.selectionStyle = .None
            switch indexPath.row {
            case 0:
                aCell.label.text = "Использовать VPN"
                vpnSwitch = aCell.ui_switch
                aCell.ui_switch.on = vpnConfig.managerEnabled
                aCell.ui_switch.addTarget(self, action: #selector(VPNSettingsViewController.switchChanged), forControlEvents: .ValueChanged)
                break
            case 1:
                aCell.label.text = "Статус"
                vpnStatusSwitch = aCell.ui_switch
                aCell.ui_switch.on = vpnConfig.connectionStatus == .Connected
                aCell.statusLabel.hidden = false
                vpnStatusLabel = aCell.statusLabel
                switch vpnConfig.connectionStatus {
                case .Connected:
                    aCell.statusLabel.text = "Подключено"
                    break
                case .Disconnected:
                    aCell.statusLabel.text = "Отключено"
                    break
                case .Connecting:
                    aCell.statusLabel.text = "Подключаюсь..."
                    break
                default:
                    break
                }
                aCell.ui_switch.addTarget(self, action: #selector(VPNSettingsViewController.switchChanged), forControlEvents: .TouchUpInside)
                break
            default:
                break
            }
            return aCell
        }
        let aCell = tableView.dequeueReusableCellWithIdentifier("ButtonCell") as! ButtonCell
        configureButtonCell(aCell, forIndexPath: indexPath)
        return aCell
    }
    
    private func configureButtonCell(cell: ButtonCell, forIndexPath indexPath: NSIndexPath) {
        delCell = cell
        cell.label.text = "Удалить конфигурацию"
        cell.label.textColor = UIColor.redColor()
        cell.spanner.hidden = true
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
        cell.textField.addTarget(cell, action: #selector(InputCell.printAction), forControlEvents: .EditingDidEnd)
        cell.delegate = self
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let aCell = tableView.cellForRowAtIndexPath(indexPath)
            (aCell as! InputCell).textField.becomeFirstResponder()
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
