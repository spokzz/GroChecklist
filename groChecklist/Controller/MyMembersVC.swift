//
//  MyMembersVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/13/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase

class MyMembersVC: UIViewController {

    @IBOutlet weak var myMemberTableView: UITableView!
    
    private var addedMember = [FriendList]()
    private var addedMember2 = [FriendList]()
    
    private var spinner: UIActivityIndicatorView!
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()

        myMemberTableView.delegate = self
        myMemberTableView.dataSource = self
        addSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        spinner.startAnimating()
        
        if Auth.auth().currentUser?.uid != nil {
            myMemberTableView.isHidden = false
        DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!) { (returnedFriendListArray) in
            if returnedFriendListArray.isEmpty == false {
                for friends in returnedFriendListArray {
                    
                    DataService.instance.getFriendsList(userID: friends.addedFriendUID, completion: { (returnedFriendList) in
                        let friend1 = FriendList(addedFriendUID: returnedFriendList[0].addedFriendUID, status: returnedFriendList[0].status, key: returnedFriendList[0].key, friendEmail: nil)
                        self.addedMember2.append(friend1)
                        
                        DataService.instance.getEmail(forUID: friends.addedFriendUID, completion: { (returnedEmail) in
                            let myFriend = FriendList(addedFriendUID: friends.addedFriendUID, status: friends.status, key: friends.key, friendEmail: returnedEmail)
                            self.addedMember.append(myFriend)
                            self.spinner.removeFromSuperview()
                            self.myMemberTableView.reloadData()
                        })
                        
                    })

                    }
            }
        }
            
        } else {
            myMemberTableView.isHidden = true
            spinner.removeFromSuperview()
            //Show them that there is no friends to display.
        }
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.spinner.removeFromSuperview()
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //ADD UIACTIVITY INDICATOR VIEW
    private func addSpinner() {
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = self.view.center
        spinner.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.view.addSubview(spinner)
    }
    
    
    
}

//TABLE VIEW:
extension MyMembersVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedMember.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myMembersCell", for: indexPath) as? MyMembersCell else {return UITableViewCell()}
        
        if addedMember.isEmpty == false {
            if addedMember[indexPath.row].status == 0 {
                cell.configureCell(profilePicture: UIImage(named: "sakar")!, buttonTitle: "Pending", friendList: addedMember[indexPath.row], addedFriend: addedMember2[indexPath.row])
                cell.acceptButton.isEnabled = false
                
            } else if addedMember[indexPath.row].status == 1 {
                cell.configureCell(profilePicture: UIImage(named: "sakar")!, buttonTitle: "Accept", friendList: addedMember[indexPath.row], addedFriend: addedMember2[indexPath.row])
                cell.acceptButton.isEnabled = true
                
            } else if addedMember[indexPath.row].status == 2 {
                cell.configureCell(profilePicture: UIImage(named: "sakar")!, buttonTitle: "", friendList: addedMember[indexPath.row], addedFriend: addedMember2[indexPath.row])
                cell.acceptButton.isHidden = true
                
            }
            cell.delegate = self
        }
        
        
        return cell
    }
    
}

extension MyMembersVC: MemberCellDelegate {
    
    //ACCEPT BUTTON TAPPED:
     func didTappedAccept(friend: FriendList, friend2: FriendList) {
        DataService.instance.editFriendStatus(withUserID: (Auth.auth().currentUser?.uid)!, friendListkey: friend.key, statusValue: 2) { (edited) in
            
            DataService.instance.editFriendStatus(withUserID: friend.addedFriendUID, friendListkey: friend2.key, statusValue: 2, completion: { (success) in
                DataService.instance.getFriendsList(userID: friend.addedFriendUID, completion: { (friendListArray) in
                    for friends in friendListArray {
                        DataService.instance.getEmail(forUID: friends.addedFriendUID, completion: { (returnedEmail) in
                            let myFriend = FriendList(addedFriendUID: friends.addedFriendUID, status: friends.status, key: friends.key, friendEmail: returnedEmail)
                            self.addedMember = []
                            self.addedMember2 = []
                            self.addedMember.append(myFriend)
                            self.myMemberTableView.reloadData()
                        })
                    }
                    
                })

            })
        }
    }
    
    //MORE BUTTON TAPPED:
     func didTappedMore(friend: FriendList, friend2: FriendList) {
        
        let alertVC = UIAlertController(title: nil, message: "Do you wanna remove \(addedMember[0].email ?? "user") from your member List?", preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "REMOVE", style: .destructive) { (removed) in
            
            DataService.instance.deleteFriends(ofUID: friend2.addedFriendUID, withKey: friend.key, completion: { (deleted) in
                if deleted {
                    
                    DataService.instance.deleteFriends(ofUID: friend.addedFriendUID, withKey: friend2.key, completion: { (success) in
                        if success {
                            DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!, completion: { (friendListArray) in
                                if friendListArray.isEmpty == false {
                                    for friend in friendListArray {
                                        DataService.instance.getEmail(forUID: friend.addedFriendUID, completion: { (returnedEmail) in
                                            let myFriend = FriendList(addedFriendUID: friend.addedFriendUID, status: friend.status, key: friend.key, friendEmail: returnedEmail)
                                            self.addedMember.append(myFriend)
                                            self.myMemberTableView.reloadData()
                                        })
                                    }
                                } else {
                                    self.addedMember = []
                                    self.myMemberTableView.reloadData()
                                }
                                
                            })
                        }
                    })
                    
                    
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        
        alertVC.addAction(removeAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true, completion: nil)
        
    }
    
    
}

















