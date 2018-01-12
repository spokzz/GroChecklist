//
//  SearchUserCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/2/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    @IBOutlet weak var userImageView: customUIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var checkedImageView: UIImageView!
    
    func configureCell(userImage: String, userEmail: String, imageShow: Bool) {
        
        self.userImageView.image = UIImage(named: userImage)
        self.userEmailLabel.text = userEmail
        
        if imageShow {
            self.checkedImageView.isHidden = false
        } else {
            self.checkedImageView.isHidden = true
        }
    }
    
    //CELL IS SELECTED:
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected && self.checkedImageView.isHidden == false {
          self.checkedImageView.isHidden = true
        } else if selected && self.checkedImageView.isHidden == true {
            self.checkedImageView.isHidden = false
        }
        
    }

}
