//
//  ProductDetailTableViewController.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 11/9/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire

class ProductDetailTableViewController: UITableViewController {
    
    var tableData = ["Carregando os dados..."]
    var productModelList: NSMutableArray = []
    var row = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        if productModelList.count != 0{
            tableView.reloadData()
//            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
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
        if productModelList.count != 0 {
            return productModelList.count
        } else {
            return tableData.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:ProductDetailTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! ProductDetailTableViewCell
        if productModelList.count != 0 {
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
        } else {
            cell.textLabel!.text = tableData[0]
        }
        return cell
    }
    
    func scrollToSelectedRow() {
        let selectedRows = self.tableView.indexPathsForSelectedRows
        if let selectedRow:NSIndexPath = selectedRows![0] {
            self.tableView.scrollToRowAtIndexPath(selectedRow, atScrollPosition: .Middle, animated: true)
        }
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
