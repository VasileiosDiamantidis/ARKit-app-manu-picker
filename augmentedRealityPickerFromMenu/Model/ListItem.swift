//
//  ListItem.swift
//  augmentedRealityPickerFromMenu
//
//  Created by Vasileios Diamantidis on 15/02/2018.
//  Copyright © 2018 vdiamant. All rights reserved.
//

import Foundation
import UIKit

class ListItem{
    var title:String!
    var image:UIImage!
    var price:Int!
    var threeDString:String!
    
    
    init(name: String, image: UIImage,  price: Int, ThreeDString: String){
        self.title = name
        self.image = image
        self.price = price
        self.threeDString = ThreeDString
    }
    
    
}
