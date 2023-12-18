//
//  ContainerTableViewCell.swift
//  MealTracker
//
//  Created by Heinrich Enslin on 3/14/20.
//  Copyright © 2020 Heinrich Enslin. All rights reserved.
//

import UIKit

class ContainerTableViewCell: UITableViewCell {

    @IBOutlet weak var IDLabel: UILabel!
    @IBOutlet weak var TypeLabel: UILabel!
    @IBOutlet weak var FilledLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
