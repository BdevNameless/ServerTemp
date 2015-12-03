//
//  MainMenuController.swift
//  ServerTemp
//
//  Created by BdevNameless on 02.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit

class MainMenuController: UITableViewController {
    
    private let menuItems = ["Тест VPN","Настройки"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
        configureCell(cell, forIndexPath: indexPath)
        return cell
    }
    
    private func configureCell(cell: MenuCell, forIndexPath indexPath: NSIndexPath) {
        cell.menuLabel.text = menuItems[indexPath.row]
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch menuItems[indexPath.row] {
            case "Тест VPN":
                self.performSegueWithIdentifier("pushVPNTest", sender: self)
                break
            case "Настройки":
                self.performSegueWithIdentifier("pushSettings", sender: self)
                break
            default:
                break
        }
    }
    
}
