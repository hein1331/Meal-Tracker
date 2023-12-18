//
//  SpiceTableViewCell.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 1/19/22.
//  Copyright © 2022 Heinrich Enslin. All rights reserved.
//

import UIKit

class SpiceTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var SpiceNameLabel: UILabel!
    @IBOutlet weak var SpiceStatusLabel: UILabel!
    var spice: Spice? = nil

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
