//
//  StorageService.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/16/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation
import Firebase

let STORAGE_REF = Storage.storage().reference()

class StorageService {
    
    static let instance = StorageService()
    
    private let _REF_PROFILEIMAGE = STORAGE_REF.child("profileImage")
    
    var REF_PROFILEIMAGE: StorageReference {
        return _REF_PROFILEIMAGE
    }
    
    //UPLOAD IMAGES TO FIREBASE STORAGE:
    func uploadImageToFirebaseStorage(imageData: Data, completion: @escaping (_ metaData: StorageMetadata?, _ error: Error?) -> ()) {
        
        let imageReference = REF_PROFILEIMAGE.child((Auth.auth().currentUser?.uid)!)
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        imageReference.putData(imageData, metadata: uploadMetaData) { (metaData, error) in
            if error != nil {
                completion(nil, error)
            } else {
                completion(metaData, nil)
            }
        }
    }
    
    //DOWNLOAD IMAGES FROM FIREBASE STORAGE:
    func downloadImagesFromStorage(ofUID id: String, completion: @escaping (_ url: URL?, _ error: Error?) -> () ) {
        
        let imageReference = REF_PROFILEIMAGE.child(id)
        imageReference.downloadURL { (downloadURL, downloadError) in
            if downloadError != nil {
                completion(nil, downloadError)
            } else {
                completion(downloadURL, nil)
            }
            
        }
        
        
    }
    
    //DELETE IMAGES FROM FIREBASE STORAGE:
    func deleteImageFromStorage(ofUID id: String, completion: @escaping (_ sender: Bool, _ error: Error?) -> ()) {
        
        let imageReference = REF_PROFILEIMAGE.child(id)
        imageReference.delete { (deletionError) in
            if deletionError != nil {
                completion(false, deletionError)
            } else {
                completion(true, nil)
            }
        }
        
        
    }
    
    
}











