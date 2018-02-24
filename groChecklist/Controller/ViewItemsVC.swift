//
//  ViewItemsVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/5/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class ViewItemsVC: UIViewController {

    @IBOutlet weak var topViewLabel: UILabel!
    @IBOutlet weak var itemTableView: UITableView!
    
    private var itemsArray: [Items]!
    private var createdDate: String!
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTableView.delegate = self
        itemTableView.dataSource = self
    }
    
    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topViewLabel.text = createdDate
    }
    
    //TAKES DATA FROM OTHER VIEW CONTROLLER:
    func initData(itemsArray: [Items], createdDate: String) {
        self.itemsArray = itemsArray
        self.createdDate = createdDate
    }

    //CLOSE BUTTON PRESSED:
    @IBAction func closeButtonPressed(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    

}

//TABLE VIEW:
extension ViewItemsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(withIdentifier: "viewItemsCell", for: indexPath) as? ViewItemsCell else {return UITableViewCell()}
        cell.confugureCell(items: itemsArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ViewItemsCell else {return}
        saveData(indexPath: indexPath) { (showing) in
            if showing {
                cell.itemSelectedImage.isHidden = false
            } else {
                cell.itemSelectedImage.isHidden = true
            }
        }
    }
    
    
}

//CORE DATA:
extension ViewItemsVC {
    
   private func saveData(indexPath: IndexPath, showImage: @escaping (_ selected: Bool) -> ()){
        
        guard let managedContext = appDelegate?.persistentContainer.viewContext else {return}
        
         let items = itemsArray[indexPath.row]
        if items.checked == true {
           items.checked = false
            showImage(false)
        } else {
            items.checked = true
            showImage(true)
        }
    
        do {
            try managedContext.save()
        } catch {
            print("error in ViewItemsVC checked")
        }
    }
    
}
















