//
//  UIViewControllerExtension.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 11/9/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    
    func showHUD(){
        let loading = MBProgressHUD.showHUDAddedTo((UIApplication.sharedApplication().delegate as! AppDelegate).window, animated: true)
        loading.userInteractionEnabled = false
    }
    
    func hideHUD() {
        MBProgressHUD.hideAllHUDsForView((UIApplication.sharedApplication().delegate as!
            AppDelegate).window, animated: true)
    }
    
}