//
//  User.swift
//  Reed
//
//  Created by Jack Flintermann on 12/24/15.
//  Copyright © 2015 jflinter. All rights reserved.
//

import Foundation

public enum User: String {
    case Jack = "jack"
    case Avery = "avery"
    
    public static let activeUser = User.Jack
    public static let nonActiveUser = User.Avery
    public static let allUsers = [User.Avery, User.Jack]
}
