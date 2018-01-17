//
//  AddUserCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/12/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

protocol AddUserDelegate {
    func addUsers(withEmail: String)
}

class AddUserCell: UITableViewCell {

    @IBOutlet weak var profileImage: customUIImageView!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    var delegate: AddUserDelegate?
    private var email: String!
    
    func configureCell(profileImage: String, userEmail: String) {
        
        self.profileImage.image = UIImage(named: profileImage)
        self.userEmail.text = userEmail
        self.email = userEmail
        
    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        
        delegate?.addUsers(withEmail: email)
        
    }
    
}
