//
//  ShareViewController.swift
//  ReedSharing
//
//  Created by Jack Flintermann on 12/25/15.
//  Copyright © 2015 jflinter. All rights reserved.
//

import UIKit
import Social
import ReedCore

class ShareViewController: SLComposeServiceViewController {

    override func didSelectPost() {
        guard let inputItem = self.extensionContext?.inputItems.first as? NSExtensionItem,
            provider = inputItem.attachments?.first as? NSItemProvider else { return }
        provider.loadItemForTypeIdentifier("public.url", options: nil) { decoder, error in
            if let url = decoder as? NSURL {
                let story = Story(title: self.contentText, url: url)
                self.extensionContext!.completeRequestReturningItems([], completionHandler: { success in
                    FirebaseStore.addStoryForUser(self.selectedUser, story: story)
                })
            }
        }
    }

    var selectedUser = User.nonActiveUser
    override func configurationItems() -> [AnyObject]! {
        let item = SLComposeSheetConfigurationItem()
        item.title = "Send this link to:"
        item.value = selectedUser.rawValue.capitalizedString
        let userSelectionVC = UserSelectionTableViewController()
        userSelectionVC.onSelect = { user in
            self.selectedUser = user
            self.reloadConfigurationItems()
            self.popConfigurationViewController()
        }
        item.tapHandler = {
            self.pushConfigurationViewController(userSelectionVC)
        }
        return [item]
    }

}
