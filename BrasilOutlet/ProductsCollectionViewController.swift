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
import Social

class ProductsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ProductsCellDelegate, APIProtocol {
    
    @IBOutlet var myCollectionView: UICollectionView!
    
    private var str : String?
    var viewControllerDelegate : ViewControllerProtocol?
    var MyAPI = API()
    var tableData = ["Um", "Dois", "Tres", "Quatro", "Cinco", "Seis", "Sete", "Oito"]
    var tableImages = ["sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg"]
    var productImages : [UIImage] = []
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

    var myIndexPath : NSIndexPath!

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ProductsCollectionViewCell

        cell.delegate = self
        myIndexPath = indexPath
        if productModelList.count != 0{
            let productArray = productModelList[indexPath.row] as! ProductModel
            cell.productActualPrice.text = productArray.discountPrice
            cell.productDescription.text = productArray.description
//            cell.productOriginalPrice.text = productArray.fullPrice
            cell.productDiscountValue.titleLabel?.text = "\(productArray.discountPercent)%"
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
                    cell.productImage.contentMode = UIViewContentMode.ScaleAspectFit
                    self?.productImages[indexPath.row] = image
                    cell.productImage.image = image
                }
            }
        }
        
//        var selectedItems = [String]()
//        func cellButtonTapped(cell: ProductsCollectionViewCell) {
//            let selectedItem = productModelList[indexPath.row]
//            
//            if let selectedItemIndex = selectedItems.indexOf(selectedItem as! String) {
//                selectedItems.removeAtIndex(selectedItemIndex)
//            } else {
//                selectedItems.append(selectedItem as! String)
//            }
//        }

        return cell
    }
    
    private var selectedItems = [String]()
    func cellButtonTapped(cell: ProductsCollectionViewCell) {
//        let indexPath = self.tableView.indexPathForRowAtPoint(cell.center)!
//        let indexPath = self.collectionView!.indexPathForCell(cell)
//        let indexPath = self.indexPathForCell(cell.center as UICollectionViewCell!)
        let selectedItem = productModelList[myIndexPath.row]
        
        if let selectedItemIndex = selectedItems.indexOf(selectedItem as! String) {
            selectedItems.removeAtIndex(selectedItemIndex)
        } else {
            selectedItems.append(selectedItem as! String)
        }
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        shareToFacebook.setInitialText("Veja este produto no Brasil Oulet")
        shareToFacebook.addImage(productImages[myIndexPath.row])
        let productURL = NSURL(string: "www")
        shareToFacebook.addURL(productURL)
        self.presentViewController(shareToFacebook, animated: true, completion: nil)
    }


    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selecionou uma celula!")
    }
    
}
