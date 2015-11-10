//
//  NearestsStoresTableViewController.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/30/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class NearestsStoresTableViewController: UITableViewController, CLLocationManagerDelegate, APIProtocol {
    
    var locManager = CLLocationManager()
    var request: Alamofire.Request?
    var tableData = ["Carregando os dados.."]
    var MyAPI = API()
    var storeModelList: NSMutableArray = []
    
    func didReceiveResult(result: JSON) {
        
        self.hideHUD()
        let stores: NSMutableArray = []
        
        NSLog("Stores.didReceiveResult: \(result)")
        
        for (index,subJson):(String, JSON) in result {
            let store = StoreModel()
            store.id = subJson["id"].stringValue
            store.name = subJson["name"].stringValue
            store.socialName = subJson["socialName"].stringValue
            store.cnpj = subJson["cnpj"].stringValue
            store.address = subJson["address"].stringValue
            store.latCoordinate = subJson["latCoordinate"].stringValue
            store.longCoordinate = subJson["longCoordinate"].stringValue
            store.cityId = subJson["cityId"].stringValue
            store.favorite = subJson["favorite"].stringValue
            store.neighborId = subJson["neighborId"].stringValue
            store.neighborName = subJson["neighborName"].stringValue
            store.shoppingId = subJson["shoppingId"].stringValue
            store.telephone1 = subJson["telephone1"].stringValue
            store.telephone2 = subJson["telephone2"].stringValue
            store.subscriptionPlan = subJson["subscriptionPlan"].stringValue
            store.subscriptionExpirationDate = subJson["subscriptionExpirationDate"].stringValue
            store.subscriptionDiscountsLimit = subJson["subscriptionDiscountsLimit"].stringValue
            stores.addObject(store)
        }
        
        storeModelList = stores
        print("Quantidade de Lojas after: \(storeModelList.count)")
        
        // Make sure we are on the main thread, and update the UI.
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // to test localhost change the path to this bellow:
        //        MyAPI.get("/db")
        
        locManager.requestWhenInUseAuthorization()
        
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
                
                currentLocation = locManager.location!
        }
        
        print("Localization longitude: \(currentLocation.coordinate.longitude)")
        print("Localization latitude: \(currentLocation.coordinate.latitude)")
        
        self.showHUD()
        MyAPI.post("/webservice/store/nearests.php", parameters: [
               "idcity" : "7",
            "latitude"  : "\(currentLocation.coordinate.latitude)".stringByReplacingOccurrencesOfString("-", withString: ""),
            "longitude" : "\(currentLocation.coordinate.longitude)".stringByReplacingOccurrencesOfString("-", withString: "")
            ], delegate: self)
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
        if storeModelList.count != 0{
            return storeModelList.count
        } else {
            return tableData.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        
        if storeModelList.count != 0 {
            let storeArray = storeModelList[indexPath.row] as! StoreModel
            cell.textLabel!.text = storeArray.name
        } else {
            cell.textLabel!.text = tableData[0]
        }
        return cell
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
//        if(segue.identifier == "subCategoriesView"){
//            let vc = segue.destinationViewController as! SubCategoriesTableViewController
//            vc.subCategoryModelList = self.subCategoryModelList
//        }
        
    }
    
}
