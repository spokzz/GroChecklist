//
//  LoginVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    let application = UIApplication.shared
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        topViewHeight.editLoginVCColorGradientHeight()
        
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        application.statusBarStyle = .lightContent
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        application.statusBarStyle = .default
    }

    @IBAction func loginWithGooglePressed(_ sender: UIButton) {
        
        
    }
    
    @IBAction func loginWithPhonePressed(_ sender: UIButton) {
        
        
    }
    
    @IBAction func loginByEmailPressed(_ sender: UIButton) {
        
        guard let emailLoginVC = storyboard?.instantiateViewController(withIdentifier: "emailLoginVC") as? EmailLoginVC else {return }
        emailLoginVC.checkButtonPressed(buttonTitle: "email")
        present(emailLoginVC, animated: true, completion: nil)
        
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        guard let emailLoginVC = storyboard?.instantiateViewController(withIdentifier: "emailLoginVC") as? EmailLoginVC else {return }
        emailLoginVC.checkButtonPressed(buttonTitle: "signup")
        present(emailLoginVC, animated: true, completion: nil)
        
    }
    
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}
