//
//  Story.swift
//  Reed
//
//  Created by Jack Flintermann on 12/24/15.
//  Copyright © 2015 jflinter. All rights reserved.
//

import Foundation

public struct Story: Equatable {
    public let title: String
    public let url: NSURL
    public let createdAt: NSDate
    public var archivedAt: NSDate?
    public var readAt: NSDate?
    public var notifiedAt: NSDate?
    public let firebaseID: String?
    public init(title: String, url: NSURL) {
        self.title = title
        self.url = url
        self.createdAt = NSDate()
        self.archivedAt = nil
        self.readAt = nil
        self.notifiedAt = nil
        self.firebaseID = nil
    }
}

public func ==(lhs: Story, rhs: Story) -> Bool {
    return lhs.url.absoluteString == rhs.url.absoluteString
}
