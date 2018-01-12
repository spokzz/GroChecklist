//
//  SettingsVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

class MoreVC: UIViewController {

    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var monthTotalAmountLabel: UILabel!
    @IBOutlet weak var profileImageView: customUIImageView!
    
    var settingsTitle: [String] = ["My Members","Add Members","Edit Photo", "See Tutorial"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moreTableView.delegate = self
        moreTableView.dataSource = self
    }

    //SIGN OUT BUTTON PRESSED:
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        DataService.instance.signOut { (successful, error) in
            if successful {
                print("Sign Out successful")
            } else {
                print("Error in signout: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    //ADD ACTION FOR SELECTED ROW AT TABLE VIEW:
    func addAction(forIndexPath index: IndexPath) {
        
        switch index.row {
        case 0:
            //.. Show added Members.
            print("0")
        case 1:
            //...Allow to add Members.
            print("1")
        case 2:
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.delegate = self
            
            present(imagePicker, animated: true, completion: nil)
        case 3:
            //... Show Tutorial of Apps.
            print("3")
        default:
            return
        }
        
    }
    
    
    
}

//TABLE VIEW:
extension MoreVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath) as? MoreCell else {return UITableViewCell()}
        cell.configureCell(withTitle: settingsTitle[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addAction(forIndexPath: indexPath)
    }
    
    
}

extension MoreVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        profileImageView.image = pickedImage
        
        dismiss(animated: true, completion: nil)
    }
    
    
}















