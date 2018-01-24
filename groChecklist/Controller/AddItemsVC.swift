//
//  AddItemsVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 12/31/17.
//  Copyright © 2017 Sakar Pokhrel. All rights reserved.
//

import UIKit
import CoreData

class AddItemsVC: UIViewController {
    
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var itemEntryTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var numberOfItemsLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    private var numberOfItems: Int = 1
    private var itemsArray = [Items]()
    private var itemsArrayReversed = [Items]()
    private var newItemsArray = [Items]()
    private var groceryItems = [GroceryItem]()
    
    private var group: Groups?
    
     var createdList: CreatedList!
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        topViewHeight.editTopViewHeight()
        itemTableView.delegate = self
        itemTableView.dataSource = self
        saveButton.isHidden = true
        addTapGesture()
        
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        backButton.isHidden = false
        newItemsArray = []
        groceryItems = []
        if group != nil {
            backButton.isHidden = true
        }
    }
    
    //TAKES GROUP FROM SEARCHUSERVC
    func initData(forGroup group: Groups) {
        self.group = group
    }
    
    //ADD TAP GESTURE (SINGLE TAP)
    private func addTapGesture() {
        let dismiss = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(dismiss)
    }
    
    //USER TAPPED ON A SCREEN:
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    //UPLOAD BUTTON PRESSED:
    @IBAction func uploadButtonPressed(_ sender: UIButton) {
        
        if itemEntryTextField.text != "" {
            if group != nil {
                let groceryItems = GroceryItem(itemTitle: itemEntryTextField.text!, numberOfItems: String(numberOfItems), checked: false, groceryKey: nil)
                self.groceryItems.insert(groceryItems, at: 0)
            } else {
                saveItemData(itemTitle: itemEntryTextField.text!, itemQuantity: numberOfItems)
                fetchData()
            }
            
            itemEntryTextField.text = ""
            numberOfItemsLabel.text = "1"
            numberOfItems = 1
            itemTableView.reloadData()
            saveButton.isHidden = false
        }
    }
    
    //BACK BUTTON PRESSED:
    //When it will be pressed, it will delete the created List.
    @IBAction func backButtonPressed(_ sender: UIButton) {
        if group != nil {
            self.groceryItems = []
            self.dismissViewController()
        } else {
            deleteCreatedList { (success) in
                if success {
                    self.dismissViewController()
                }
            }
        }
        
        }
    
    //SAVE BUTTON PRESSED:
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        if group != nil {
            
            DataService.instance.uploadItemsInGroup(withItems: groceryItems, forGroupKey: (group?.key)!, uploadCompletion: { (uploaded) in
                self.groceryItems = []
                self.performSegue(withIdentifier: "unwindToGroups", sender: nil)
            })
        } else {
            dismissViewController()
        }
       
    }
    
    //INCREASE BUTTON (+) PRESSED:
    @IBAction func increaseNumBtnPressed(_ sender: UIButton) {
        
        numberOfItems += 1
        numberOfItemsLabel.text = String(numberOfItems)
        
    }
    
    //DECREASE BUTTON (-) PRESSED
    @IBAction func decreaseNumBtnPressed(_ sender: UIButton) {
        
        if numberOfItems > 1 {
           numberOfItems -= 1
            numberOfItemsLabel.text = String(numberOfItems)
        }
    }
    
    

}

//TABLE VIEW:
extension AddItemsVC: UITableViewDelegate, UITableViewDataSource {
    
    //NUMBER OF ROWS IN SECTION:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if group != nil {
            return groceryItems.count
        } else {
          return newItemsArray.count
        }
        
    }
    
    //CELL FOR ROW:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "addItemCell", for: indexPath) as? AddItemCell else {return UITableViewCell()}
        if group != nil {
            cell.configureCell(itemTitle: groceryItems[indexPath.row].itemTitle, numberOfItems: groceryItems[indexPath.row].numberOfItems)
            return cell
            
        } else {
            let items = newItemsArray[indexPath.row]
            cell.configureCell(itemTitle: items.itemTitle!, numberOfItems: String(items.itemQuantity))
        }
        
        return cell
    }
    
    //Remove rows from tableView.
  /* func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "DELETE") { (action, indexPath) in
            
            self.deleteData(indexPath: indexPath, completion: { (deleted) in
                if deleted {
                    self.fetchData()
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    self.itemTableView.reloadData()
                }
            })
        }
        
        return [delete]
    } */
    
}

//CORE DATA:
extension AddItemsVC {
    
    //Save items:
    func saveItemData(itemTitle: String, itemQuantity: Int) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let items = Items(context: managedContext)
        items.itemTitle = itemTitle
        items.itemQuantity = Int32(itemQuantity)
        items.createdList = createdList
        
        do {
            try managedContext.save()
        } catch {
            print("Error in saving data: \(error.localizedDescription)")
        }
        
    }
    
    //Fetch Items:
    func fetchData() {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        let fetchRequest = NSFetchRequest<Items>(entityName: "Items")
        
        do {
            itemsArray = try managedContext.fetch(fetchRequest)
            itemsArrayReversed = itemsArray.reversed()
            print(itemsArray.count)
            if itemsArrayReversed[0].createdList == createdList {
                newItemsArray.insert(itemsArrayReversed[0], at: 0)
            }
        } catch {
            print("Error in parsing data")
        }
        
    }
    
    //Delete SelectedItems from Core Data.
   /* func deleteData(indexPath: IndexPath, completion: @escaping (_ status: Bool) -> ()) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let removedItem = itemsArray[itemsArray.count - (1 + indexPath.row)]
        managedContext.delete(removedItem)
        
        do {
            try managedContext.save()
            completion(true)
        } catch {
            print("Error in deleting data from swiping in AddItemsVC table row")
            completion(false)
        }
    } */
    
    
    //Delete CreatedList Model.
    func deleteCreatedList(completion: @escaping (_ status: Bool) -> ()) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        if let items = createdList {
            managedContext.delete(items)
        }
        
        do {
            try managedContext.save()
            completion(true)
        } catch {
            print("Error in AddItemsVC while deleting the data.\(error)")
            completion(false)
        }
    }
    
    
}


















