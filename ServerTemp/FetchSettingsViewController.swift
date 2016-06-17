//
//  FetchSettingsViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 17.06.16.
//  Copyright © 2016 Nikita Karaulov. All rights reserved.
//

import UIKit

class FetchSettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = ""
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }
        return 1
    }

}
