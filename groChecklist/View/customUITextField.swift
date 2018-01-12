//
//  customUITextField.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/1/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

@IBDesignable

class customUITextField: UITextField {

    override func awakeFromNib() {
        super.awakeFromNib()
        if let p = placeholder {
            attributedPlaceholder = NSAttributedString(string: p , attributes: [NSAttributedStringKey.foregroundColor : #colorLiteral(red: 0.3988900483, green: 0.3988900483, blue: 0.3988900483, alpha: 1)])
        }
    }
    
    var edgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, edgeInsets)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, edgeInsets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, edgeInsets)
    }

}
