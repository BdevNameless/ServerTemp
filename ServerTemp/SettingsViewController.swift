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
    private let VPNSettings = ["Адрес сервера", "Имя группы", "Общий ключ", "Учетная запись", "Пароль"]
    private let ZabbixSettings = ["Пользователь", "Пароль"]
    
    //MARK: Configurations
    lazy private var oldVPNConfig : VPNConfiguration = {
        return VPNConfiguration()
    }()
    lazy private var newVPNConfig: VPNConfiguration = {
        return VPNConfiguration()
    }()
    lazy private var oldZabbixConfig : ZabbixConfiguration = {
        return ZabbixConfiguration()
    }()
    lazy private var newZabbixConfig: ZabbixConfiguration = {
        return ZabbixConfiguration()
    }()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureReveal()
        saveButton.enabled = false
    }
    
    //MARK: - InterfaceBuilder
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        newVPNConfig.saveConfiguration()
        newZabbixConfig.saveConfiguration()
        saveButton.enabled = false
        updateConfigurations()
    }
    
    //MARK: - Private Model Methods
    
    private func configureReveal() {
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    private func updateConfigurations() {
        updateVPNConfig()
        UpdateZabbixConfig()
    }
    
    private func updateVPNConfig() {
        oldVPNConfig.loadConfigugarion()
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
            cell.textField.text = newVPNConfig.serverAddress
            break
        case "Имя группы":
            cell.textField.text = newVPNConfig.groupName
            break
        case "Общий ключ":
            cell.textField.text = newVPNConfig.sharedKey
            break
        case "Учетная запись":
            cell.textField.text = newVPNConfig.username
            break
        case "Пароль":
            cell.textField.text = newVPNConfig.password
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
                newVPNConfig.serverAddress = sender.textField.text
                break
            case "Имя группы":
                newVPNConfig.groupName = sender.textField.text
                break
            case "Общий ключ":
                newVPNConfig.sharedKey = sender.textField.text
                break
            case "Учетная запись":
                newVPNConfig.username = sender.textField.text
                break
            case "Пароль":
                newVPNConfig.password = sender.textField.text
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
        if (newVPNConfig.isEqual(oldVPNConfig)&&(newZabbixConfig.isEqual(oldZabbixConfig))){
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
        let aCell = tableView.dequeueReusableCellWithIdentifier("InputCell")
        configureCell(aCell as! InputCell, forIndexPath: indexPath)
        return aCell!
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
        cell.textField.addTarget(cell, action: "textChanged", forControlEvents: .EditingChanged)
        cell.delegate = self
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let aCell = tableView.cellForRowAtIndexPath(indexPath)
        (aCell as! InputCell).textField.becomeFirstResponder()
    }
    
    
    
}
