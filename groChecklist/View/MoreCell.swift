//
//  MoreCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/10/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class MoreCell: UITableViewCell {

    @IBOutlet weak var settingsTitle: UILabel!
    @IBOutlet weak var rightArrowImageView: UIImageView!
    
    func configureCell(withTitle title: String) {
        
        self.settingsTitle.text = title
    }

}
