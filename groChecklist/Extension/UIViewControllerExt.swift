//
//  UIViewControllerExt.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/16/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

extension UIViewController {
    
    //RIGHT TRANSITION:
    func presentVCFromRightSide(withViewController viewController: UIViewController) {
        
        let tranisition = CATransition()
        tranisition.type = kCATransitionMoveIn
        tranisition.subtype = kCATransitionFromRight
        tranisition.duration = 0.5
        
        self.view.window?.layer.add(tranisition, forKey: kCATransition)
        self.present(viewController, animated: false, completion: nil)
    }
    
    //LEFT TRANSITION:
    func dismissViewController() {
        
        let transition = CATransition()
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromLeft
        transition.duration = 0.5
        
        self.view.window?.layer.add(transition, forKey: kCATransition)
        self.dismiss(animated: false, completion: nil)
        
        
        
    }
    
    
}
