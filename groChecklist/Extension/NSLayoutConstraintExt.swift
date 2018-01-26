//
//  NSLayoutConstraintExt.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/22/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    //CHNAGE TOP VIEW HEIGHT BASED ON DEVICE MODEL:
    func editTopViewHeight() {
        
            switch deviceType! {
            case "iphone 8", "iphone 8 Plus":
                self.constant = 70
            case "iphone X":
                self.constant = 90
            default:
                self.constant = 70
                return
            }
        }
    
    //CHANGE THE COLOR GRADIENT HEIGHT OF MOREVC
    func editMoreVCColorGradientHeight() {
        
        switch deviceType! {
        case "iphone 8", "iphone 8 Plus":
            self.constant = 125
        case "iphone X":
            self.constant = 145
        default:
            self.constant = 125
            return
        }
        
        
    }
    
    //CHANGE THE COLOR GRADIENT HEIGHT OF LOGIN VC
    func editLoginVCColorGradientHeight() {
        
        switch deviceType! {
        case "iphone 8", "iphone 8 Plus":
            self.constant = 250
        case "iphone X":
            self.constant = 270
        default:
            self.constant = 250
            return
        }
    }
    
    func changeEmailLoginColorGradientHeight() {
        
        switch deviceType! {
        case "iphone 8", "iphone 8 Plus":
            self.constant = 230
        case "iphone X":
            self.constant = 250
        default:
            self.constant = 230
            return
        }
        
        
        
    }
    
    
}












