//
//  CategoryItem.swift
//  augmentedRealityPickerFromMenu
//
//  Created by Vasileios Diamantidis on 15/02/2018.
//  Copyright © 2018 vdiamant. All rights reserved.
//

import Foundation
import UIKit

class CategoryItem{
    var categoryTitle:String!
    var categoryImage:UIImage!
    var categoryChildList:[ListItem]
    
    init(categoryName: String, CategoryImage: UIImage, List: [ListItem]){
        self.categoryTitle = categoryName
        self.categoryImage = CategoryImage
        self.categoryChildList = List
    }
    
    
}
