//
//  HomeCell.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 12/31/17.
//  Copyright © 2017 Sakar Pokhrel. All rights reserved.
//

import UIKit

class HomeCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func customizeCell(groceryDate: String, totalPrice: String) {
        
        self.dateLabel.text = groceryDate
        self.totalPriceLabel.text = totalPrice
    }

   

}
