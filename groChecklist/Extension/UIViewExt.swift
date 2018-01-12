//
//  UIViewExt.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 12/31/17.
//  Copyright © 2017 Sakar Pokhrel. All rights reserved.
//

import UIKit

extension UIView {
    
    func bindToKeyboard() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameChanged(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    
    @objc func keyboardFrameChanged(_ notification: NSNotification) {
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let beginingFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endingFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endingFrame.origin.y - beginingFrame.origin.y
        
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions.init(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
        
    }

    
    
    
}















