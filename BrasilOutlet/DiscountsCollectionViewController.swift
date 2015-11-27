//
//  DiscountsCollectionViewController.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/27/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class DiscountsCollectionViewController: UICollectionViewController, APIProtocol {
    
    var viewControllerDelegate : ViewControllerProtocol?
    private var str : String?
    
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
            self.collectionView?.reloadData()
            self.collectionView?.reloadSections(NSIndexSet.init(index: 0))
            print("dispatch main queue here!")
            
        })
    }
    
    func didErrorHappened(error: NSError) {
        self.hideHUD()
        let alert = UIAlertController(title: "Erro", message: "Há um problema na conexão com o BrasilOutlet. Tente novamente mais tarde (1011).", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    override func loadView() {
        super.loadView()
        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""
        self.showHUD()
        MyAPI.post("/webservice/discount/topdiscounts.php", parameters: [ "idcity" : actualCity  ], delegate: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(true)
//        for _ in tableData {
//            productModelList.addObject(tableData)
//            print(productModelList.description)
//        }

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Quantidade de itens na sessao: \(productModelList.count)")
        if productModelList.count != 0{
            return productModelList.count
        } else {
            return tableData.count
        }
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ProductsCollectionViewCell
        if productModelList.count != 0{
            cell.productActualPrice.text = "9999"
            cell.productDescription.text = productModelList[0] as? String
            cell.setNeedsDisplay()
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        print("selecionou uma celula!")
    }
    
}
