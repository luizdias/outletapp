//
//  TopDiscountsCollectionCollectionViewController.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/26/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Social

class TopDiscountsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ProductsCellDelegate, APIProtocol {
    
    @IBOutlet var myCollectionView: UICollectionView!
    
    private var str : String?
    var request: Alamofire.Request?
    var viewControllerDelegate : ViewControllerProtocol?
    var MyAPI = API()
    var tableData = ["Um", "Dois", "Tres", "Quatro", "Cinco", "Seis", "Sete", "Oito"]
    var tableImages = ["sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg"]
    var productModelList: NSMutableArray = []
    
    func didReceiveResult(result: JSON) {
        self.hideHUD()
        
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
        
        self.showHUD()
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
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as! ProductsCollectionViewCell
        
        cell.delegate = self
        if productModelList.count != 0{
            let productArray = productModelList[indexPath.row] as! ProductModel
            cell.productActualPrice.text = productArray.discountPrice
            cell.productDescription.text = productArray.description
            cell.productOriginalPrice.text = productArray.fullPrice
            cell.productDiscountValue.titleLabel?.text = "\(productArray.discountPercent)%"
            cell.productDiscountDates.text = ("Promoção válida de: \n" + "\(productArray.startDate) até \(productArray.endDate)")
            
            //loading images from URLs Asyncronously
            let imageURL = (productArray.image)
            cell.productImage.image = nil
            cell.request?.cancel()
            cell.request = Alamofire.request(.GET, imageURL).responseImage() {
                [weak self] response in
                if let image = response.result.value {
                    cell.productImage.contentMode = UIViewContentMode.ScaleAspectFit
                    cell.productImage.image = image
                }
            }
        }
        return cell
    }
    
    func cellButtonTapped(cell: ProductsCollectionViewCell) {
        let indexPath = myCollectionView.indexPathForCell(cell)!
        let productArray = productModelList[indexPath.row] as! ProductModel
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        shareToFacebook.setInitialText(productArray.description)
        let productURL = NSURL(string: productArray.image)
        shareToFacebook.addURL(productURL)
        
        //loading images from URLs Asyncronously
        let imageURL = (productArray.image)
        self.request?.cancel()
        self.request = Alamofire.request(.GET, imageURL).responseImage() {
            [weak self] response in
            if let image = response.result.value {
                shareToFacebook.addImage(image)
            }
        }
        self.presentViewController(shareToFacebook, animated: true, completion: nil)
    }
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selecionou uma celula!")
        self.performSegueWithIdentifier("productDetailView", sender: indexPath)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier == "productDetailView"){
                let vc = segue.destinationViewController as! ProductDetailTableViewController
                vc.productModelList = self.productModelList
            }
        }
        
}
