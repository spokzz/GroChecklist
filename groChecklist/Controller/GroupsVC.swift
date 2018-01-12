//
//  GroupsVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/2/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase

class GroupsVC: UIViewController {

    @IBOutlet weak var groupTableView: UITableView!
    
    var groupsArray = [Groups]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        groupTableView.delegate = self
        groupTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.getAllGroups { (allGroups) in
            self.groupsArray = allGroups
            self.groupTableView.reloadData()
        }
    }

    //ADD GROUP BUTTON PRESSED:
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        //If nobody has loggedIn yet or it's logged out.
        if Auth.auth().currentUser == nil {
           
            guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") else {return}
            present(loginVC, animated: true, completion: nil)
        } else {
            guard let searchUserVC = storyboard?.instantiateViewController(withIdentifier: "searchUserVC") else {return }
            present(searchUserVC, animated: true, completion: nil)
        }
    }
    
    //UNWIND SEGUE:
    @IBAction func unwindToGroupsVC(segue: UIStoryboardSegue) { }
        

}

//TABLE VIEW:
extension GroupsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath) as? GroupsCell else {return UITableViewCell()}
        let groupToShow = groupsArray[indexPath.row]
        cell.configureCell(date: groupToShow.groupCreatedDate, totalPrice: groupToShow.totalAmount, userImage1: "ishwor", userImage2: "sakar", userImage3: "alien")
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertVC = UIAlertController(title: nil, message: groupsArray[indexPath.row].groupCreatedDate, preferredStyle: .actionSheet)
        
        //View Items of selected Group
        let viewAction = UIAlertAction(title: "VIEW", style: .default) { (view) in
            
            guard let viewGroupItems = self.storyboard?.instantiateViewController(withIdentifier: "viewGroupItems") as? ViewGroupItems else {return}
            viewGroupItems.initData(groupPressed: self.groupsArray[indexPath.row])
            self.present(viewGroupItems, animated: true, completion: nil)
            
        }
        
        //Edit Total:
        let editTotalAction = UIAlertAction(title: "EDIT TOTAL", style: .default) { (editTotal) in
            
            let alert = UIAlertController(title: "Edit Total:", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (alertAction) in
                let textField = alert.textFields![0] as UITextField
                if textField.text != "" {
                    if let totalPriceInDouble = Double(textField.text!) {
                        DataService.instance.editTotalPrice(ofGroup: self.groupsArray[indexPath.row], newTotalPrice: "\(totalPriceInDouble)", completion: { (completed) in
                            if completed {
                                DataService.instance.getAllGroups { (allGroups) in
                                    self.groupsArray = allGroups
                                    self.groupTableView.reloadData()
                                }
                            }
                        })
                        
                    }
                }
            })
            
            alert.addTextField { (textField : UITextField!) -> Void in
                self.editTotalTextField(textField: textField)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        
        //Delete Groups:
        let deleteAction = UIAlertAction(title: "DELETE", style: .destructive) { (delete) in
            
            DataService.instance.deleteGroup(ofGroupKey: self.groupsArray[indexPath.row].key, completion: { (success) in
                if success {
                    DataService.instance.getAllGroups { (allGroups) in
                        self.groupsArray = allGroups
                        self.groupTableView.reloadData()
                    }
                }
            })
            
        }
        
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        
        alertVC.addAction(viewAction)
        alertVC.addAction(editTotalAction)
        alertVC.addAction(deleteAction)
        alertVC.addAction(cancelAction)
        
        present(alertVC, animated: true, completion: nil)
        
    }
    
    
}

//UITEXTFIELD:
extension GroupsVC {
    
    func editTotalTextField(textField: UITextField) {
        
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.leftViewMode = .always
        let placeholderImageView = UIImageView(frame: CGRect(x: 3, y: 0, width: 15, height: 15))
        placeholderImageView.image = UIImage(named: "dollar")
        let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 18))
        placeholderView.addSubview(placeholderImageView)
        textField.leftView = placeholderView
        textField.placeholder = "22.46"
        
    }
    
    
}



























