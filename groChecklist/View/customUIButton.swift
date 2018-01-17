//
//  customUIButton.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/15/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

@IBDesignable

class customUIButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet{
            self.layer.cornerRadius = cornerRadius
        }
    }

}
