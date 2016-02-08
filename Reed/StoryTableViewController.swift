//
//  StoryTableViewController.swift
//  Reed
//
//  Created by Jack Flintermann on 12/24/15.
//  Copyright © 2015 jflinter. All rights reserved.
//

import UIKit
import Dwifft
import SafariServices
import ReedCore

class StoryTableViewController: UITableViewController {
    
    var user: User {
        if self.title?.lowercaseString == "avery" {
            return .Avery
        }
        return .Jack
    }
    
    var diffCalculator: TableViewDiffCalculator<Story>!
    var archiveDiffCalculator: TableViewDiffCalculator<Story>!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.diffCalculator = TableViewDiffCalculator<Story>(tableView: self.tableView)
        self.diffCalculator.insertionAnimation = .Fade
        self.diffCalculator.deletionAnimation = .Fade
        self.archiveDiffCalculator = TableViewDiffCalculator<Story>(tableView: self.tableView)
        self.archiveDiffCalculator.insertionAnimation = .Fade
        self.archiveDiffCalculator.deletionAnimation = .Fade
        self.archiveDiffCalculator.sectionIndex = 1
        FirebaseStore.observeStoriesForUser(self.user) {
            self.diffCalculator.rows = $0.filter({ $0.archivedAt == nil })
            self.archiveDiffCalculator.rows = $0.filter({ $0.archivedAt != nil })
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.diffCalculator.rows.count
        }
        return self.archiveDiffCalculator.rows.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Stories" : "Archive"
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("storyCell", forIndexPath: indexPath)
        if indexPath.section == 0 {
            let story = self.diffCalculator.rows[indexPath.row]
            cell.textLabel?.text = story.title
            cell.detailTextLabel?.text = story.url.absoluteString
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        } else {
            let story = self.archiveDiffCalculator.rows[indexPath.row]
            cell.textLabel?.text = story.title
            cell.detailTextLabel?.text = story.url.absoluteString
            cell.textLabel?.textColor = UIColor.grayColor()
            cell.detailTextLabel?.textColor = UIColor.grayColor()
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let diff = indexPath.section == 0 ? self.diffCalculator : self.archiveDiffCalculator
        let story = diff.rows[indexPath.row]
        let safariVC = SFSafariViewController(URL: story.url, entersReaderIfAvailable: true)
        self.presentViewController(safariVC, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        if indexPath.section == 1 {
            return []
        }
        return [UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Archive", handler: { (rowAction, indexPath) -> Void in
            let story = self.diffCalculator.rows[indexPath.row]
            FirebaseStore.archiveStoryForUser(self.user, story: story)
        })]
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }

}
