//
//  ChooseCityViewController.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 11/22/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import SwiftyJSON

class ChooseCityViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var cityPickerTextField: UITextField!
    
    @IBOutlet weak var actualCityText: UILabel!
    @IBOutlet weak var actualCityLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBAction func confirmChosenCity(sender: AnyObject) {
        print("definindo cidade do usuário: \(cityToSave+1)")
        NSUserDefaults().setString("\(cityToSave+1)", forKey: "userCityKey")
        NSNotificationCenter.defaultCenter().postNotificationName("load", object: nil)
        self.dismissViewControllerAnimated(true) { () -> Void in  }
    }
    
    @IBAction func cancelChoice(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { () -> Void in  }
    }
    private var citiesArray = [City]()
    private var cityToSave:Int = 0
    
    struct City {
        var id: String
        var state: String
        var city: String
    }
    
    func loadCitiesData() -> [City]{
        let path = NSBundle.mainBundle().pathForResource("cityData", ofType: "json")!
        let data = NSData(contentsOfFile: path)!
        let json = JSON(data: data)
        
        var cities = [City]()
        for (_, item) in json {
            let id = item["id"].string!
            let state = item["state"].string!
            let city = item["city"].string!
            cities.append(City(id: id, state: state, city: city))
        }
        
        return cities
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        citiesArray = loadCitiesData()
        cancelButton.hidden = true
        let actualCity = NSUserDefaults.standardUserDefaults().stringForKey("userCityKey") ?? ""
        
        if  actualCity != "" && actualCity != "0" {
            actualCityText.text = citiesArray[Int(actualCity)!-1].city
            cancelButton.hidden = false
        } else {
            actualCityText.text = ""
            actualCityLabel.hidden = true
        }
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        cityPickerTextField.inputView = pickerView
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return citiesArray.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(citiesArray[row].city) - \(citiesArray[row].state)"
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cityPickerTextField.text = citiesArray[row].city
        cityToSave = row
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
