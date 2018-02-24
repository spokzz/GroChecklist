//
//  AddUsersVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/12/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireImage

class AddUsersVC: UIViewController {

    @IBOutlet weak var searchTextField: customSearchTextField!
    @IBOutlet weak var addUserTableView: UITableView!
    @IBOutlet weak var loginInfoLabel: UILabel!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    
    private var userArray = [Users]()
    private var members = ""
    private var status = Int()
    
    private var spinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topViewHeight.editTopViewHeight()
        addUserTableView.delegate = self
        addUserTableView.dataSource = self
        searchTextField.delegate = self
        searchTextField.becomeFirstResponder()
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addSingleTapGesture()
        addSpinner()
        
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkUserPresence()
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchTextField.endEditing(true)
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.spinner.removeFromSuperview()
        self.userArray = []
        self.members = ""
        self.status = Int()
       ImageDownloadService.instance.removeSession()
    }
    
    
    //BACK BUTTON PRESSED:
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
    @objc private func tappedOnScreen() {
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
extension AddUsersVC: UITextFieldDelegate { }

//TABLE VIEW:
extension AddUsersVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return userArray.count
    }
    
    //cell for row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addUserCell", for: indexPath) as? AddUserCell else {return UITableViewCell()}
        let user = userArray[indexPath.row]
        
        cell.userEmail.text = user.email
        cell.email = user.email
        updateImage(ofUser: user, andCell: cell)
        
        //Checks if user has friend or not on the search list.
        if userArray[indexPath.row].email == members {
        
            switch status {
            case 0, 1, 2:
                cell.addButton.isHidden = true
                cell.delegate = self
            default:
                return UITableViewCell()
            }
        } else {
            cell.addButton.isHidden = false
            cell.delegate = self
        }
        return cell
  
}
    
}

//WHEN USER TAP ADD BUTTON:
extension AddUsersVC: AddUserDelegate {
    
    func addUsers(withEmail: String) {
        DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!) {[unowned self] (returnedFriendList) in
            
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

//CUSTOM FUNCTIONS:
extension AddUsersVC {
    
    //CHECK IF USER IS LOGIN OR NOT:
    func checkUserPresence() {
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if Auth.auth().currentUser?.email != nil {
                
                DispatchQueue.main.async {
                    self.loginInfoLabel.isHidden = true
                    self.addUserTableView.isHidden = false
                    self.searchTextField.isEnabled = true
                }
                DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!) {(returnedFriendList) in
                    if returnedFriendList.isEmpty == false {
                        DataService.instance.getEmail(forUID: returnedFriendList[0].addedFriendUID, completion: { (returnedEmail) in
                            self.members = returnedEmail
                            self.status = returnedFriendList[0].status
                        })
                    }
                }
            } else {
                
                DispatchQueue.main.async {
                    self.loginInfoLabel.isHidden = false
                    self.addUserTableView.isHidden = true
                    self.searchTextField.isEnabled = false
                }
               
            }
            
        }
    }
    
    //WHEN USER START TYPING:
    @objc private func textFieldDidChange() {
        spinner.startAnimating()
        
        if searchTextField.text == "" {
            userArray = []
            addUserTableView.reloadData()
            self.spinner.stopAnimating()
        } else {
            self.spinner.startAnimating()
            DataService.instance.getEmailAndUserImage(forSearchQuery: searchTextField.text!, completion: {(returnedUser) in
                self.userArray = returnedUser
                self.spinner.stopAnimating()
                self.addUserTableView.reloadData()
            })
        }
        
    }
    
    //IT CHECKS THE USER IMAGE ON FIREBASE STORAGE AND UPDATE IT ON CELL:
    func updateImage(ofUser user: Users, andCell cell: AddUserCell) {
        
        //If there is user image(url) on database.
        if let imageString = user.profileImageURL, let url = URL(string: imageString) {
            
            // cell.profileImage.loadImageUsingCache(withUrlString: imageString)
            
            ImageDownloadService.instance.downloadImages(withUrl: url, completion: { (imageData) in
                cell.profileImage.image = UIImage(data: imageData)
            })
            
        } else {
            
            cell.profileImage.image = UIImage(named: "userImage")
        }
        
    }
    
    
}











