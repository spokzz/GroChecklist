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
     @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    private var myMember = [FriendList]()
    private var memberFriend = [FriendList]()
   
    
    private var spinner: UIActivityIndicatorView!
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()

        topViewHeight.editTopViewHeight()
        myMemberTableView.delegate = self
        myMemberTableView.dataSource = self
        addSpinner()
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.myMemberTableView.isHidden = true
        spinner.startAnimating()
        checkUserPresence()
        
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.spinner.removeFromSuperview()
    }
    
    
    //BACK BUTTON PRESSED:
    @IBAction func backButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

//TABLE VIEW:
extension MyMembersVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myMember.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "myMembersCell", for: indexPath) as? MyMembersCell else {return UITableViewCell()}
        let myFriend = myMember[indexPath.row]
        
        cell.emailLabel.text = myFriend.email
        cell.friend = myFriend
        if memberFriend.count != 0 {
            cell.addedFriend = memberFriend[indexPath.row]
        }
        updateCellView(ofFriend: myFriend, andCell: cell)
        cell.delegate = self
        
        return cell
        
    }
    
}

//MEMBER CELL DELEGATE
extension MyMembersVC: MemberCellDelegate {
    
    //ACCEPT BUTTON TAPPED:
     func didTappedAccept(friend: FriendList, friend2: FriendList) {
        DataService.instance.editFriendStatus(withUserID: (Auth.auth().currentUser?.uid)!, friendListkey: friend.key, statusValue: 2) {[unowned self] (edited) in
            
            DataService.instance.editFriendStatus(withUserID: friend.addedFriendUID, friendListkey: friend2.key, statusValue: 2, completion: { (success) in
                DataService.instance.getFriendsList(userID: friend.addedFriendUID, completion: { (friendListArray) in
                    for friends in friendListArray {
                        DataService.instance.getEmail(forUID: friends.addedFriendUID, completion: { (returnedEmail) in
                            let myFriend = FriendList(addedFriendUID: friends.addedFriendUID, status: friends.status, key: friends.key, friendEmail: returnedEmail, profileImage: nil)
                            self.myMember = []
                            self.myMember.append(myFriend)
                            self.myMemberTableView.reloadData()
                        })
                    }
                    
                })

            })
        }
    }
    
    //MORE BUTTON TAPPED:
     func didTappedMore(friend: FriendList, friend2: FriendList) {
        
        let alertVC = UIAlertController(title: nil, message: "Do you wanna remove \(myMember[0].email ?? "user") from your member List?", preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(title: "REMOVE", style: .destructive) { (removed) in
            
            DataService.instance.deleteFriends(ofUID: friend2.addedFriendUID, withKey: friend.key, completion: {[unowned self] (deleted) in
                if deleted {
                    
                    DataService.instance.deleteFriends(ofUID: friend.addedFriendUID, withKey: friend2.key, completion: { (success) in
                        if success {
                            DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!, completion: { (friendListArray) in
                                if friendListArray.isEmpty == false {
                                    for friend in friendListArray {
                                        DataService.instance.getEmail(forUID: friend.addedFriendUID, completion: { (returnedEmail) in
                                            let myFriend = FriendList(addedFriendUID: friend.addedFriendUID, status: friend.status, key: friend.key, friendEmail: returnedEmail, profileImage: nil)
                                            self.myMember.append(myFriend)
                                            self.myMemberTableView.reloadData()
                                        })
                                    }
                                } else {
                                    self.myMember = []
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

//CUSTOM FUNCTIONS
extension MyMembersVC {
    
    // CHECK IF USER IS LOGIN OR NOT:
    private func checkUserPresence() {
        
        if Auth.auth().currentUser?.uid != nil {
            
            //Returns the friend list of current user.
            DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!) {[unowned self] (returnedFriendListArray) in
                if returnedFriendListArray.isEmpty == false {
                    for friends in returnedFriendListArray {
                        
                        //Returns the friend list of user friend.
                        DataService.instance.getFriendsList(userID: friends.addedFriendUID, completion: { (returnedFriendList) in
                            let userFriend = FriendList(addedFriendUID: returnedFriendList[0].addedFriendUID, status: returnedFriendList[0].status, key: returnedFriendList[0].key, friendEmail: nil, profileImage: nil)
                            self.memberFriend.append(userFriend)
                            
                            DataService.instance.getUser(withUID: friends.addedFriendUID, completion: { (returnedUser) in
                                let myFriend = FriendList(addedFriendUID: friends.addedFriendUID, status: friends.status, key: friends.key, friendEmail: returnedUser.email, profileImage: returnedUser.profileImageURL)
                                self.myMember.append(myFriend)
                                self.myMemberTableView.isHidden = false
                                self.spinner.removeFromSuperview()
                                self.myMemberTableView.reloadData()
                                
                            })
                            
                        })
                        
                    }
                } else {
                    self.spinner.removeFromSuperview()
                    self.infoLabel.text = "You don't have any members."
                    self.infoLabel.isHidden = false
                    self.myMemberTableView.isHidden = true
                }
            }
            
        } else {
            spinner.removeFromSuperview()
            self.infoLabel.text = "You have to login first."
            self.infoLabel.isHidden = false
            self.myMemberTableView.isHidden = true
            
            //Show them that there is no friends to display.
        }
    }
    
    //ADD UIACTIVITY INDICATOR VIEW
    private func addSpinner() {
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = self.view.center
        spinner.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.view.addSubview(spinner)
    }
    
    //DOWNLOADS AND RETURNS THE PROFILE IMAGE:
    func returnProfileImage(ofIndexPath indexPath: IndexPath, completion: @escaping (_ image: UIImage) -> ()) {
        if let userProfileImageURLString = myMember[indexPath.row].profileImage {
            
            guard let url = URL(string: userProfileImageURLString) else {return}
            ImageDownloadService.instance.downloadImages(withUrl: url, completion: { (imageData) in
                guard let profileImage = UIImage(data: imageData) else {return}
                completion(profileImage)
            })
        } else {
            let profileImage = UIImage(named: "userImage")
            completion(profileImage!)
        }
    }
    
    //IT UPDATES THE CELL VIEW:
    func updateCellView(ofFriend myFriend: FriendList, andCell cell: MyMembersCell) {
        
        //downloads profile picture of memeber
        if let friendProfileImageUrlString = myFriend.profileImage {
            cell.profilePicture.loadImageUsingCache(withUrlString: friendProfileImageUrlString)
        }
        
        switch myFriend.status {
        case 0:
            cell.acceptButton.setTitle("Pending", for: .normal)
            cell.acceptButton.isEnabled = false
            cell.acceptButton.isHidden = false
        case 1:
            cell.acceptButton.setTitle("Accept", for: .normal)
            cell.acceptButton.isEnabled = true
            cell.acceptButton.isHidden = false
        case 2:
            cell.acceptButton.setTitle(nil, for: .normal)
            cell.acceptButton.isHidden = true
        default:
            break
        }
        
    }

}
















