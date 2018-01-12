//
//  ViewGroupItemsCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/9/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class ViewGroupItemsCell: UITableViewCell {

    @IBOutlet weak var numberOfItems: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var checkedImageView: UIImageView!
    
    func configureCell(groupItems: GroceryItem) {
        
        self.numberOfItems.text = groupItems.numberOfItems
        self.itemTitle.text = groupItems.itemTitle
        
        if groupItems.checked {
            self.checkedImageView.isHidden = false
        }
        
    }

}
