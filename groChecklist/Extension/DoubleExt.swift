//
//  DoubleExt.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/22/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation

extension Double {
    
    //It rounds the double numbers.
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return Darwin.round(self * divisor) / divisor
    }
    
    
}
