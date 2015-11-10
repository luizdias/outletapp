//
//  ProductDetailTableViewCell.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 11/9/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire

protocol ProductDetailTableViewCellDelegate {
    func cellTapped(cell: ProductDetailTableViewCell)
}

class ProductDetailTableViewCell: UITableViewCell {
    
    var request: Alamofire.Request?

    @IBOutlet var productDescription: UILabel!
    @IBOutlet var productDiscountValue: UIButton!
    @IBOutlet var productActualPrice: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productHeartButton: UIButton!
    @IBOutlet var productOriginalPrice: UILabel!
    @IBOutlet var productLikeButton: UIButton!
    @IBOutlet var productShareButton: UIButton!
    @IBOutlet var productDiscountDates: UILabel!
    
    @IBAction func favoriteProduct(sender: UIButton) {

    }
    
//    var delegate: ProductsCellDelegate?
    
    @IBAction func shareProduct(sender: UIButton) {
        
//        delegate?.cellTapped(self)
        
    }
    
    @IBAction func likeProduct(sender: UIButton) {
        
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // The Favorite/Heart button is hidden while the User Login is not implemented.
        self.productHeartButton.hidden = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
}
