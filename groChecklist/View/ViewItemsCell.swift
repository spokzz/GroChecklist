//
//  ViewItemsCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/5/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class ViewItemsCell: UITableViewCell {

    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemSelectedImage: UIImageView!
    
    func confugureCell(items: Items) {
        
        self.numberOfItemsLabel.text = "\(items.itemQuantity)"
        self.itemTitle.text = items.itemTitle
        
        if items.checked {
            self.itemSelectedImage.isHidden = false
        }
        
    }
    

}
