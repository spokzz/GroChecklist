//
//  AddUsersVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/12/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase

class AddUsersVC: UIViewController {

    @IBOutlet weak var searchTextField: customSearchTextField!
    @IBOutlet weak var addUserTableView: UITableView!
    
    private var emailArray = [String]()
    private var members = ""
    private var status = Int()
    
    private var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addUserTableView.delegate = self
        addUserTableView.dataSource = self
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addSingleTapGesture()
        addSpinner()
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser?.email != nil {
            self.emailArray = []
            self.members = ""
            self.status = Int()
            addUserTableView.isHidden = false
            searchTextField.isEnabled = true
        DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!) { (returnedFriendList) in
            if returnedFriendList.isEmpty == false {
                DataService.instance.getEmail(forUID: returnedFriendList[0].addedFriendUID, completion: { (returnedEmail) in
                    self.members = returnedEmail
                    self.status = returnedFriendList[0].status
                })
            }
        }
            
        } else {
            addUserTableView.isHidden = true
            searchTextField.isEnabled = false
        }
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.spinner.removeFromSuperview()
    }
    
    //WHEN USER START TYPING:
    @objc func textFieldDidChange() {
        spinner.startAnimating()
        
        if searchTextField.text == "" {
            emailArray = []
            addUserTableView.reloadData()
            self.spinner.stopAnimating()
        } else {
            DataService.instance.getEmail(forSearchQuery: searchTextField.text!, completion: { (returnedEmail) in
                self.spinner.removeFromSuperview()
                self.emailArray = returnedEmail
                self.addUserTableView.reloadData()
                
            })
        }
        
    }
    
    

    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    //ADDS TAP GESTURE (SINGLE TAP)
    private func addSingleTapGesture() {
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tappedOnScreen))
        singleTap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(singleTap)
    }
    
    //USER TAPPED ON SCREEN:
    @objc func tappedOnScreen() {
        searchTextField.endEditing(true)
    }
    
    //ADD UIACTIVITY INDICATOR VIEW
    private func addSpinner() {
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = self.view.center
        spinner.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.view.addSubview(spinner)
    }

    
    

}

//UITEXTFIELD:
extension AddUsersVC: UITextFieldDelegate {
    
}

//TABLE VIEW:
extension AddUsersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return emailArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addUserCell", for: indexPath) as? AddUserCell else {return UITableViewCell()}
        
        //Check if the email is added or not.
            if emailArray[indexPath.row] == members {
                if status == 0 {
                    cell.configureCell(profileImage: "sakar", userEmail: emailArray[indexPath.row])
                    cell.addButton.setTitle("Pending", for: .normal)
                    cell.addButton.isHidden = true
                    cell.delegate = self
                } else if status == 1 {
                    cell.configureCell(profileImage: "sakar", userEmail: emailArray[indexPath.row])
                    cell.addButton.isHidden = true
                    cell.delegate = self
                } else if status == 2 {
                    cell.configureCell(profileImage: "sakar", userEmail: emailArray[indexPath.row])
                    cell.addButton.isHidden = true
                    cell.delegate = self
                }
            } else {
                cell.configureCell(profileImage: "sakar", userEmail: emailArray[indexPath.row])
                cell.addButton.isHidden = false
                cell.delegate = self
            }
        
        
        return cell
    }
    
  
}

//WHEN USER TAP ADD BUTTON:
extension AddUsersVC: AddUserDelegate {
    
    func addUsers(withEmail: String) {
        DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!) { (returnedFriendList) in
            
            if returnedFriendList.isEmpty {
                
                DataService.instance.getUserdIds(forEmail: [withEmail], completion: { (returnedUID) in
                    
                    DataService.instance.getFriendsList(userID: returnedUID[0], completion: { (friendListArray) in
                        
                        if friendListArray.isEmpty {
                            DataService.instance.createFriends(withUserID: (Auth.auth().currentUser?.uid)!, withFriendUID: returnedUID[0], status: 0)
                            DataService.instance.createFriends(withUserID: returnedUID[0], withFriendUID: (Auth.auth().currentUser?.uid)!, status: 1)
                            DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!) { (returnedFriendList) in
                                if returnedFriendList.isEmpty == false {
                                    DataService.instance.getEmail(forUID: returnedFriendList[0].addedFriendUID, completion: { (returnedEmail) in
                                        self.members = returnedEmail
                                        self.status = returnedFriendList[0].status
                                        self.addUserTableView.reloadData()
                                    })
                                }
                            }
                            
                        } else {
                            
                            let alertVC = UIAlertController(title: "", message: "\(withEmail) have more than one members in his account. Sorry,You can't add.", preferredStyle: .alert)
                            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertVC.addAction(alertAction)
                            
                            self.present(alertVC, animated: true, completion: nil)
                            
                        }
                    })
                    
                })
            }
            else {
                
                let alertVC = UIAlertController(title: "", message: "You can't have more than one member. Remove member from \"My Members\" if you want to add this member.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertVC.addAction(alertAction)
                
                self.present(alertVC, animated: true, completion: nil)
            }
            
        }
    }
    }













