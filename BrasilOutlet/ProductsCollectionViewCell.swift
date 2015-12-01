//
//  ProductsCollectionViewCell.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/26/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire

protocol ProductsCollectionViewCellDelegate {
    func cellShareButtonTapped(cell: ProductsCollectionViewCell)
    func cellLikeButtonTapped(cell: ProductsCollectionViewCell)
}

class ProductsCollectionViewCell: UICollectionViewCell {
    
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
    
    var delegate: ProductsCollectionViewCellDelegate?
    
    @IBAction func shareProduct(sender: UIButton) {
        
        delegate?.cellShareButtonTapped(self)
        
    }
    
    @IBAction func likeProduct(sender: UIButton) {
        
        delegate?.cellLikeButtonTapped(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // The Favorite/Heart button is hidden while the User Login is not implemented.
        self.productHeartButton.hidden = true
        self.productLikeButton.hidden = true
    }
    
}
