//
//  GroupsCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/2/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class GroupsCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var userImage1: customUIImageView!
    @IBOutlet weak var userImage2: customUIImageView!
    @IBOutlet weak var userImage3: customUIImageView!
    
    func configureCell(date: String, totalPrice: String, userImage1: String, userImage2: String, userImage3: String) {
        
        self.dateLabel.text = date
        self.totalLabel.text = "Total Price: $\(totalPrice)"
        self.userImage1.image = UIImage(named: userImage1)
        self.userImage2.image = UIImage(named: userImage2)
        self.userImage3.image = UIImage(named: userImage3)
        
    }

}
