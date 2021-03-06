//
//  ViewController.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 12/30/17.
//  Copyright © 2017 Sakar Pokhrel. All rights reserved.
//

import UIKit
import CoreData

var coreDataTotalAmount: Double!

let appDelegate = UIApplication.shared.delegate as? AppDelegate

class HomeVC: UIViewController {

    @IBOutlet weak var homeTableView: UITableView!
    @IBOutlet weak var informationStackView: UIStackView!
    @IBOutlet weak var topViewHeight: NSLayoutConstraint!
    
    private var dateFormatter = DateFormatter()
    private var createdListArray = [CreatedList]()
    private var createdListArrayReversed = [CreatedList]()
    
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topViewHeight.editTopViewHeight()
        homeTableView.delegate = self
        homeTableView.dataSource = self
        dateFormatter.dateFormat = "MMM d, yyyy"
        registerForPreviewing(with: self, sourceView: homeTableView)
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData {[unowned self] (success) in
            self.listFetched(completed: success)
        }
        calculateTotalAmount()
    }
    
    
    //ADD BUTTON PRESSED:
    @IBAction func addButtonPressed(_ sender: UIButton) {
        
        handleAddButton()
    }
    
    //ADD BUTTON PRESSED: (WHEN TABLE VIEW IS HIDDEN, IT WILL APPEAR)
    @IBAction func infoAddButtonPressed(_ sender: UIButton) {
        
        handleAddButton()
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
        
        addAlertController(indexPath: indexPath, tableView: tableView)
        
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
    func editTotalPrice(indexPath: IndexPath, totalPrice: Double) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let selectedList = self.createdListArray[self.createdListArray.count - (1 + indexPath.row)]
        selectedList.total = totalPrice
        
        do {
            try managedContext.save()
        } catch {
            print("Editing Price error")
        }
    }
    
    //Edit Title:
    func editTitle(ofindexPath indexPath: IndexPath, withTitle title: String) {
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
        let selectedList = self.createdListArray[self.createdListArray.count - (1 + indexPath.row)]
        selectedList.date = title
        
        do {
            try managedContext.save()
        } catch {
            print("Saving Title error in core data.")
        }
        
        
    }
    
}

//3D TOUCH
extension HomeVC: UIViewControllerPreviewingDelegate {
    
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = homeTableView.indexPathForRow(at: location), let cellInIndexPath = homeTableView.cellForRow(at: indexPath) else {return nil}
        
       guard let popVC = storyboard?.instantiateViewController(withIdentifier: "viewItemsVC") as? ViewItemsVC else {return nil}
        let set = self.createdListArrayReversed[indexPath.row].items
        if let itemsArr = set?.allObjects as? [Items] {
            popVC.initData(itemsArray: itemsArr, createdDate: self.createdListArrayReversed[indexPath.row].date!)
        }
        previewingContext.sourceRect = cellInIndexPath.contentView.frame
        return popVC
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
}

//CUSTOM FUNCTIONS:
extension HomeVC {
    
    //RETURNS VIEW APPEARANCE BASED ON VALUE FETCHED RESULT:
    private func listFetched(completed: Bool) {
        
        if completed {
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
    
    //Calculates the totalAmount of Core Data:
    private func calculateTotalAmount() {
        var totalAmount = Double()
        
        for list in createdListArray {
            totalAmount += list.total
        }
        
        coreDataTotalAmount = totalAmount.round(to: 2)
    }
    
    //HANDLES THE ADD BUTTON PRESSED:
    private func handleAddButton() {
        
        saveCreatedListData()
        guard let addItemsVC = storyboard?.instantiateViewController(withIdentifier: "addItemsVC") as? AddItemsVC else {return }
        fetchData {[unowned self] (success) in
            if success {
                addItemsVC.createdList = self.createdListArrayReversed[0]
                self.presentVCFromRightSide(withViewController: addItemsVC)
            } else {
                print("Unsuccessful")
            }
        }
    }
    
    //IT WILL ADD ALERT CONTROLLER WITH DIFFERENT OPTIONS:
    private func addAlertController(indexPath: IndexPath, tableView: UITableView) {
        
        let alertController = UIAlertController(title: nil, message: "\(createdListArrayReversed[indexPath.row].date!)", preferredStyle: .actionSheet)
        
        //View:
        let viewAction = UIAlertAction(title: "View", style: .default) { (view) in
            
            guard let viewItemsVC = self.storyboard?.instantiateViewController(withIdentifier: "viewItemsVC") as? ViewItemsVC else {return}
            let set = self.createdListArrayReversed[indexPath.row].items
            if let itemsArr = set?.allObjects as? [Items] {
                viewItemsVC.initData(itemsArray: itemsArr, createdDate: self.createdListArrayReversed[indexPath.row].date!)
                self.present(viewItemsVC, animated: true, completion: nil)
            } else {
                print("Error in view.")
            }
        }
        
        //More:
        
        let moreAction = UIAlertAction(title: "More", style: .default) { (moreButton) in
            
            let moreAlertVC = UIAlertController(title: nil, message: "\(self.createdListArrayReversed[indexPath.row].date!)", preferredStyle: .actionSheet)
            
            //Edit Total:
            let editTotalAction = UIAlertAction(title: "Edit Total", style: .default) { (editTotal) in
                
                let alert = UIAlertController(title: "Edit Total:", message: "", preferredStyle: UIAlertControllerStyle.alert)
                
                let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (alertAction) in
                    let textField = alert.textFields![0] as UITextField
                    if textField.text != "" {
                        if let totalPriceInDouble = Double(textField.text!) {
                            
                            let roundedDoubleValue = totalPriceInDouble.round(to: 2)
                            
                            self.editTotalPrice(indexPath: indexPath, totalPrice: roundedDoubleValue)
                            self.homeTableView.reloadData()
                            self.calculateTotalAmount()
                        }
                    }
                })
                
                alert.addTextField { (textField : UITextField!) -> Void in
                    self.customView(oftextField: textField, buttonPressed: "editTotal")
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
            
            //Edit Title:
            let editTitleAction = UIAlertAction(title: "Edit Title", style: .default) { (editTitle) in
                let alert = UIAlertController(title: "Edit Title:", message: "", preferredStyle: .alert)
                
                let saveAction = UIAlertAction(title: "Save", style: .default, handler: { (alertAction) in
                    let textField = alert.textFields![0] as UITextField
                    if textField.text != "" {
                        
                        self.editTitle(ofindexPath: indexPath, withTitle: textField.text!)
                        self.homeTableView.reloadData()
                        
                    }
                })
                
                alert.addTextField { (textField : UITextField!) -> Void in
                    self.customView(oftextField: textField, buttonPressed: "editTitle")
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                alert.addAction(saveAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            moreAlertVC.addAction(editTotalAction)
            moreAlertVC.addAction(editTitleAction)
            moreAlertVC.addAction(cancelAction)
            
            self.present(moreAlertVC, animated: true, completion: nil)
        }
        
        //Delete:
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (deleteRow) in
            
            self.deleteCreatedList(indexPath: indexPath, completion: {(deleted) in
                if deleted {
                    self.fetchData(completion: { (fetched) in
                        if fetched {
                            tableView.deleteRows(at: [indexPath], with: .fade)
                            self.homeTableView.reloadData()
                            if self.createdListArrayReversed.isEmpty {
                                self.homeTableView.isHidden = true
                                self.calculateTotalAmount()
                                self.informationStackView.isHidden = false
                            }
                        }
                    })
                }
            })
        }
        
        //Cancel:
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(viewAction)
        alertController.addAction(moreAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    //Custom View for alert Text Field.
    private func customView(oftextField textField: UITextField, buttonPressed title: String) {
        
        switch title  {
            
        case "editTotal":
            textField.keyboardType = UIKeyboardType.decimalPad
            textField.leftViewMode = .always
            let placeholderImageView = UIImageView(frame: CGRect(x: 3, y: 0, width: 15, height: 15))
            placeholderImageView.image = UIImage(named:"dollar")
            let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 23, height: 18))
            placeholderView.addSubview(placeholderImageView)
            textField.leftView = placeholderView
            textField.placeholder = "22.46"
            
        case "editTitle":
            textField.keyboardType = UIKeyboardType.default
            textField.leftViewMode = .always
            textField.placeholder = "ThanksGiving Day"
            let placeholderView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
            textField.leftView = placeholderView
            
        default:
            break
        }
        
    }
}











