//
//  UserSelectionTableViewController.swift
//  Reed
//
//  Created by Jack Flintermann on 12/25/15.
//  Copyright © 2015 jflinter. All rights reserved.
//

import UIKit
import ReedCore

class UserSelectionTableViewController: UITableViewController {
    
    var onSelect: (User -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clearColor()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "userCell")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return User.allUsers.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath)
        cell.backgroundColor = UIColor.clearColor()
        cell.textLabel?.text = User.allUsers[indexPath.row].rawValue.capitalizedString
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let user = User.allUsers[indexPath.row]
        self.onSelect?(user)
    }
    
}
