//
//  Users.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/20/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation

class Users {
    
    private var _email: String
    private var _profileImageURL: String?
    
    var email: String {
        return _email
    }
    
    var profileImageURL: String? {
        return _profileImageURL
    }
    
    init(email: String,  profileImageURL: String?) {
        self._email = email
        self._profileImageURL =  profileImageURL
    }
}
