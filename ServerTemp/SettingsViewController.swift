//
//  SettingsViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 01.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController, InputCellDelegate {
    
    //MARK: - Private Instance Variables
    private let ZabbixSettings = ["IP-адрес сервера","Пользователь", "Пароль", "Датчики", "Дополнительные настройки"]
    private let vpnConfig = VPNConfiguration(true)
//    private let zabbixConfig = ZabbixConfiguration()
    
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
                cell.textField.text = ZabbixConfiguration.serverAddress
                break
            case "Пользователь":
                cell.textField.text = ZabbixConfiguration.username
                break
            case "Пароль":
                cell.textField.text = ZabbixConfiguration.password
                break
            default:
                break
        }
    }
    
    //MARK: - Internal Handlers
    
    func checkChanges(sender: InputCell) {
        switch sender.label.text! {
            case "IP-адрес сервера":
                ZabbixConfiguration.serverAddress = sender.textField.text
                break
            case "Пользователь":
                ZabbixConfiguration.username = sender.textField.text
                break
            case "Пароль":
                ZabbixConfiguration.password = sender.textField.text
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
            var aCell: UITableViewCell? = nil
            switch indexPath.row {
            case 0...2:
                aCell = tableView.dequeueReusableCellWithIdentifier("InputCell") as! InputCell
                configureCell(aCell as! InputCell, forIndexPath: indexPath)
                break
            case 3:
                aCell = tableView.dequeueReusableCellWithIdentifier("disclosureCell") as! DisclosureCell
                (aCell as! DisclosureCell).label.text = "Датчики"
                break
            case 4:
                aCell = tableView.dequeueReusableCellWithIdentifier("disclosureCell") as! DisclosureCell
                (aCell as! DisclosureCell).label.text = "Дополнительные настройки"
                break
            default:
                break
            }
            return aCell!
        }
        let aCell = tableView.dequeueReusableCellWithIdentifier("disclosureCell") as! DisclosureCell
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
            switch indexPath.row {
            case 0...2:
                let aCell = tableView.cellForRowAtIndexPath(indexPath)
                (aCell as! InputCell).textField.becomeFirstResponder()
                break
            case 3:
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
//                self.performSegueWithIdentifier("toVPNSegue", sender: self)
                break
            case 4:
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
//                self.performSegueWithIdentifier("toVPNSegue", sender: self)
                break
            default:
                break
            }
        }
        else if indexPath.section == 1 {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.performSegueWithIdentifier("toVPNSegue", sender: self)
        }
    }
}
