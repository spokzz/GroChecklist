//
//  FriendsList.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/12/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation

class FriendList {
    
    private var _addedFriendUID: String
    private var _status: Int
    private var _key: String
    private var _email: String?
    
    var addedFriendUID: String {
        return _addedFriendUID
    }
    
    var status: Int {
        return _status
    }
    
    var key: String {
        return _key
    }
    
    var email: String? {
        return _email
    }
    
    
    init(addedFriendUID: String, status: Int, key: String, friendEmail email: String?) {
        self._addedFriendUID = addedFriendUID
        self._status = status
        self._key = key
        self._email = email
    }
    
    
    
}