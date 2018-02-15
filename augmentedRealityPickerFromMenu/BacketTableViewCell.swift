//
//  BacketTableViewCell.swift
//  augmentedRealityPickerFromMenu
//
//  Created by Vasileios Diamantidis on 15/02/2018.
//  Copyright © 2018 vdiamant. All rights reserved.
//

import UIKit

class BacketTableViewCell: UITableViewCell {

    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemCost: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
