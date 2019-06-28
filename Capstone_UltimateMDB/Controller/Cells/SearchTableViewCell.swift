//
//  SearchTableViewCell.swift
//  Capstone_UltimateMDB
//
//  Created by Giordany Orellana on 6/18/19.
//  Copyright © 2019 Giordany Orellana. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {
    

    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieLabel: UILabel!
    @IBOutlet weak var movieYearLabel: UILabel!
    @IBOutlet weak var movieDescription: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
