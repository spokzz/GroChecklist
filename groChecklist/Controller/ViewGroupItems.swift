//
//  ViewGroupItems.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/9/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class ViewGroupItems: UIViewController {

    @IBOutlet weak var groupItemsTableView: UITableView!
    @IBOutlet weak var dateTopLabel: UILabel!
    
    private var group: Groups!
    private var groceryItemsArray = [GroceryItem]()
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        groupItemsTableView.delegate = self
        groupItemsTableView.dataSource = self
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dateTopLabel.text = group.groupCreatedDate
        
        DataService.instance.REF_GROUPS.observe(.value) {(snapshot) in
            DataService.instance.getAllItems(forGroup: self.group, completion: { (returnedGroceryItemsArray) in
                self.groceryItemsArray = returnedGroceryItemsArray
                self.groupItemsTableView.reloadData()
            })
        }
        
    }
    
    //TAKES DATA FROM OTHER VC
    func initData(groupPressed: Groups) {
        self.group = groupPressed
        
    }

    //CLOSE BUTTON PRESSED:
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
    }
    
}

//TABLE VIEW
extension ViewGroupItems: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groceryItemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "viewGroupItemsCell", for: indexPath) as? ViewGroupItemsCell else {return UITableViewCell()}
        cell.configureCell(groupItems: groceryItemsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ViewGroupItemsCell else {return}
        
        //If checked image is Hidden:
        if cell.checkedImageView.isHidden == true {
            DataService.instance.changeSelectedImageValue(forGroup: group, andGroceryItem: groceryItemsArray[indexPath.row], itemsChecked: true, completion: { (success) in
                cell.checkedImageView.isHidden = false
            })
        }
            //If checked image is notHidden:
        else {
            DataService.instance.changeSelectedImageValue(forGroup: group, andGroceryItem: groceryItemsArray[indexPath.row], itemsChecked: false, completion: { (success) in
                cell.checkedImageView.isHidden = true
            })
        }
    }
    
    
    
}

























