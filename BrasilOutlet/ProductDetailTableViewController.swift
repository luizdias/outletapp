//
//  ProductDetailTableViewController.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 11/9/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire
import Social

class ProductDetailTableViewController: UITableViewController, ProductDetailTableViewCellDelegate {
    
    var collectionViewCell = ProductsCollectionViewCell()
    var selectedProductData = ProductModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ProductDetailTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ProductDetailTableViewCell

        cell.delegate = self
        
        if let discountValue = self.collectionViewCell.productDiscountValue.titleLabel {
            cell.productDiscountValue.setTitle(discountValue.text, forState: UIControlState.Normal)
        }
        cell.productActualPrice.text = self.collectionViewCell.productActualPrice.text
        cell.productDescription.text = self.collectionViewCell.productDescription.text
        cell.productLongDescription.text = self.collectionViewCell.productDescription.text
        cell.productOriginalPrice.text = self.collectionViewCell.productOriginalPrice.text
        let productDiscountDatesWithoutLineFeed = self.collectionViewCell.productDiscountDates.text!.stringByReplacingOccurrencesOfString("\n", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
        print("\(self.collectionViewCell.productDiscountDates.text)")
        cell.productDiscountDates.text = productDiscountDatesWithoutLineFeed
        print("\(cell.productDiscountDates.text)")
        cell.productImage.image = nil
        cell.productImage.contentMode = UIViewContentMode.ScaleAspectFit
        cell.productImage.image = self.collectionViewCell.productImage.image
        let store = self.selectedProductData.store
        let storeText = store.name+"\n"+store.neighborName+"  "+store.shoppingName+"\n"+store.address+"\nTelefone: "+store.telephone1+"   "+store.telephone2
        cell.storeDetails.text = storeText
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell
    }
    
    func cellShareButtonTapped(cell: ProductDetailTableViewCell) {

        let shareToFacebook : SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
        shareToFacebook.setInitialText(cell.productDescription.text)
        //TODO: Change to the correct Product URL here
        shareToFacebook.addURL(NSURL(string: "http://www.brasiloutlet.com"))

        if let image = cell.productImage.image {
            shareToFacebook.addImage(image)
        }
        
        self.presentViewController(shareToFacebook, animated: true, completion: nil)
    }

    func cellLikeButtonTapped(cell: ProductDetailTableViewCell) {
//        let indexPath = myCollectionView.indexPathForCell(cell)!
//        let productToLike = productModelList[indexPath.row] as! ProductModel
        let productToLike = ProductModel()
        let likeURL = "http://www.brasiloutlet.com/webservice/discount/like.php?discountid=\(productToLike.id)&type=PUT"
        cell.request = Alamofire.request(.POST, likeURL).responseImage() {
            [weak self] response in
            if let likeResult = response.result.value {
                print("SE LIKE OK: Trocar cor do botão!")
            }
        }
    }

    func cellPhoneButtonTapped(cell: ProductDetailTableViewCell) {
        let phone = "tel://982374234";
        let url:NSURL = NSURL(string:phone)!;
        UIApplication.sharedApplication().openURL(url);
    }
    
    func cellMailButtonTapped(cell: ProductDetailTableViewCell) {
        let email = "foo@bar.com"
        let url = NSURL(string: "mailto:\(email)")
        UIApplication.sharedApplication().openURL(url!)
    }

    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
    }
    */
    
    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
    // Delete the row from the data source
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
    } else if editingStyle == .Insert {
    // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    }
    */
    
    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    
    }
    */
    
    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
    }
    */
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//    }
    
}
