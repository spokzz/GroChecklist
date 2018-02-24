//
//  ImageDownloadService.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/20/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage

class ImageDownloadService {
    
    static let instance = ImageDownloadService()
    
    //RETURNS THE IMAGE DATA:
    func downloadImages(withUrl url: URL, completion: @escaping (_ imageData: Data) -> ()) {
        
            Alamofire.request(url).responseImage { (imageResponse) in
                if imageResponse.result.isSuccess {
                    
                    if let imageDownloaded = imageResponse.result.value {
                        guard let imageDownloadedData = UIImagePNGRepresentation(imageDownloaded) else {return}
                        completion(imageDownloadedData)
                    }
                }
        }
        }
    
    //REMOVE ALL THE NETWORKING SESSIONS:
    func removeSession() {
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (dataTask, uploadData, downloadData) in
            dataTask.forEach({$0.cancel()})
            downloadData.forEach({$0.cancel()})
        }
    }
    
    
}
