//
//  EmailLoginVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class EmailLoginVC: UIViewController {

    @IBOutlet weak var emailTextField: customUITextField!
    @IBOutlet weak var passwordTextField: customUITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
   private var buttonPressed: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSingleTapGesture()
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        errorLabel.text = ""
        signInButton.isEnabled = true
        super.viewWillAppear(animated)
        if buttonPressed == "email" {
            signInButton.setTitle("SIGN IN", for: .normal)
            loginLabel.text = "LOGIN"
        } else if buttonPressed == "signup" {
            signInButton.setTitle("SIGN UP", for: .normal)
            loginLabel.text = "CREATE ACCOUNT"
        }
    }
    
    //PASS THE SELECTED BUTTON TITLE FROM LOGINVC
    func checkButtonPressed(buttonTitle: String) {
        
        self.buttonPressed = buttonTitle
    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        signInButton.isEnabled = false
        if buttonPressed == "email" {
            if emailTextField.text != nil && passwordTextField.text != nil {
                AuthService.instance.loginUser(withEmail: emailTextField.text!, andPassword: passwordTextField.text!, loginCompletion: { (successful, loginError) in
                    if successful {
                        self.performSegue(withIdentifier: "unwindToMoreVC", sender: nil)
                    } else {
                        print("Login Error: \(String(describing: loginError!.localizedDescription))")
                        if loginError!.localizedDescription == "The password is invalid or the user does not have a password."{
                            self.errorLabel.text = "Incorrect Password"
                        } else if loginError!.localizedDescription == "There is no user record corresponding to this identifier. The user may have been deleted."{
                            self.errorLabel.text = "Incorrect Username"
                        }
                        self.signInButton.isEnabled = true
                    }
                })
            }
        }
        else if buttonPressed == "signup" {
           
            if emailTextField.text != nil && passwordTextField.text != nil {
                AuthService.instance.registerUser(withEmail: emailTextField.text!, andPassword: passwordTextField.text!, userCreationComplete: { (registrationSuccess, registrationError) in
                    if registrationSuccess {
                        AuthService.instance.loginUser(withEmail: self.emailTextField.text!, andPassword: self.passwordTextField.text!, loginCompletion: { (loginSuccess, loginError) in
                            if loginSuccess {
                                self.performSegue(withIdentifier: "unwindToMoreVC", sender: nil)
                            } else {
                                print("Login Error: \(String(describing: loginError?.localizedDescription))")
                            }
                        })
                    } else {
                        print("Login Error: \(String(describing: registrationError?.localizedDescription))")
                        self.signInButton.isEnabled = true
                    }
                })
        }
        }
        
        
    }
    
    //ADD TAP GESTURE (SINGLE TAP)
    private func addSingleTapGesture() {
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapped))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
        
    }
    
    //USER TAPPED ON A SCREEN:
    @objc func singleTapped() {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    //BACK BUTTON PRESSED:
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        dismissViewController()
    }
    

}

extension EmailLoginVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.errorLabel.text = ""
    }
    
}














