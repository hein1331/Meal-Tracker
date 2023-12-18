//
//  MealTableViewCell.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/16/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit

class MealTableViewCell: UITableViewCell {

    @IBOutlet weak var NameLabel: UILabel!
    @IBOutlet weak var CalorieLabel: UILabel!
    @IBOutlet weak var CountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
