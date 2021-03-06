//
//  CategoriesTableViewController.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/30/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class CategoriesTableViewController: UITableViewController, CLLocationManagerDelegate, APIProtocol {

    var locManager = CLLocationManager()
    var request: Alamofire.Request?
    var tableData = [""]
    var MyAPI = API()
    var categoryModelList: NSMutableArray = []
    var subCategoryModelList: NSMutableArray = []
    
    func didReceiveResult(result: JSON) {
        self.hideHUD()
        let categories: NSMutableArray = []
        let subCategories: NSMutableArray = []
        
        NSLog("Categories.didReceiveResult: \(result)")
        
        for (index,subJson):(String, JSON) in result {
            if subJson["idfather"] == "0" {
                let category = CategoryModel()
                category.id = subJson["id"].stringValue
                category.name = subJson["name"].stringValue
                category.favorite = subJson["favorite"].stringValue
                category.gender = subJson["gender"].stringValue
                category.idfather = subJson["idfather"].stringValue
                category.imagePath = subJson["image_path"].stringValue
                category.image = subJson["image"].stringValue
                print("URL da imagem: \(category.imagePath)")
                categories.addObject(category)
            } else {
                let subCategory = CategoryModel()
                subCategory.id = subJson["id"].stringValue
                subCategory.name = subJson["name"].stringValue
                subCategory.favorite = subJson["favorite"].stringValue
                subCategory.gender = subJson["gender"].stringValue
                subCategory.idfather = subJson["idfather"].stringValue
                subCategory.imagePath = subJson["image_path"].stringValue
                subCategories.addObject(subCategory)
            }
        }
        
        categoryModelList = categories
        subCategoryModelList = subCategories
        print("Quantidade de categorias after: \(categoryModelList.count)")
        print("Quantidade de subCategorias after: \(subCategoryModelList.count)")
        
        // Make sure we are on the main thread, and update the UI.
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.reloadData()
        })
    }
    
    func didErrorHappened(error: NSError) {
        self.hideHUD()
        let alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        if let message = error.userInfo["message"]{
            print("\(message.description)")
            alert.title = "Oops! 😮"
            alert.message = message as? String
            categoryModelList = []
            subCategoryModelList = []
            self.tableView.reloadData()
        }else {
            alert.title = "Erro"
            alert.message = "Há um problema na conexão com o BrasilOutlet. Tente novamente mais tarde (1011)."
        }
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

        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"load", object: nil)

        self.showHUD()
        MyAPI.post("/webservice/category/discountcategorylist.php", parameters: [ "idcity" : actualCity, "gender" : "1"  ], delegate: self)
        

        locManager.requestWhenInUseAuthorization()
        
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
                
                currentLocation = locManager.location!
        }
        
        print("Localization longitude: \(currentLocation.coordinate.longitude)")
        print("Localization latitude: \(currentLocation.coordinate.latitude)")
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
        if categoryModelList.count != 0{
            return categoryModelList.count
        } else {
            return tableData.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:CategoriesTableViewCell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CategoriesTableViewCell

        if categoryModelList.count != 0 {
            let categoryArray = categoryModelList[indexPath.row] as! CategoryModel
            cell.categoryDescription.text = categoryArray.name
            
            //loading images from URLs Asyncronously
//            let imageURL = (categoryArray.image_path)
            let imageURL = categoryArray.imagePath
            print("URL DA IMAGEM: \(imageURL)")
            cell.imageView?.image = nil
            cell.request?.cancel()
            cell.request = Alamofire.request(.GET, imageURL).responseImage() {
                [weak self] response in
                if let image = response.result.value {
                    print("The loaded image: \(image)")
                    cell.leftImage.contentMode = UIViewContentMode.ScaleAspectFit
                    cell.leftImage.image = image
                }
            }

        } else {
            cell.categoryDescription.text = tableData[0]
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
        
        if(segue.identifier == "subCategoriesView"){
            let vc = segue.destinationViewController as! SubCategoriesTableViewController
            vc.subCategoryModelList = self.subCategoryModelList
        }
        
    }

}
