//
//  SettingsViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 01.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, InputCellDelegate {
    
    //MARK: - Instance Variables
    private let VPNSettings = ["Адрес сервера", "Общий ключ", "Учетная запись", "Пароль"]
    private let ZabbixSettings = ["Пользователь", "Пароль"]
//    lazy private var vpnConfig = {
//        return VPNConfiguration()
//    }()
    private let vpnConfig = VPNConfiguration()
    lazy private var oldZabbixConfig = {
        return ZabbixConfiguration()
    }()
    lazy private var newZabbixConfig = {
        return ZabbixConfiguration()
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureReveal()
        configureNotificationHandling()
        saveButton.enabled = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        vpnConfig.saveConfiguration()
    }
    
    //MARK: - InterfaceBuilder
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        newZabbixConfig.saveConfiguration()
        saveButton.enabled = false
        updateConfigurations()
    }
    
    internal func updateData(aNotif: NSNotification?) {
        tableView.reloadData()
    }
    
    //MARK: - Private Methods
    private func configureNotificationHandling() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateData:", name: "VPNPreferencesLoaded", object: nil)
    }
    
    private func configureReveal() {
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    private func updateConfigurations() {
        UpdateZabbixConfig()
    }
    
    private func UpdateZabbixConfig() {
        oldZabbixConfig.loadConfigugarion()
    }
    
    private func setValueForZabbixField(fieldName: String, cell: InputCell) {
        switch fieldName {
        case "Пользователь":
            cell.textField.text = newZabbixConfig.username
            break
        case "Пароль":
            cell.textField.text = newZabbixConfig.password
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
    
    //MARK: - InputCellDelegate
    func checkChanges(sender: InputCell) {
        let indexPath = tableView.indexPathForCell(sender)!
        if (indexPath.section == 0){
            switch sender.label.text! {
                case "Адрес сервера":
                    vpnConfig.serverAddress = sender.textField.text
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
        else {
            switch sender.label.text! {
            case "Пользователь":
                newZabbixConfig.username = sender.textField.text
                break
            case "Пароль":
                newZabbixConfig.password = sender.textField.text
                break
            default:
                break
            }
        }
        if newZabbixConfig.isEqual(oldZabbixConfig) {
            saveButton.enabled = false
        }
        else {
            saveButton.enabled = true
        }
    }
    
    //MARK: - UITableViewDelegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return VPNSettings.count
        }
        return ZabbixSettings.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCellWithIdentifier("InputCell") as! InputCell
        configureCell(aCell, forIndexPath: indexPath)
        return aCell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Конфигурация VPN"
        }
        return "Конфигурация подключения к Zabbix-серверу"
    }
    
    private func configureCell(cell: InputCell, forIndexPath indexPath: NSIndexPath) {
        var setting: String
        let secureFields: Set<String> = ["Общий ключ", "Пароль"]
        if indexPath.section == 0 {
            setting = VPNSettings[indexPath.row]
            setValueForVPNField(setting, cell: cell)
        }
        else {
            setting = ZabbixSettings[indexPath.row]
            setValueForZabbixField(setting, cell: cell)
        }
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
        let aCell = tableView.cellForRowAtIndexPath(indexPath)
        (aCell as! InputCell).textField.becomeFirstResponder()
    }
    
    
    
}
