//
//  customUIView.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 12/30/17.
//  Copyright © 2017 Sakar Pokhrel. All rights reserved.
//

import UIKit

@IBDesignable

class CustomUIView: UIView {
    
   @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            self.layer.shadowColor = shadowColor.cgColor
        }
    }
    
   @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            self.layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var OffSetWidth: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    @IBInspectable var OffSetHeight: CGFloat = 0 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    
    func updateView() {
        self.layer.shadowOffset = CGSize(width: OffSetWidth, height: OffSetHeight)
        
    }
    
    
    
    
    
    
    
    
}
