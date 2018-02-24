//
//  UIImageViewExt.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/21/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func loadImageUsingCache(withUrlString urlString: String) {
        
        self.image = nil
        
        //Check cache for image first:
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //New Download:
        let url = URL(string: urlString)
        ImageDownloadService.instance.downloadImages(withUrl: url!) { (imageData) in
            
             DispatchQueue.main.async {
            if let downloadedImage = UIImage(data: imageData) {
                imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                self.image = downloadedImage
            }
                
            }
            
        }
        
    }
    
    
    
}
