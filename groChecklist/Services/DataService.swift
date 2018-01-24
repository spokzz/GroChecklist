//
//  DataService.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation
import Firebase
import AlamofireImage


let DB_BASE = Database.database().reference()
//0 - pending, 1 - Accept, 2 - friends. (Status in Database)

class DataService {
    
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("Users")
    private var _REF_GROUPS = DB_BASE.child("Groups")
    private var _REF_FRIENDS = DB_BASE.child("Friends")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    var REF_FRIENDS: DatabaseReference {
        return _REF_FRIENDS
    }
    
    
    
    //ADD UID AND USERDATA IN "USERS" FOLDER IN DATABASE.
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    //ADD IMAGES IN "USER" DATABASE:
    func addImageInUserDB(withprofileImageURL url: String) {
        REF_USERS.child((Auth.auth().currentUser?.uid)!).updateChildValues(["profileImage": url])
    }
    
    //RETURN EMAIL WITH SEARCH LETTER:
    func getEmailAndUserImage(forSearchQuery query: String, completion: @escaping (_ userArray: [Users]) -> ()) {
        var userArray = [Users]()
        
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for user in userSnapshot {
                
                let email = user.childSnapshot(forPath: "email").value as! String
                let profileImage = user.childSnapshot(forPath: "profileImage").value as? String ?? nil
                
                if email.contains(query) == true && email != Auth.auth().currentUser?.email {
                    let user = Users(email: email, profileImageURL: profileImage)
                    userArray.append(user)
                    
                }
            }
            completion(userArray)

        }
    }
    
    //RETURNS USERS WITH IMAGE DATA (FOR SEARCHING USERS)
  /*  func getUserEmailAndImageData(forSearchQuery query: String, completion: @escaping (_ userArray: [UserWithImageData]) -> ()) {
        var usersArray = [UserWithImageData]()
        
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for user in userSnapshot {
                
                let email = user.childSnapshot(forPath: "email").value as! String
                let profileImageString = user.childSnapshot(forPath: "profileImage").value as? String ?? nil
                
                if email.contains(query) == true && email != Auth.auth().currentUser?.email {
                    
                    if profileImageString != nil {
                        
                        guard let imageURL = URL(string: profileImageString!) else {return}
                        
                        DispatchQueue.main.async {
                            ImageDownloadService.instance.downloadImages(withUrl: imageURL, completion: { (returnedImageData) in
                                let userWithImage = UserWithImageData(email: email, imageData: returnedImageData)
                                usersArray.append(userWithImage)
                                print(userWithImage.email)
                            })
                        }
                        
                    } else {
                        let userWithoutImage = UserWithImageData(email: email, imageData: nil)
                        usersArray.append(userWithoutImage)
                    }
                }
            }
            print(usersArray.count)
            completion(usersArray)
            
        }
        
     }
  */
    
    
    //SIGN OUT FROM FIREBASE:
    func signOut(completion: (_ status: Bool, _ error: Error?) -> ()) {
        
        do {
            try Auth.auth().signOut()
            completion(true, nil)
        } catch {
            completion(false,error)
        }
    }
    
    //CREATE GROUP:
    func createGroup(withDate date: String, andTotalAmount total: String, forUserIds uids: [String], completion: @escaping (_ groupsCreated: Bool) -> ()) {
        
        REF_GROUPS.childByAutoId().updateChildValues(["CreatedDate": date, "TotalAmount": total, "members": uids])
        completion(true)
    }
    
    //RETURNS UIDS FROM EMAIL:
    func getUserdIds(forEmail emailArray:[String], completion: @escaping (_ uidArray: [String]) -> ()) {
        var idArray = [String]()
        
        REF_USERS.observeSingleEvent(of: .value) { (emailSnapshot) in
            guard let emailSnapshot = emailSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for email in emailSnapshot {
                let userEmail = email.childSnapshot(forPath: "email").value as! String
                if emailArray.contains(userEmail) {
                    idArray.append(email.key)
                }
            }
            completion(idArray)
        }
    }
    
    //GET EMAIL FROM UID
    func getEmail(forUID uid: String, completion: @escaping (_ sender: String) -> ()) {
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (dataSnapshot) in
            
            guard let email = dataSnapshot.childSnapshot(forPath: "email").value as? String else {return}
               completion(email)
            
            
        }
    }
    
    //RETURNS USER FROM UID:
    func getUser(withUID uid: String, completion: @escaping (_ users: Users) -> ()) {
        
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (userSnapshot) in
            
            guard let email = userSnapshot.childSnapshot(forPath: "email").value as? String else {return}
            if let profileImage = userSnapshot.childSnapshot(forPath: "profileImage").value as? String {
                
                let user = Users(email: email, profileImageURL: profileImage)
                completion(user)
            } else {
                let user = Users(email: email, profileImageURL: nil)
                completion(user)
            }
        }
    }
    
    //UPLOAD ITEMS IN GROUP:
    func uploadItemsInGroup(withItems itemsArray: [GroceryItem], forGroupKey groupKey: String, uploadCompletion: @escaping (_ sender: Bool) -> ()) {
        
        for items in itemsArray {
            REF_GROUPS.child(groupKey).child("groceryItems").childByAutoId().updateChildValues(["itemTitle": items.itemTitle, "numberOfItems": items.numberOfItems, "checked": items.checked])
        }
        uploadCompletion(true)
    }
    
    //RETURN ALL MY GROUPS:
    func getAllGroups(completion: @escaping (_ groupsArray: [Groups]) -> ()) {
        var groupsArray = [Groups]()
        
        REF_GROUPS.observeSingleEvent(of: .value) { (groupsSnapshot) in
            guard let groupsSnapshot = groupsSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for group in groupsSnapshot {
                
                let memberArray = group.childSnapshot(forPath: "members").value as! [String]
                if memberArray.contains((Auth.auth().currentUser?.uid)!) {
                    
                    let createdDate = group.childSnapshot(forPath: "CreatedDate").value as! String
                    let totalAmount = group.childSnapshot(forPath: "TotalAmount").value as! String
                    
                    let group = Groups(groupCreatedDate: createdDate, key: group.key, members: memberArray, totalAmount: totalAmount)
                    groupsArray.insert(group, at: 0)
                }
            }
            
            completion(groupsArray)
        }
    }
    
    
    //RETURN ALL ITEMS OF SPECIFIC GROUPS:
    func getAllItems(forGroup group: Groups, completion: @escaping (_ sender: [GroceryItem]) -> ()) {
        var itemsArray = [GroceryItem]()
        
        REF_GROUPS.child(group.key).child("groceryItems").observeSingleEvent(of: .value) { (groceryItemSnapshot) in
            guard let groceryItemSnapshot = groceryItemSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for groceryItems in groceryItemSnapshot {
                
                let itemTitle = groceryItems.childSnapshot(forPath: "itemTitle").value as! String
                let numberOfItems = groceryItems.childSnapshot(forPath: "numberOfItems").value as! String
                let itemChecked = groceryItems.childSnapshot(forPath: "checked").value as! Bool
                
                let items = GroceryItem(itemTitle: itemTitle, numberOfItems: numberOfItems, checked: itemChecked, groceryKey: groceryItems.key)
                itemsArray.append(items)
                
            }
            completion(itemsArray)
        }
    }
    
    //ADD FRIENDS IN DATABSE.
    func createFriends(withUserID uid: String, withFriendUID fid: String, status: Int) {
        REF_FRIENDS.child(uid).childByAutoId().updateChildValues(["AddedFriend": fid, "status": status])
    }
    
    
    
    //RETURN ALL FRIENDS LIST.
    func getFriendsList(userID uid: String, completion: @escaping (_ sender: [FriendList]) -> ()) {
        var friendsArray = [FriendList]()
        
        REF_FRIENDS.child(uid).observeSingleEvent(of: .value) { (friendListSnapshot) in
            guard let friendListSnapshot = friendListSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for friendList in friendListSnapshot {
                    
                    let addedFriend = friendList.childSnapshot(forPath: "AddedFriend").value as! String
                    let status = friendList.childSnapshot(forPath: "status").value as! Int
                    
                let friendListArray = FriendList(addedFriendUID: addedFriend, status: status, key: friendList.key, friendEmail: nil, profileImage: nil)
                friendsArray.append(friendListArray)
                
            }
            completion(friendsArray)
        }
    }
    
    //CHANGE THE CHECKED IMAGE VALUE:
    func changeSelectedImageValue(forGroup group: Groups,andGroceryItem item: GroceryItem, itemsChecked: Bool, completion: @escaping (_ valueChanged: Bool) -> ()) {
        REF_GROUPS.child(group.key).child("groceryItems").child(item.groceryKey).child("checked").setValue(itemsChecked)
        completion(true)
        
    }
    
    //EDIT TOTAL PRICE OF GROUP:
    func editTotalPrice(ofGroup group: Groups, newTotalPrice total: String, completion: @escaping (_ status: Bool) -> ()){
        
        REF_GROUPS.child(group.key).child("TotalAmount").setValue(total)
        completion(true)
    }
    
    //DELETES SELECTED GROUP:
    func deleteGroup(ofGroupKey key: String, completion: @escaping (_ status: Bool) -> ()){
        
        REF_GROUPS.child(key).removeValue()
        completion(true)
    }
    
    //EDIT FRIEND LIST STATUS IN DATABASE:
    func editFriendStatus(withUserID uid: String, friendListkey key: String, statusValue value: Int, completion: @escaping (_ sender: Bool) -> ()) {
        
        REF_FRIENDS.child(uid).child(key).child("status").setValue(value)
        completion(true)
    }
    
    //DELETE FRIENDS FROM FRIEND LIST IN DATABSE:
    func deleteFriends(ofUID uid: String, withKey key: String, completion: @escaping (_ status: Bool) -> ()) {
        
        REF_FRIENDS.child(uid).child(key).removeValue()
        completion(true)
    }
    
    
    
}




















