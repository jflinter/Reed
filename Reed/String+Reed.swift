//
//  String+Reed.swift
//  Reed
//
//  Created by Jack Flintermann on 12/24/15.
//  Copyright © 2015 jflinter. All rights reserved.
//

import UIKit

public extension String {
    public var isValidURL: Bool {
        if let _ = self.URL?.scheme {
            return true
        }
        return false
    }
    
    public var URL: NSURL? {
        if let urlComponents = NSURLComponents(string: self) {
            if urlComponents.scheme == nil {
                urlComponents.scheme = "http"
            }
            return urlComponents.URL
        }
        return nil
    }
}
