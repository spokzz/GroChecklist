//
//  LoginVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func loginWithGooglePressed(_ sender: UIButton) {
        
        
    }
    
    @IBAction func loginWithPhonePressed(_ sender: UIButton) {
        
        
    }
    
    @IBAction func loginByEmailPressed(_ sender: UIButton) {
        
        guard let emailLoginVC = storyboard?.instantiateViewController(withIdentifier: "emailLoginVC") as? EmailLoginVC else {return }
        emailLoginVC.checkButtonPressed(buttonTitle: "email")
        presentVCFromRightSide(withViewController: emailLoginVC)
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        guard let emailLoginVC = storyboard?.instantiateViewController(withIdentifier: "emailLoginVC") as? EmailLoginVC else {return }
        emailLoginVC.checkButtonPressed(buttonTitle: "signup")
        presentVCFromRightSide(withViewController: emailLoginVC)
        
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
