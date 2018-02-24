//
//  AuthService.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation
import Firebase

class AuthService {
    
    static let instance = AuthService()
    
    //Create User in Firebase:
    func registerUser(withEmail email: String, andPassword password: String, userCreationComplete: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            guard let user = user else {
                userCreationComplete(false, error)
                return
            }
            let userData = ["provider": user.providerID, "email": user.email]
            DataService.instance.createDBUser(uid: user.uid, userData: userData as Any as! Dictionary<String, Any>)
            userCreationComplete(true, nil)
        }
        
    }
    
    //Login User in Firebase:
    func loginUser(withEmail email: String, andPassword password: String, loginCompletion: @escaping (_ status:Bool, _ error: Error?) -> ()) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                loginCompletion(true, nil)
            } else {
                loginCompletion(false, error)
            }
        }
        
    }
    
    //SIGN OUT FROM FIREBASE:
    func signOut(completion: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        
        do {
            try Auth.auth().signOut()
            completion(true, nil)
        } catch {
            completion(false,error)
        }
    }
    
    //RESET PASSWORD:
    func resetPassword(forEmail email: String, completion: @escaping (_ status: Bool, _ error: Error?) -> ()) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (resetError) in
            if resetError != nil {
                completion(false, resetError)
            } else {
                completion(true, nil)
            }
        }
        
        
    }
    
    
}













