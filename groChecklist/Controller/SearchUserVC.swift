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
    @IBOutlet weak var searchTextField: customSearchTextField!
    
    var emailArray = [String]()
    var membersArray = [String]()
    
    var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTableView.delegate = self
        searchTableView.dataSource = self
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        dateFormatter.dateFormat = "MMM d, yyyy"

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nextButton.isHidden = true
    }

    //BACK BUTTON PRESSED:
    @IBAction func backButtonPressed(_ sender: UIButton) {
        
        performSegue(withIdentifier: "unwindToGroupsVC", sender: nil)
        membersArray = []
    }
    
    //NEXT BUTTON PRESSED:
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        nextButton.isEnabled = false
        
        let todayDate = Date()
        let todayDateString = dateFormatter.string(from: todayDate)
        
        DataService.instance.getUserdIds(forEmail: membersArray) { (returnedUid) in
            var idsArray = returnedUid
            idsArray.append((Auth.auth().currentUser?.uid)!)
            
            DataService.instance.createGroup(withDate: todayDateString, andTotalAmount: "0.0", forUserIds: idsArray,  completion: { (groupCreated) in
                if groupCreated {
                    DataService.instance.getAllGroups(completion: { (groupsArray) in
                        guard let addItemsVC = self.storyboard?.instantiateViewController(withIdentifier: "addItemsVC") as? AddItemsVC else {return}
                        addItemsVC.initData(forGroup: groupsArray[0])
                        self.present(addItemsVC, animated: true, completion: nil)
                        self.nextButton.isEnabled = true
                    })
                } else {
                    self.nextButton.isEnabled = true
                }
            })
        }
        }
    
    //SEARCH TEXT FIELD TEXT CHANGED:
    @objc func textFieldDidChange() {
        
        if searchTextField.text == "" {
            emailArray = []
            searchTableView.reloadData()
        } else {
            DataService.instance.getEmail(forSearchQuery: searchTextField.text!, completion: { (returnedEmail) in
                self.emailArray = returnedEmail
                self.searchTableView.reloadData()
            })
        }
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

//UITEXTFIELD DELEGATE
extension SearchUserVC: UITextFieldDelegate {
    
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














