//
//  SettingsVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase

class MoreVC: UIViewController {

    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var monthTotalAmountLabel: UILabel!
    @IBOutlet weak var profileImageView: customUIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    
    private var settingsTitle: [String] = ["My Members","Add Members","Edit Photo", "Watch Tutorial"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moreTableView.delegate = self
        moreTableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Auth.auth().currentUser?.uid == nil {
            logInButton.isHidden = false
        } else {
            logInButton.isHidden = true
        }
        userEmailLabel.text = Auth.auth().currentUser?.email ?? "user@grochecklist.com"
    }
    
    
    //UNWIND SEGUE:
    @IBAction func unwindToMoreVC(segue: UIStoryboardSegue) { }
    
    //SIGN OUT BUTTON PRESSED:
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        
        DataService.instance.signOut { (successful, error) in
            if successful {
                print("Sign Out successful")
                userEmailLabel.text = "user@grochecklist.com"
                logInButton.isHidden = false
            } else {
                print("Error in signout: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    //ADD ACTION FOR SELECTED ROW AT TABLE VIEW:
    private func addAction(forIndexPath index: IndexPath) {
        
        switch index.row {
        case 0:
            guard let myMembersVC = storyboard?.instantiateViewController(withIdentifier: "myMembersVC") else {return}
            present(myMembersVC, animated: true, completion: nil)
            
        case 1:
            guard let searchUserVC = storyboard?.instantiateViewController(withIdentifier: "addUsersVC") else {return}
           present(searchUserVC, animated: true, completion: nil)
    
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
    
    //LOGIN BUTTON PRESSED:
    @IBAction func logInButtonPressed(_ sender: UIButton) {
        
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "loginVC") else {return}
        present(loginVC, animated: true, completion: nil)
        
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
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage, let imageData = UIImagePNGRepresentation(pickedImage) {
            
        let profileImageData = imageData
         profileImageView.image = pickedImage
            
            //BACKGROUND THREAD:
            DispatchQueue.global(qos: .userInteractive).async {
                
                StorageService.instance.uploadImageToFirebaseStorage(imageData: profileImageData, completion: { (metaData, error) in
                    if error != nil {
                        print("Image Upload Error: \(String(describing: error?.localizedDescription))")
                    } else {
                        StorageService.instance.downloadImagesFromStorage(ofUID: (Auth.auth().currentUser?.uid)!, completion: { (url, error) in
                            if error != nil {
                                print("Download Error: \(error?.localizedDescription)")
                            } else {
                                print("URL: \(url)")
                            }
                        })
                    }
                })
                
        }
            
    }
       dismiss(animated: true, completion: nil)
    }

    
}

/*
 DispatchQueue.global(qos: .userInteractive).async {
 
 StorageService.instance.deleteImageFromStorage(ofUID: (Auth.auth().currentUser?.uid)!, completion: { (success, error) in
 if success {
 StorageService.instance.uploadImageToFirebaseStorage(imageData: self.profileImageData!, completion: { (uploaded, error) in
 if uploaded {
 print("Successfully uploaded.")
 } else {
 print("Image upload error: \(error?.localizedDescription)")
 }
 })
 
 } else {
 print("Error in deletion: \(error?.localizedDescription)")
 }
 })
 
 }
*/














