//
//  EmailLoginVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class EmailLoginVC: UIViewController {

    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: customUITextField!
    @IBOutlet weak var passwordTextField: customUITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var buttonPressed: String!
    let application = UIApplication.shared
    private var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topViewHeight.changeEmailLoginColorGradientHeight()
        addSingleTapGesture()
        emailTextField.becomeFirstResponder()
        
        addSpinner()
        
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        application.statusBarStyle = .lightContent
        errorLabel.text = ""
        signInButton.isEnabled = true
        updateViewForButtonPressed()
        
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        application.statusBarStyle = .default
    }
    
    //UPDATE THE VIEW BASED ON BUTTON PRESSED:
    func updateViewForButtonPressed() {
        
        if buttonPressed == "email" {
            signInButton.setTitle("Sign In", for: .normal)
            loginLabel.text = "Sign In"
        } else if buttonPressed == "signup" {
            signInButton.setTitle("Sign Up", for: .normal)
            loginLabel.text = "CREATE ACCOUNT"
        }
    }
    
    //PASS THE SELECTED BUTTON TITLE FROM LOGINVC
    func checkButtonPressed(buttonTitle: String) {
        
        self.buttonPressed = buttonTitle
    }

    @IBAction func signInButtonPressed(_ sender: UIButton) {
        
        spinner.startAnimating()
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
            self.spinner.removeFromSuperview()
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
        
        self.spinner.removeFromSuperview()
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
    
    //ADD UIACTIVITY INDICATOR VIEW
    private func addSpinner() {
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = self.view.center
        spinner.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.view.addSubview(spinner)
    }

    
    //BACK BUTTON PRESSED:
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    

}

extension EmailLoginVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.errorLabel.text = ""
    }
    
}














