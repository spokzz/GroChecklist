//
//  LoginVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class LoginVC: UIViewController {

    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    let application = UIApplication.shared
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topViewHeight.editLoginVCColorGradientHeight()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
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

    //LOGIN WITH GOOGLE BUTTON PRESSED:
    @IBAction func loginWithGooglePressed(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().signIn()
    }
    
    //LOGIN BY EMAIL BUTTON PRESSED:
    @IBAction func loginByEmailPressed(_ sender: UIButton) {
        
        guard let emailLoginVC = storyboard?.instantiateViewController(withIdentifier: "emailLoginVC") as? EmailLoginVC else {return }
        emailLoginVC.checkButtonPressed(buttonTitle: "email")
        present(emailLoginVC, animated: true, completion: nil)
        
    }
    
    //SIGN UP BUTTON PRESSED:
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        guard let emailLoginVC = storyboard?.instantiateViewController(withIdentifier: "emailLoginVC") as? EmailLoginVC else {return }
        emailLoginVC.checkButtonPressed(buttonTitle: "signup")
        present(emailLoginVC, animated: true, completion: nil)
        
    }
    
    //CLOSE BUTTON PRESSED:
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
}

//GOOGLE SIGN IN DELEGATE:
extension LoginVC: GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            print("ERROR IN GOOGLE SIGN IN", error)
            return
        }
        
        guard let authenication = user.authentication else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: authenication.idToken, accessToken: authenication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print("Error in google sign in: ", error)
                return
            }
            
            if let user = user {
                let userData = ["provider": user.providerID, "email": user.email!]
                DataService.instance.createDBUser(uid: user.uid, userData: userData)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }

    
}

















