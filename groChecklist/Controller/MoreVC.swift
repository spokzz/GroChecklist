//
//  SettingsVC.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/7/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import AlamofireImage

class MoreVC: UIViewController {

    @IBOutlet weak var moreTableView: UITableView!
    @IBOutlet weak var monthTotalAmountLabel: UILabel!
    @IBOutlet weak var profileImageView: customUIImageView!
    @IBOutlet weak var userEmailLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var topGradientViewHeight: NSLayoutConstraint!
    
    private var settingsTitle: [String] = ["My Members","Add Members","Edit Photo", "Watch Tutorial"]
    private let userImageKey = "userImage"
    
    let application = UIApplication.shared
    
    //VIEW DID LOAD:
    override func viewDidLoad() {
        super.viewDidLoad()
        
        topGradientViewHeight.editMoreVCColorGradientHeight()
        moreTableView.delegate = self
        moreTableView.dataSource = self
        
    }

    //VIEW WILL APPEAR:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        application.statusBarStyle = .lightContent
        checkUserPresence()
        if let totalAmount = coreDataTotalAmount {
            monthTotalAmountLabel.text = "$\(totalAmount)"
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        application.statusBarStyle = .default
    }
    
    //IF USER IS THERE:
    func checkUserPresence() {
        
        if Auth.auth().currentUser?.uid == nil {
            logInButton.isHidden = false
            profileImageView.image = UIImage(named: "userImage")
            
        } else {
            
                DataService.instance.getUser(withUID: (Auth.auth().currentUser?.uid)!, completion: { (returnedUsers) in
                    if returnedUsers.profileImageURL != nil {
                            self.profileImageView.loadImageUsingCache(withUrlString: returnedUsers.profileImageURL!)
                        
                    } else {
                        self.profileImageView.image = UIImage(named: "userImage")
                    }
                })
            
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
                profileImageView.image = UIImage(named: "userImage")
                logInButton.isHidden = false
            } else {
                print("Error in signout: \(String(describing: error?.localizedDescription))")
            }
        }
    }
    
    //ADD ACTION FOR SELECTED ROW AT TABLE VIEW:
    private func addAction(forIndexPath index: IndexPath) {
        
        switch index.row {
            
            //My Members
        case 0:
            guard let myMembersVC = storyboard?.instantiateViewController(withIdentifier: "myMembersVC") else {return}
            present(myMembersVC, animated: true, completion: nil)
            
            //Add Members
        case 1:
            guard let searchUserVC = storyboard?.instantiateViewController(withIdentifier: "addUsersVC") else {return}
           present(searchUserVC, animated: true, completion: nil)
    
            //Edit Photo
        case 2:
            
            if Auth.auth().currentUser?.uid != nil {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = true
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                present(imagePicker, animated: true, completion: nil)
            } else {
                
                let alertVC = UIAlertController(title: nil, message: "You must login to change your profile picture.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertVC.addAction(action)
                present(alertVC, animated: true, completion: nil)
                
            }
            
            //Watch Tutorial
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

//UIImagePickerDelegate:
extension MoreVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage, let imageData = UIImagePNGRepresentation(pickedImage) {
            
            //BACKGROUND THREAD:
            DispatchQueue.global(qos: .userInteractive).async {
                
                StorageService.instance.uploadImageToFirebaseStorage(imageData: imageData, completion: { (metaData, error) in
                    if error != nil {
                        print("Image Upload Error: \(String(describing: error?.localizedDescription))")
                    } else {
                        StorageService.instance.downloadImagesFromStorage(ofUID: (Auth.auth().currentUser?.uid)!, completion: { (url, error) in
                            if error != nil {
                                print("Download Error: \(error?.localizedDescription)")
                            } else {
                                if let profileImageURl = url?.absoluteString {
                                  DataService.instance.addImageInUserDB(withprofileImageURL: profileImageURl)
                                }
                            }
                        })
                        
                    }
                })
        }
    }
       dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    
}
















