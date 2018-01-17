//
//  SearchUserVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/2/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase

class SearchUserVC: UIViewController {

    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var informationStackView: UIStackView!
    
    private var emailArray = [String]()
    private var membersArray = [String]()
    private var userIdsArray = [String]()
    
    private var dateFormatter = DateFormatter()
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.delegate = self
        searchTableView.dataSource = self
        dateFormatter.dateFormat = "MMM d, yyyy"

    }
    
    //VIEW WILL APPEAR"
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextButton.isHidden = true
        
        DataService.instance.getFriendsList(userID: (Auth.auth().currentUser?.uid)!) { (returnedFriendList) in
            DataService.instance.getEmail(forUID: returnedFriendList[0].addedFriendUID, completion: { (returnedEmail) in
                if returnedFriendList.isEmpty && returnedFriendList[0].status != 2{
                    self.searchTableView.isHidden = true
                    self.informationStackView.isHidden = false
                    
                } else {
                   self.emailArray.append(returnedEmail)
                    self.userIdsArray.append(returnedFriendList[0].addedFriendUID)
                    self.searchTableView.isHidden = false
                    self.informationStackView.isHidden = true
                    self.searchTableView.reloadData()
                }
                
            })
        }
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.emailArray = []
        self.membersArray = []
        self.userIdsArray = []
    }

    //BACK BUTTON PRESSED:
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        dismissViewController()
        membersArray = []
    }
    
    //NEXT BUTTON PRESSED:
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        nextButton.isEnabled = false
        
        let todayDate = Date()
        let todayDateString = dateFormatter.string(from: todayDate)
        
            self.userIdsArray.append((Auth.auth().currentUser?.uid)!)
            
            DataService.instance.createGroup(withDate: todayDateString, andTotalAmount: "0.0", forUserIds: userIdsArray,  completion: { (groupCreated) in
                if groupCreated {
                    DataService.instance.getAllGroups(completion: { (groupsArray) in
                        guard let addItemsVC = self.storyboard?.instantiateViewController(withIdentifier: "addItemsVC") as? AddItemsVC else {return}
                        addItemsVC.initData(forGroup: groupsArray[0])
                        self.presentVCFromRightSide(withViewController: addItemsVC)
                        self.nextButton.isEnabled = true
                    })
                } else {
                    self.nextButton.isEnabled = true
                }
        })
        }
    }


//TABLE VIEW:
extension SearchUserVC: UITableViewDataSource, UITableViewDelegate {
    
    //number of rows:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailArray.count
    }
    
    //cell for row:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchUserCell", for: indexPath) as? SearchUserCell else {return UITableViewCell()}
        if membersArray.contains(emailArray[indexPath.row]) {
            cell.configureCell(userImage: "sakar", userEmail: emailArray[indexPath.row], imageShow: true)
            
        } else {
             cell.configureCell(userImage: "sakar", userEmail: emailArray[indexPath.row], imageShow: false)
        }
        return cell
    }
    
    //did Select Row:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchUserCell else {return}
        let emailSelected = cell.userEmailLabel.text!
        saveData(userEmail: emailSelected)
        if membersArray.isEmpty {
            self.nextButton.isHidden = true
        } else {
            self.nextButton.isHidden = false
        }
    }
    
}


//SAVE EMAIL FROM SEARCH LIST.
extension SearchUserVC {
    
    //It will save email from search Text Field. (Tapped)
    private func saveData(userEmail: String) {
        
        if membersArray.contains(userEmail) == false {
            membersArray.append(userEmail)
        } else {
            if let index = membersArray.index(of: userEmail) {
                membersArray.remove(at: index)
            }
        }
    }
    
    
}














