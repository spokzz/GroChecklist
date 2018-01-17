//
//  ViewController.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 12/30/17.
//  Copyright © 2017 Sakar Pokhrel. All rights reserved.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class HomeVC: UIViewController {

    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var informationStackView: UIStackView!
    
    private var dateFormatter = DateFormatter()
    private var createdListArray = [CreatedList]()
    private var createdListArrayReversed = [CreatedList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        dateFormatter.dateFormat = "MMM d, yyyy"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData { (success) in
            if success {
                if self.createdListArrayReversed.isEmpty {
                    self.informationStackView.isHidden = false
                    self.homeTableView.isHidden = true
                } else {
                    self.homeTableView.reloadData()
                    self.informationStackView.isHidden = true
                    self.homeTableView.isHidden = false
                }
                
            }
        }
        
        
    }
    
    //ADD BUTTON PRESSED:
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        saveCreatedListData()
        guard let addItemsVC = storyboard?.instantiateViewController(withIdentifier: "addItemsVC") as? AddItemsVC else {return }
        fetchData { (success) in
            if success {
                addItemsVC.createdList = self.createdListArrayReversed[0]
                self.presentVCFromRightSide(withViewController: addItemsVC)
            } else {
                print("Unsuccessful")
            }
        }
    }
    
    
    @IBAction func infoAddButtonPressed(_ sender: UIButton) {
        
        saveCreatedListData()
        guard let addItemsVC = storyboard?.instantiateViewController(withIdentifier: "addItemsVC") as? AddItemsVC else {return }
        fetchData { (success) in
            if success {
                addItemsVC.createdList = self.createdListArrayReversed[0]
                self.presentVCFromRightSide(withViewController: addItemsVC)
            } else {
                print("Unsuccessful")
            }
        }
        
    }
    
}

//TABLE VIEW:
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    //NUMBER OF ROWS:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return createdListArrayReversed.count
    }
    
    //CELL FOR ROW:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "homeCell", for: indexPath) as? HomeCell else {return UITableViewCell()}
        let list = createdListArrayReversed[indexPath.row]
        cell.customizeCell(groceryDate: list.date!, totalPrice: "Total Price: $\(list.total)")
        return cell
        
    }
    
    //ROW SELECTED:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let alertController = UIAlertController(title: nil, message: "\(createdListArrayReversed[indexPath.row].date!)", preferredStyle: .actionSheet)
        
        let viewAction = UIAlertAction(title: "VIEW", style: .default) { (view) in
            
            guard let viewItemsVC = self.storyboard?.instantiateViewController(withIdentifier: "viewItemsVC") as? ViewItemsVC else {return}
            let set = self.createdListArrayReversed[indexPath.row].items
            if let itemsArr = set?.allObjects as? [Items] {
                viewItemsVC.initData(itemsArray: itemsArr, createdDate: self.createdListArrayReversed[indexPath.row].date!)
                self.present(viewItemsVC, animated: true, completion: nil)
            } else {
                print("Error in view.")
            }
        }
        
        //Add total Price:
        let addtotalAction = UIAlertAction(title: "EDIT TOTAL", style: .default) { (addTotal) in
            
            let alert = UIAlertController(title: "Edit Total:", message: "", preferredStyle: UIAlertControllerStyle.alert)
            
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (alertAction) in
                let textField = alert.textFields![0] as UITextField
                if textField.text != "" {
                    if let totalPriceInDouble = Double(textField.text!) {
                        self.editTotalPrice(indexPath: indexPath, totalPrice: totalPriceInDouble)
                        self.homeTableView.reloadData()
                    }
                }
                })
            
            alert.addTextField { (textField : UITextField!) -> Void in
                self.editTotalTextField(textField: textField)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            alert.addAction(saveAction)
            
            self.present(alert, animated: true, completion: nil)
        }
        
        //Delete Action:
        let deleteAction = UIAlertAction(title: "DELETE", style: .destructive) { (deleteRow) in
            
            self.deleteCreatedList(indexPath: indexPath, completion: { (deleted) in
                if deleted {
                    self.fetchData(completion: { (fetched) in
                        if fetched {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            self.homeTableView.reloadData()
                            if self.createdListArrayReversed.isEmpty {
                                self.homeTableView.isHidden = true
                                self.informationStackView.isHidden = false
                            }
                        }
                    })
                }
            })
        }
        
        //Cancel Action:
        let cancelAction = UIAlertAction(title: "CANCEL", style: .cancel, handler: nil)
        
        alertController.addAction(viewAction)
        alertController.addAction(addtotalAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
}

//CORE DATA:
extension HomeVC {
    
    //Save Data:
    func saveCreatedListData() {
        
        let todayDate = Date()
        let todayDateString = dateFormatter.string(from: todayDate)
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let list = CreatedList(context: managedContext)
        list.date = todayDateString
        list.total = 0.0
        
        do {
            try managedContext.save()
        } catch {
            print("Error in saving listData into coreData")
        }
    }
    
    //Fetch Data:
    func fetchData(completion: @escaping (_ sender: Bool) -> ()) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<CreatedList>(entityName: "CreatedList")
        
        do {
            createdListArray =  try managedContext.fetch(fetchRequest)
            createdListArrayReversed = createdListArray.reversed()
            completion(true)
        } catch {
            print("Error in parsing Data from CreatedList")
            completion(false)
        }
    }
    
    //Delete Selected List:
    func deleteCreatedList(indexPath: IndexPath, completion: @escaping (_ status: Bool) -> ()) {
        
         guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let selectedList = createdListArray[createdListArray.count - (1 + indexPath.row)]
        managedContext.delete(selectedList)
        
        do {
            try managedContext.save()
            completion(true)
        } catch {
            print("Error in deleting List from Home VC")
            completion(false)
        }
    }
    
    //Edit Total Price:
    func editTotalPrice (indexPath: IndexPath, totalPrice: Double) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let selectedList = self.createdListArray[self.createdListArray.count - (1 + indexPath.row)]
        selectedList.total = totalPrice
        
        do {
            try managedContext.save()
        } catch {
            print("Editing Price error")
        }
    }
    
    
}

//UITEXTFIELD:
extension HomeVC {
    
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












