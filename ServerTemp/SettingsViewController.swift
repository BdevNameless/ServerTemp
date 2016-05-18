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
    private let ZabbixSettings = ["IP-адрес сервера","Пользователь", "Пароль"]
    private let vpnConfig = VPNConfiguration(true)
    private let zabbixConfig = ZabbixConfiguration()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureReveal()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    internal func updateData(aNotif: NSNotification?) {
        tableView.reloadData()
    }
    
    //MARK: - Private Methods
    private func configureReveal() {
        view.addGestureRecognizer(revealViewController().panGestureRecognizer())
    }
    
    private func setValueForZabbixField(fieldName: String, cell: InputCell) {
        switch fieldName {
            case "IP-адрес сервера":
                cell.textField.text = zabbixConfig.serverAddress
                break
            case "Пользователь":
                cell.textField.text = zabbixConfig.username
                break
            case "Пароль":
                cell.textField.text = zabbixConfig.password
                break
            default:
                break
        }
    }
    
    //MARK: - Internal Handlers
    
    func checkChanges(sender: InputCell) {
        switch sender.label.text! {
            case "IP-адрес сервера":
                zabbixConfig.serverAddress = sender.textField.text
                break
            case "Пользователь":
                zabbixConfig.username = sender.textField.text
                break
            case "Пароль":
                zabbixConfig.password = sender.textField.text
                break
            default:
                break
        }
    }
    
    //MARK: - UITableViewDelegate
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return ZabbixSettings.count
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let aCell = tableView.dequeueReusableCellWithIdentifier("InputCell") as! InputCell
            configureCell(aCell, forIndexPath: indexPath)
            return aCell
        }
        let aCell = tableView.dequeueReusableCellWithIdentifier("toVPNCell") as! DisclosureCell
        aCell.label.text = "Настроить VPN"
        return aCell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Конфигурация подключения к Zabbix-серверу"
        }
        return "Конфигурация VPN"
    }
    
    private func configureCell(cell: InputCell, forIndexPath indexPath: NSIndexPath) {
        let secureFields: Set<String> = ["Пароль"]
        let setting = ZabbixSettings[indexPath.row]
        setValueForZabbixField(setting, cell: cell)
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
        if indexPath.section == 0 {
            let aCell = tableView.cellForRowAtIndexPath(indexPath)
            (aCell as! InputCell).textField.becomeFirstResponder()
        }
        else {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
}
