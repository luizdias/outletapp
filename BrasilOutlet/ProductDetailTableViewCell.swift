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
    func cellShareButtonTapped(cell: ProductDetailTableViewCell)
    func cellLikeButtonTapped(cell: ProductDetailTableViewCell)
    func cellMailButtonTapped(cell: ProductDetailTableViewCell)
    func cellPhoneButtonTapped(cell: ProductDetailTableViewCell)
}

class ProductDetailTableViewCell: UITableViewCell {
    
    var request: Alamofire.Request?
    var url = String()
    var telephone = String()
    var email = String()

    @IBOutlet var productDescription: UILabel!
    @IBOutlet var productDiscountValue: UIButton!
    @IBOutlet var productActualPrice: UILabel!
    @IBOutlet var productImage: UIImageView!
    @IBOutlet var productHeartButton: UIButton!
    @IBOutlet var productOriginalPrice: UILabel!
    @IBOutlet var productLikeButton: UIButton!
    @IBOutlet var productShareButton: UIButton!
    @IBOutlet var productDiscountDates: UILabel!
    @IBOutlet var productLongDescription: UILabel!
    @IBOutlet var storeDetails: UILabel!
    @IBOutlet weak var callStoreButton: UIButton!
    @IBOutlet weak var sendEmailToStoreButton: UIButton!
    
    @IBAction func favoriteProduct(sender: UIButton) {

    }
    

    var delegate: ProductDetailTableViewCellDelegate?
    
    @IBAction func shareProduct(sender: UIButton) {
        
        delegate?.cellShareButtonTapped(self)
        
    }
    
    @IBAction func likeProduct(sender: UIButton) {
        
        delegate?.cellLikeButtonTapped(self)
        
    }

    @IBAction func callStore(sender: UIButton) {

        delegate?.cellPhoneButtonTapped(self)
        
    }

    @IBAction func mailStore(sender: UIButton) {

        delegate?.cellMailButtonTapped(self)
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // The Favorite/Heart button is hidden while the User Login is not implemented.
        self.productHeartButton.hidden = true
        self.productLikeButton.hidden = true

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    
}
