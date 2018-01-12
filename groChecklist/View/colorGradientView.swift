//
//  colorGradientView.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/4/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

@IBDesignable

class colorGradientView: UIView {

    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    func updateView() {
        let gradientLayer = self.layer as! CAGradientLayer
        gradientLayer.colors = [firstColor.cgColor, secondColor.cgColor]
        gradientLayer.masksToBounds = true
    }
    

}
