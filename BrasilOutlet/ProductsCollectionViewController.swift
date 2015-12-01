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

class ProductsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ProductsCollectionViewCellDelegate, APIProtocol {
    
    @IBOutlet var myCollectionView: UICollectionView!
    
    var subCategory:String = ""
    var storeId = 0
    var request: Alamofire.Request?
    var viewControllerDelegate : ViewControllerProtocol?
    var MyAPI = API()
    var tableData = []
    var tableImages = ["sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg"]
    var productModelList: NSMutableArray = []
    
    private var str : String?
    
    func didReceiveResult(result: JSON) {
        self.hideHUD()
        
        let products: NSMutableArray = []        
        NSLog("Product.didReceiveResult: \(result)")
        
        for (index,subJson):(String, JSON) in result {
            let product = ProductModel()
            
            //TODO: Should we hide the product if ACTIVATED=TRUE?
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
    
    func didErrorHappened(error: NSError) {
        self.hideHUD()
        let alert = UIAlertController(title: "Erro", message: "Há um problema na conexão com o BrasilOutlet. Tente novamente mais tarde (1011).", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)
        
        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""
        
        self.showHUD()
        print("Chamando api request com storeid: \(storeId)")
        MyAPI.post("/webservice/discount/discountlist.php", parameters: [
            "idcity" : actualCity,
            "cat" : subCategory,
            "storeid" : storeId,
            "page" : "0"
            ], delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(true)
    }
    
    func loadList(notification: NSNotification){
        
        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""
        self.showHUD()
        print("Chamando api request com storeid: \(storeId)")
        MyAPI.post("/webservice/discount/discountlist.php", parameters: [
            "idcity" : actualCity,
            "cat" : subCategory,
            "storeid" : storeId,
            "page" : "0"
            ], delegate: self)
        
        self.myCollectionView.reloadData()
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
            cell.productActualPrice.text = "R$\(productArray.discountPrice)"
            cell.productDescription.text = productArray.description
            cell.productOriginalPrice.text = "R$\(productArray.fullPrice)"
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
    
    func cellShareButtonTapped(cell: ProductsCollectionViewCell) {
        let indexPath = myCollectionView.indexPathForCell(cell)!
        let productToShare = productModelList[indexPath.row] as! ProductModel
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        shareToFacebook.setInitialText(productToShare.description)
        let productURL = NSURL(string: productToShare.image)
        shareToFacebook.addURL(productURL)
        
        //loading images from URLs Asyncronously
        let imageURL = (productToShare.image)
        self.request?.cancel()
        self.request = Alamofire.request(.GET, imageURL).responseImage() {
            [weak self] response in
            if let image = response.result.value {
                shareToFacebook.addImage(image)
            }
        }

        self.presentViewController(shareToFacebook, animated: true, completion: nil)
    }

    
    func cellLikeButtonTapped(cell: ProductsCollectionViewCell) {
        let indexPath = myCollectionView.indexPathForCell(cell)!
        let productToLike = productModelList[indexPath.row] as! ProductModel
        let responseGeneric = ResponseModel()
        let likeURL = "http://www.brasiloutlet.com/webservice/discount/like.php?discountid=\(productToLike.id)&type=PUT"
        let parameters = ["discountid" : productToLike.id, "type": "PUT"]
        
        print("LIKE button before request - product to like: \(productToLike.id)")
        print(likeURL)
        
        cell.request = Alamofire.request(.POST, likeURL, parameters: parameters as! [String : AnyObject]).responseJSON { response in
            switch response.result {
            case .Success:
                let json = JSON(response.result.value!)
                responseGeneric.obj = json["obj"].stringValue
                responseGeneric.sucess = json["sucess"].boolValue
                responseGeneric.msg = json["msg"].stringValue
                NSLog("POST do LIKE Result: \(json)")
                
                if (responseGeneric.sucess){
                    cell.productLikeButton.tintColor = UIColor.blueColor()
                    let likeImage = cell.productLikeButton.imageForState(UIControlState.Normal)
                    let likeBlueImage = likeImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                    cell.productLikeButton.setImage(likeBlueImage, forState: UIControlState.Normal)
                    cell.tintColor = UIColor.blueColor()
                    
                } else {
                    print("LIKE: deu errado")
                }
                
            case .Failure(let error):
                print("POST Error \(error)")
            }
        }
        
    }


//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print("selecionou uma celula!")
//    }
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        print("entrou prepare for segue")
        var indexPaths = self.myCollectionView.indexPathsForSelectedItems()
        if(segue.identifier == "productDetailView"){
            let vc = segue.destinationViewController as! ProductDetailTableViewController
            let selectedCell = myCollectionView.cellForItemAtIndexPath(indexPaths![0]) as! ProductsCollectionViewCell
            vc.collectionViewCell = selectedCell
            let indexPath = myCollectionView.indexPathForCell(selectedCell)!
            let selectedProduct = productModelList[indexPath.row] as! ProductModel
            vc.selectedProductData = selectedProduct
            print("Segue identifier eh productDetailView")
        }
    }

    
    
    @IBAction func chooseCity(sender: UIButton){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("ChooseCityViewControllerID")
        viewController.modalPresentationStyle = .Popover
        viewController.preferredContentSize = CGSizeMake(320, 261)
        let popoverPresentationViewController = viewController.popoverPresentationController
        popoverPresentationViewController?.permittedArrowDirections = .Any
        //        popoverPresentationViewController?.delegate = self
        popoverPresentationController?.sourceRect = sender.frame
        presentViewController(viewController, animated: true, completion: nil)
    }

    
}
