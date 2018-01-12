//
//  AddItemCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/1/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class AddItemCell: UITableViewCell {

    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var numberOfItems: UILabel!
    
    func configureCell(itemTitle: String, numberOfItems: String) {
        
        self.itemTitle.text = itemTitle
        self.numberOfItems.text = numberOfItems
    }

}
