//
//  ResetPasswordVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 2/21/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ResetPasswordVC: UIViewController {

    @IBOutlet weak var emailTextField: customUITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        errorLabel.text = ""
    }

    @IBAction func resetButtonPressed(_ sender: customUIButton) {
        
        if emailTextField.text != "" {
            
            AuthService.instance.resetPassword(forEmail: emailTextField.text!, completion: { (success, error) in
                if success {
                    
                    self.errorLabel.text = "Reset link sent in your email."
                    
                } else {
                    print("\(String(describing: error?.localizedDescription))")
                    self.errorLabel.text = "Invalid Username"
                }
            })
            
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
