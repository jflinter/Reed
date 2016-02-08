//
//  FirebaseStore.swift
//  Reed
//
//  Created by Jack Flintermann on 12/24/15.
//  Copyright © 2015 jflinter. All rights reserved.
//

import Foundation
import Firebase

extension Dictionary {
    func decodeString(key: Key) -> String? {
        return self[key] as? String
    }
    
    func decodeURL(key: Key) -> NSURL? {
        guard let string = self.decodeString(key) else { return nil }
        let components = NSURLComponents(string: string)
        if components?.scheme == nil {
            components?.scheme = "http"
        }
        return components?.URL
    }
    
    func decodeDate(key: Key) -> NSDate? {
        guard let number = self[key] as? NSNumber else { return nil }
        return NSDate(timeIntervalSince1970: number.doubleValue)
    }
}

extension NSDate {
    var asNSNumber: NSNumber {
        return NSNumber(double: self.timeIntervalSince1970)
    }
}

public extension Story {
    public init?(_ firebaseDict: [String: AnyObject]) {
        guard let title = firebaseDict.decodeString("title"),
            url = firebaseDict.decodeURL("url"),
            createdAt = firebaseDict.decodeDate("createdAt") else {
                return nil
        }
        self.title = title
        self.url = url
        self.createdAt = createdAt
        self.readAt = firebaseDict.decodeDate("readAt")
        self.archivedAt = firebaseDict.decodeDate("archivedAt")
        self.notifiedAt = firebaseDict.decodeDate("notifiedAt")
        self.firebaseID = firebaseDict.decodeString("firebaseID")
    }
    var asFirebaseObject: [String: AnyObject] {
        var object: [String: AnyObject?] = [
            "title": self.title,
            "url": self.url.absoluteString,
            "createdAt": self.createdAt.asNSNumber,
            "readAt": self.readAt?.asNSNumber,
            "archivedAt": self.archivedAt?.asNSNumber,
            "notifiedAt": self.notifiedAt?.asNSNumber
        ]
        let keysToRemove = object.keys.filter { object[$0]! == nil }
        for key in keysToRemove {
            object.removeValueForKey(key)
        }
        return object as! [String: AnyObject]
    }
}

public class FirebaseStore {
    
    static let root: Firebase = {
        Firebase.defaultConfig().persistenceEnabled = true
        return Firebase(url:"https://letsreedsomestuff.firebaseio.com")
    }()

    public static func addStoryForUser(user: User, story: Story, completion: (NSError? -> Void) = { _ in }) -> Void {
        root.childByAppendingPath(user.rawValue).childByAutoId().setValue(story.asFirebaseObject) { error, _ in
            completion(error)
        }
    }
    
    public static func observeStoriesForUser(user: User, callback: [Story] -> Void) -> Void {
        root.childByAppendingPath(user.rawValue).observeEventType(.Value, withBlock: { snapshot in
            if let value = snapshot.value as? [String: [String: AnyObject]] {
                let values = value.map({ (k: String, var v: [String : AnyObject]) -> Story? in
                    v["firebaseID"] = k
                    return Story(v)
                }).flatMap({ $0 }).sort({ $0.0.createdAt.timeIntervalSince1970 > $0.1.createdAt.timeIntervalSince1970 })
                callback(values)
            }
        })
    }
    
    public static func archiveStoryForUser(user: User, var story: Story) {
        story.archivedAt = NSDate()
        root.childByAppendingPath(user.rawValue).childByAppendingPath(story.firebaseID!).setValue(story.asFirebaseObject)
    }
    
    public static func markStoryNotifiedForUser(user: User, var story: Story) {
        story.notifiedAt = NSDate()
        root.childByAppendingPath(user.rawValue).childByAppendingPath(story.firebaseID!).setValue(story.asFirebaseObject)
    }
    
    public static func fetchNewStoriesForUser(user: User, completion: [Story] -> Void) {
        root.childByAppendingPath(user.rawValue).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let value = snapshot.value as? [String: [String: AnyObject]] {
                let stories = value.map({ (k: String, var v: [String : AnyObject]) -> Story? in
                    v["firebaseID"] = k
                    return Story(v)
                }).flatMap({ $0 }).filter({ story in
                    return story.notifiedAt == nil && story.archivedAt == nil
                })
                for story in stories {
                    markStoryNotifiedForUser(user, story: story)
                }
                completion(stories)
            } else {
                completion([])
            }
        })
    }
    
}
