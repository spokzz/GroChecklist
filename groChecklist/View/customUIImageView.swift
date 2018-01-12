//
//  customUIImageView.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/2/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

@IBDesignable

class customUIImageView: UIImageView {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = true
        }
    }
    
    
    

}
