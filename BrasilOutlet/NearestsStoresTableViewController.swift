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
            store.id = subJson["id"].intValue
            store.name = subJson["name"].stringValue
            store.socialName = subJson["socialName"].stringValue
            store.cnpj = subJson["cnpj"].stringValue
            store.address = subJson["address"].stringValue
            store.latCoordinate = subJson["latCoordinate"].stringValue
            store.longCoordinate = subJson["longCoordinate"].stringValue
            store.cityId = subJson["cityId"].intValue
            store.favorite = subJson["favorite"].stringValue
            store.neighborId = subJson["neighborId"].intValue
            store.neighborName = subJson["neighborName"].stringValue
            store.shoppingId = subJson["shoppingId"].intValue
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
    
    func didErrorHappened(error: NSError) {
        self.hideHUD()
        let alert = UIAlertController(title: "Erro", message: "Há um problema na conexão com o BrasilOutlet. Tente novamente mais tarde (1011).", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        // to test localhost change the path to this bellow:
        //        MyAPI.get("/db")
        
        //TODO: Implement control that uses the actual CITY when user DENIES the authorization
        locManager.requestWhenInUseAuthorization()
        
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
                
                currentLocation = locManager.location!
        }
        
        print("Localization longitude: \(currentLocation.coordinate.longitude)")
        print("Localization latitude: \(currentLocation.coordinate.latitude)")
        
        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""
        
        self.showHUD()
        MyAPI.post("/webservice/store/nearests.php", parameters: [
               "idcity" : actualCity,
            "latitude"  : "\(currentLocation.coordinate.latitude)".stringByReplacingOccurrencesOfString("-", withString: ""),
            "longitude" : "\(currentLocation.coordinate.longitude)".stringByReplacingOccurrencesOfString("-", withString: "")
            ], delegate: self)
    }
    
    func loadList(notification: NSNotification){
        
        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""
        self.showHUD()
        MyAPI.post("/webservice/category/discountcategorylist.php", parameters: [ "idcity" : actualCity, "gender" : "1"  ], delegate: self)
        
        self.tableView.reloadData()
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
        let cell:StoreTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! StoreTableViewCell
        
        if storeModelList.count != 0 {
            let storeArray = storeModelList[indexPath.row] as! StoreModel
            cell.nameLabel.text = storeArray.name
            cell.detailsLabel.text = storeArray.shoppingName + "\n" + storeArray.address
        } else {
            cell.nameLabel.text = tableData[0]
            cell.detailsLabel.text = tableData[0]
        }
        return cell
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
        
        if(segue.identifier == "productsView"){
            let vc = segue.destinationViewController as! ProductsCollectionViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            let selectedStore = storeModelList[indexPath!.row] as! StoreModel
            print("Na tela nearest stores storeid\(selectedStore.id)")
            vc.storeId = selectedStore.id
        }
        
    }
    
}
