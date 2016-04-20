//
//  StoreTableViewCell.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 11/17/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire

class StoreTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    @IBOutlet var storeImage: UIImageView!

    var request: Alamofire.Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
