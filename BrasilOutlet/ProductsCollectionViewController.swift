//
//  ProductsCollectionViewController.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/26/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProductsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, APIProtocol {
    
    @IBOutlet var myCollectionView: UICollectionView!
    
    var viewControllerDelegate : ViewControllerProtocol?
    private var str : String?
    
    var MyAPI = API()
    var tableData = ["Um", "Dois", "Tres", "Quatro", "Cinco", "Seis", "Sete", "Oito"]
    var tableImages = ["sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg"]
    
    var productModelList: NSMutableArray = []
    
    func didReceiveResult(result: JSON) {
        let products: NSMutableArray = []
        
        NSLog("Product.didReceiveResult: \(result)")
        
        for (index,subJson):(String, JSON) in result {
            let product = ProductModel()
            product.activated = subJson["activated"].intValue
            product.description = subJson["description"].stringValue
            product.discountPercent = subJson["discountPercent"].intValue
            product.discountPrice = subJson["discountPrice"].stringValue
            product.fullPrice = subJson["fullPrice"].stringValue
            product.id = subJson["id"].intValue
            product.image = subJson["image"].stringValue
            product.startDate = subJson["startDate"].stringValue
            product.title = subJson["title"].stringValue
            print("URL da imagem: \(product.image)")
            products.addObject(product)
            print("\(products.description) e indice: \(index)")
        }
        
        productModelList = products
        
        print("Quantidade de itens after: \(productModelList.count)")
        print("Trying to reload data after the response...")
        
        // Make sure we are on the main thread, and update the UI.
        dispatch_async(dispatch_get_main_queue(), {
            self.myCollectionView.collectionViewLayout.invalidateLayout()
            self.myCollectionView.reloadData()
            self.myCollectionView.reloadSections(NSIndexSet.init(index: 0))
            print("dispatch main queue here!")
        
        })
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyAPI.post("/webservice/discount/topdiscounts.php", parameters: [ "idcity" : "7"  ], delegate: self)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(true)
    }

    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Quantidade de itens na sessao: \(productModelList.count)")

        if productModelList.count != 0{
            return productModelList.count
        } else {
            return tableData.count
        }

    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ProductsCollectionViewCell

        if productModelList.count != 0{
            let productArray = productModelList[indexPath.row] as! ProductModel
            cell.productActualPrice.text = productArray.discountPrice
            cell.productDescription.text = productArray.description
            cell.productOriginalPrice.text = productArray.fullPrice
            cell.productDiscountDates.text = ("Promoção válida de: \n" + "\(productArray.startDate) até \(productArray.endDate)")
            
            //loading image from URL Synchronously:
//            if let url = NSURL(string: productArray.image) {
//                if let data = NSData(contentsOfURL: url){
//                    cell.productImage.contentMode = UIViewContentMode.ScaleAspectFit
//                    cell.productImage.image = UIImage(data: data)
//                }
//            }

            //loading images from URLs Asyncronously
            let imageURL = (productArray.image)
            cell.productImage.image = nil
            cell.request?.cancel()
            cell.request = Alamofire.request(.GET, imageURL).responseImage() {
                [weak self] response in
                if let image = response.result.value {
                    cell.productImage.image = image
                }
            }
        }
        return cell
    }


    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selecionou uma celula!")
    }
    
}
