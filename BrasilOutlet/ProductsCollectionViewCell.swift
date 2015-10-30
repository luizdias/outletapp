//
//  ProductsCollectionViewCell.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/26/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire

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
        self.productHeartButton.tintColor = UIColor.redColor()
    }
    
    @IBAction func shareProduct(sender: UIButton) {
    }
    
    @IBAction func likeProduct(sender: UIButton) {
    }
    
}