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
    @IBOutlet weak var informationStackView: UIStackView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    private var groupsArray = [Groups]()
    private var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topViewHeight.editTopViewHeight()
        groupTableView.delegate = self
        groupTableView.dataSource = self
        addSpinner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        spinner.startAnimating()
        checkUserPresence()
        
    }
    
    //VIEW WILL DISAPPEAR:
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.spinner.removeFromSuperview()
    }
    
    //CHECKS IF USER IS NIL OR NOT:
    private func checkUserPresence() {
        
        if Auth.auth().currentUser?.uid != nil {
            groupTableView.isHidden = false
            informationStackView.isHidden = true
            DataService.instance.getAllGroups { (allGroups) in
                
                if allGroups.isEmpty {
                    self.groupTableView.isHidden = true
                    self.informationStackView.isHidden = false
                    
                } else {
                    self.groupsArray = allGroups
                    self.groupTableView.isHidden = false
                    self.informationStackView.isHidden = true
                    self.groupTableView.reloadData()
                    
                }
                self.spinner.removeFromSuperview()
            }
        }  else {
            groupTableView.isHidden = true
            informationStackView.isHidden = false
            self.spinner.removeFromSuperview()
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
            presentVCFromRightSide(withViewController: searchUserVC)
        }
    }
    
    //ADD BUTTON PRESSED (INFORMATION STACK VIEW:)
    @IBAction func infoAddButtonPressed(_ sender: UIButton) {
        
        //If nobody has loggedIn yet or it's logged out.
        if Auth.auth().currentUser == nil {
            
            guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") else {return}
            present(loginVC, animated: true, completion: nil)
        } else {
            guard let searchUserVC = storyboard?.instantiateViewController(withIdentifier: "searchUserVC") else {return }
            presentVCFromRightSide(withViewController: searchUserVC)
        }
        
    }
    
    //UNWIND SEGUE:
    @IBAction func unwindToGroupsVC(segue: UIStoryboardSegue) { }
    
    //ADD UIACTIVITY INDICATOR VIEW
    private func addSpinner() {
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.center = self.view.center
        spinner.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        self.view.addSubview(spinner)
    }

}

//TABLE VIEW:
extension GroupsVC: UITableViewDelegate, UITableViewDataSource {
    
    //NUMBER OF ROWS:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsArray.count
    }
    
    //CELL FOR ROW:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupsCell", for: indexPath) as? GroupsCell else {return UITableViewCell()}
        
        let groupToShow = groupsArray[indexPath.row]
        cell.dateLabel.text = groupToShow.groupCreatedDate
        cell.totalLabel.text = "Total Amount:\(groupToShow.totalAmount)"
        
        //Returns the friend images in cell
        for membersUID in groupToShow.members {
            if membersUID != Auth.auth().currentUser?.uid {
                
                DataService.instance.getUser(withUID: membersUID, completion: { (returnedUser) in
                    if let userImageURL = returnedUser.profileImageURL {
                        cell.friendImage.loadImageUsingCache(withUrlString: userImageURL)
                    } else {
                        cell.friendImage.image = UIImage(named: "userImage")
                    }
                })
            }
            
        }
        
        return cell
    }
    
    //DID SELECT ROW:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addAlertController(indexPath: indexPath, tableView: tableView)
    }
    
    
    //ADD ALERT CONTROLLER ON SELECTED ROW:
    func addAlertController(indexPath: IndexPath, tableView: UITableView) {
     
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
                        let priceRoundUp = totalPriceInDouble.round(to: 2)
                        DataService.instance.editTotalPrice(ofGroup: self.groupsArray[indexPath.row], newTotalPrice: "\(priceRoundUp)", completion: { (completed) in
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
                        if self.groupsArray.isEmpty {
                            self.groupTableView.isHidden = true
                            self.informationStackView.isHidden = false
                        }
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



























