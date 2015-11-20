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

class TopDiscountsCollectionViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, ProductsCollectionViewCellDelegate, APIProtocol {
    
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

            product.store.id = subJson["store"]["id"].intValue
            product.store.name = subJson["store"]["name"].stringValue
            product.store.socialName = subJson["store"]["socialName"].stringValue
            product.store.cnpj = subJson["store"]["cnpj"].stringValue
            product.store.address = subJson["store"]["address"].stringValue
            product.store.latCoordinate = subJson["store"]["latCoordinate"].stringValue
            product.store.longCoordinate = subJson["store"]["longCoordinate"].stringValue
            product.store.cityId = subJson["store"]["cityId"].intValue
            product.store.favorite = subJson["store"]["favorite"].stringValue
            product.store.neighborName = subJson["store"]["neighborName"].stringValue
            product.store.neighborId = subJson["store"]["neighborId"].intValue
            product.store.shoppingId = subJson["store"]["shoppingId"].intValue
            product.store.shoppingName = subJson["store"]["shoppingName"].stringValue
            product.store.telephone1 = subJson["store"]["telephone1"].stringValue
            product.store.telephone2 = subJson["store"]["telephone2"].stringValue
            product.store.subscriptionDiscountsLimit = subJson["store"]["subscriptionDiscountsLimit"].stringValue
            product.store.subscriptionExpirationDate = subJson["store"]["subscriptionExpirationDate"].stringValue
            product.store.subscriptionPlan = subJson["store"]["subscriptionPlan"].stringValue
            
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
    
    override func viewWillAppear(animated: Bool) {}
    
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
            print("retornou uma celula com conteúdo da requisicao")
            let productArray = productModelList[indexPath.row] as! ProductModel
            cell.productActualPrice.text = "R$\(productArray.discountPrice)"
            cell.productDescription.text = productArray.description
            cell.productOriginalPrice.text = "R$\(productArray.fullPrice)"
            cell.productDiscountValue.setTitle("\(productArray.discountPercent)%", forState: UIControlState.Normal)
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
                    print("response de uma imagem")
                }
            }
            
            cell.productLikeButton.tag = indexPath.item
//            cell.productLikeButton.addTarget(self, action: "like:", forControlEvents: UIControlEvents.TouchUpInside)

            
        } else {
            print("retornou célula padrão.")
        }
        return cell
    }
    
    func cellShareButtonTapped(cell: ProductsCollectionViewCell) {
        let indexPath = myCollectionView.indexPathForCell(cell)!
        let productToShare = productModelList[indexPath.row] as! ProductModel
        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        let productURL = NSURL(string: productToShare.image)
        shareToFacebook.setInitialText(productToShare.description)
        shareToFacebook.addURL(productURL)

        //loading images from URLs Asyncronously
        let imageURL = (productToShare.image)
        self.request?.cancel()
        self.request = Alamofire.request(.GET, imageURL).responseImage() {
            [weak self] response in
            if let image = response.result.value {
                shareToFacebook.addImage(cell.productImage.image)
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
}
