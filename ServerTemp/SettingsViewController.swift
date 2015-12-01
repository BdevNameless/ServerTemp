//
//  SettingsViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 01.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    //MARK: - Instance Variables
    private let VPNSettings = ["Адрес сервера", "Имя группы", "Общий ключ", "Учетная запись", "Пароль"]
    private let ZabbixSettings = ["Пользователь", "Пароль"]
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        }
        else {
            setting = ZabbixSettings[indexPath.row]
        }
        cell.label.text = setting
        if secureFields.contains(setting) {
            cell.textField.secureTextEntry = true
        }
        cell.selectionStyle = .None
        cell.textField.delegate = cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let aCell = tableView.cellForRowAtIndexPath(indexPath)
        (aCell as! InputCell).textField.becomeFirstResponder()
    }
    
}
