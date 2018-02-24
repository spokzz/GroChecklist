//
//  EmailLoginVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase

class EmailLoginVC: UIViewController {

    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    @IBOutlet weak var emailTextField: customUITextField!
    @IBOutlet weak var passwordTextField: customUITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var forgetPasswordButton: UIButton!
    
    private var buttonPressed: String!
    let application = UIApplication.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topViewHeight.changeEmailLoginColorGradientHeight()
        addSingleTapGesture()
        emailTextField.becomeFirstResponder()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        application.statusBarStyle = .lightContent
        errorLabel.text = ""
        signInButton.isEnabled = true
        forgetPasswordButton.isHidden = true
        updateViewForButtonPressed()
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        application.statusBarStyle = .default
    }
    
    //PASS THE SELECTED BUTTON TITLE FROM LOGINVC
    func checkButtonPressed(buttonTitle: String) {
        
        self.buttonPressed = buttonTitle
    }

    //SIGN IN BUTTON PRESSED:
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        if emailTextField.text != "" || passwordTextField.text != "" {
            signInButton.isEnabled = false
            checkButtonPressed()
        }
        
    }
    
    //BACK BUTTON PRESSED:
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    

}

//UITEXTFIELD DELEGATE:
extension EmailLoginVC: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.errorLabel.text = ""
    }
    
}

//CUSTOM FUNCTIONS:
extension EmailLoginVC {
    
    //UPDATE THE VIEW BASED ON BUTTON PRESSED:
    private func updateViewForButtonPressed() {
        
        if buttonPressed == "email" {
            signInButton.setTitle("Sign In", for: .normal)
            loginLabel.text = "Sign In"
        } else if buttonPressed == "signup" {
            signInButton.setTitle("Sign Up", for: .normal)
            loginLabel.text = "CREATE ACCOUNT"
        }
    }
    
    //CHECKS IF BUTTON PRESSED IS "EMAIL" OR "SIGNUP" AND UPDATES THE VIEW
    private func checkButtonPressed() {
        self.errorLabel.text = "Connecting..."
        if buttonPressed == "email" {
            if emailTextField.text != nil && passwordTextField.text != nil {
                viewForEmail(withEmail: emailTextField.text!, password: passwordTextField.text!)
            }
        }
        else if buttonPressed == "signup" {
            
            if emailTextField.text != nil && passwordTextField.text != nil && (emailTextField.text?.contains(".com"))! {
                viewForSignUp(withEmail: emailTextField.text!, password: passwordTextField.text!)
            } else {
                self.signInButton.isEnabled = true
            }
        }
    }
    
    //UPDATES THE VIEW IF EMAIL WAS SELECTED
    private func viewForEmail(withEmail email: String, password: String) {
        
        AuthService.instance.loginUser(withEmail: email, andPassword: password, loginCompletion: {[unowned self] (successful, loginError) in
            if successful {
                self.performSegue(withIdentifier: "unwindToMoreVC", sender: nil)
            } else {
                print("Login Error: \(String(describing: loginError!.localizedDescription))")
                if let signInError = loginError as NSError? {
                    self.handleSignIn(error: signInError)
                }
                self.signInButton.isEnabled = true
                self.forgetPasswordButton.isHidden = false
            }
        })
        
    }
    
    //UPDATES THE VIEW IF SIGN UP WAS SELECTED
    private func viewForSignUp(withEmail email: String, password: String) {
        
        AuthService.instance.registerUser(withEmail: email, andPassword: password, userCreationComplete: { (registrationSuccess, registrationError) in
            if registrationSuccess {
                AuthService.instance.loginUser(withEmail: self.emailTextField.text!, andPassword: self.passwordTextField.text!, loginCompletion: { [unowned self] (loginSuccess, loginError) in
                    if loginSuccess {
                        self.performSegue(withIdentifier: "unwindToMoreVC", sender: nil)
                    } else {
                        self.errorLabel.text = "No Internet Connection"
                    }
                })
            } else {
                guard let regError = registrationError as NSError? else {return}
                self.handleSignUp(error: regError)
                self.signInButton.isEnabled = true
            }
        })
    }
    
    //HANDLES SIGN IN ERROR FROM FIREBASE
    private func handleSignIn(error: NSError) {
        
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            
            switch errorCode {
            case .invalidEmail:
                errorLabel.text = "Invalid Email"
            case .userDisabled:
                errorLabel.text = "Your account is disabled"
            case .wrongPassword:
                errorLabel.text = "Wrong Password"
            default:
                errorLabel.text = "Invalid Email"
            }
            
        }
    }
    
    //HANDLES SIGNUP ERROR FROM FIREBASE:
    private func handleSignUp(error: NSError) {
        
        if let errorCode = AuthErrorCode(rawValue: error.code) {
            
            switch errorCode {
                
            case .invalidEmail:
                errorLabel.text = "Invalid Email"
            case .emailAlreadyInUse:
                errorLabel.text = "Email already in use"
            case .weakPassword:
                errorLabel.text = "Password too weak"
            default:
                errorLabel.text = "Invalid Email"
                
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
    @objc private func singleTapped() {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
    }
    
    
}














