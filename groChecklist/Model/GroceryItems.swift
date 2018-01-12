//
//  GroceryItems.swift
//  groChecklist
//
//  Created by Sakar Pokhrel on 1/8/18.
//  Copyright © 2018 Sakar Pokhrel. All rights reserved.
//

import Foundation

class GroceryItem {
    
    private var _itemTitle: String
    private var _numberOfItems: String
    private var _checked: Bool
    private var _groceryKey: String?
    
    var itemTitle: String {
        return _itemTitle
    }
    
    var numberOfItems: String {
        return _numberOfItems
    }
    
    var checked: Bool {
        return _checked
    }
    
    var groceryKey: String {
        return _groceryKey!
    }
    
    init(itemTitle: String, numberOfItems: String, checked: Bool, groceryKey: String?) {
        self._itemTitle = itemTitle
        self._numberOfItems = numberOfItems
        self._checked = checked
        self._groceryKey = groceryKey
    }
    
}
