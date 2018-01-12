//
//  Groups.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/8/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation

class Groups {
    
    private var _groupCreatedDate: String
    private var _key: String
    private var _members: [String]
    private var _totalAmount: String
    
    var groupCreatedDate: String {
        return _groupCreatedDate
    }
    
    var key: String {
        return _key
    }
    
    var members: [String]{
        return _members
    }
    
    var totalAmount: String {
        return _totalAmount
    }
    
    
    init(groupCreatedDate: String, key: String, members: [String], totalAmount: String) {
        self._groupCreatedDate = groupCreatedDate
        self._key = key
        self._members = members
        self._totalAmount = totalAmount
    }
    
    
}
