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
    var tableData = []
    var tableImages = ["sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg","sample-product.jpg"]
    var productModelList: NSMutableArray = []
    
    func didReceiveResult(result: JSON) {
        self.hideHUD()
        
        let products: NSMutableArray = []
//        NSLog("Product.didReceiveResult: \(result)")
        
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
        }
        
        productModelList = products
        
        print("Quantidade de itens after: \(productModelList.count)")
        print("Trying to reload data after the response...")
        
        // Make sure we are on the main thread, and update the UI.
        dispatch_async(dispatch_get_main_queue(), {
            self.myCollectionView.collectionViewLayout.invalidateLayout()
            self.myCollectionView.reloadData()
            //           self.myCollectionView.reloadSections(NSIndexSet.init(index: 0))
        })
    }
    

    func didErrorHappened(error: NSError) {
        self.hideHUD()
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        if let message = error.userInfo["message"]{
            print("\(message.description)")
            alert.title = "Oops! 😮"
            alert.message = message as? String
            productModelList = []
            self.myCollectionView.reloadData()
        }else {
            alert.title = "Erro"
            alert.message = "Há um problema na conexão com o BrasilOutlet. Tente novamente mais tarde (1011)."
        }
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkVersion()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)
        
        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""
        
        if actualCity != "" {
            self.showHUD()
            MyAPI.post("/webservice/discount/topdiscounts.php", parameters: [ "idcity" : actualCity  ], delegate: self)
        } else{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("ChooseCityViewControllerID")
            viewController.modalPresentationStyle = .Popover
            viewController.preferredContentSize = CGSizeMake(320, 261)
            let popoverPresentationViewController = viewController.popoverPresentationController
            popoverPresentationViewController?.permittedArrowDirections = .Any
            presentViewController(viewController, animated: true, completion: nil)
        }
    }
    
    func checkVersion(){

        enum VersionStatus {
            case Updated
            case AVAILABLE
            case Mandatory
        }
        
        var parameters = ["appversion": "1"]

        if let appVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            parameters.updateValue(appVersion, forKey: "appversion")
            print("Versão atual [ \(appVersion) ] da RELEASE.")
        }
        
        let url = "http://www.brasiloutlet.com/webservice/app/checkversion.php"
        Alamofire.request(.POST, url, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    let json = JSON(response.result.value!)
                    print("Validation Successful: \(json)")
                    if let actualVersion = json["update"].string {
                        switch actualVersion{
                        case "UPDATED":
                            break
                        case "AVAILABLE":
                            let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.title = "Novidades! 😎"
                            alert.message = "Há uma nova versão do Brasil Outlet disponível. Atualize já!"
                            
                            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                                let url  = NSURL(string: "itms-apps://itunes.apple.com/us/app/brasiloutlet/id1065711297?ls=1&mt=8")
                                if UIApplication.sharedApplication().canOpenURL(url!) == true  {
                                    UIApplication.sharedApplication().openURL(url!)
                                }
                            }
                            
                            alert.addAction(OKAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                            print("há uma atualização disponível")
                        case "MANDATORY":
                            let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.title = "Ops!"
                            alert.message = "Há uma nova versão disponível. Faça a atualização para continuar usando o app."
                            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
                                let url  = NSURL(string: "itms-apps://itunes.apple.com/us/app/brasiloutlet/id1065711297?ls=1&mt=8")
                                if UIApplication.sharedApplication().canOpenURL(url!) == true  {
                                    UIApplication.sharedApplication().openURL(url!)
                                }
                            }
                            alert.addAction(OKAction)
                            self.presentViewController(alert, animated: true, completion: nil)
                        default:
                            print("Não foi possível COMPARAR o status da versão atual no servidor.")
                        }
                    }else {
                        print("Não foi possível obter status da versão atual no servidor.")
                    }
                    

                case .Failure(let error):
                    print("POST Error \(error)")
                }
                
        }
        
        
        
    }
    
    func loadList(notification: NSNotification){

        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""
        self.showHUD()
        MyAPI.post("/webservice/discount/topdiscounts.php", parameters: [ "idcity" : actualCity  ], delegate: self)
        
        self.myCollectionView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.myCollectionView.collectionViewLayout.invalidateLayout()
//        self.myCollectionView.reloadData()
        self.myCollectionView.reloadSections(NSIndexSet.init(index: 0))
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
            print("retornou uma celula com conteúdo da requisicao")
            let productArray = productModelList[indexPath.row] as! ProductModel
            cell.productActualPrice.text = "R$\(productArray.discountPrice)"
            cell.productDescription.text = productArray.description
            cell.productOriginalPrice.text = "R$\(productArray.fullPrice)"
            cell.productDiscountValue.setTitle("\(productArray.discountPercent)%", forState: UIControlState.Normal)
            cell.productDiscountDates.text = ("Promoção válida de: \n" + "\(productArray.startDate) até \(productArray.endDate)")
            
            //loading images from URLs Asyncronously
            let imageURL = (productArray.image)
            print("URL DA IMAGEM: \(imageURL)")
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

        cell.request = Alamofire.request(.POST, likeURL, parameters: parameters as? [String : AnyObject]).responseJSON { response in
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
