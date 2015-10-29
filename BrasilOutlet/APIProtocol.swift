//
//  APIProtocol.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/27/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import Foundation
import SwiftyJSON

// Creating a protocol called APIProtocol
protocol APIProtocol {
    func didReceiveResult(results: JSON)
    
}
