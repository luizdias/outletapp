//
//  CategoriesTableViewCell.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 11/2/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire

class CategoriesTableViewCell: UITableViewCell {
    
    var request: Alamofire.Request?
    @IBOutlet var leftImage: UIImageView!
    @IBOutlet var categoryDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
