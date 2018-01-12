//
//  DataService.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = Database.database().reference()

class DataService {
    
    static let instance = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("Users")
    private var _REF_GROUPS = DB_BASE.child("Groups")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_GROUPS: DatabaseReference {
        return _REF_GROUPS
    }
    
    //ADD UID AND USERDATA IN "USERS" FOLDER IN DATABASE.
    func createDBUser(uid: String, userData: Dictionary<String, Any>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
    //RETURN EMAIL WITH SEARCH LETTER:
    func getEmail(forSearchQuery query: String, completion: @escaping (_ emailArray: [String]) -> ()) {
        var emailArray = [String]()
        
        REF_USERS.observe(.value) { (userSnapshot) in
            guard let userSnapshot = userSnapshot.children.allObjects as? [DataSnapshot] else {return}
            
            for user in userSnapshot {
                let email = user.childSnapshot(forPath: "email").value as! String
                
                if email.contains(query) == true && email != Auth.auth().currentUser?.email {
                    emailArray.append(email)
                }
            }
            completion(emailArray)

        }
    }
    
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
    
    
}




















