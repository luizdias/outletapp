//
//  API.swift
//  BrasilOutlet
//
//  Created by Luiz Dias on 10/27/15.
//  Copyright © 2015 Luiz Dias. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class API {
    
    let hostname = "http://www.brasiloutlet.com"
    
    // Setting up an API Class with a GET method that accepts a elegate of type APIProtocol
    func get(path: String, parameters: [String: AnyObject]? = nil, delegate: APIProtocol? = nil){
        let url = "\(self.hostname)\(path)"
        NSLog("Preparing for GET request to: \(url)")
        
        Alamofire.request(.GET, url, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    print("GET Validation Successful")
                    let json = JSON(response.result.value!)
                    print("GET Result: \(json)")
                    // Call delegate if it was passed into the call
                    if (delegate != nil) {
                        delegate!.didReceiveResult(json)
                    }
                case .Failure(let error):
                    print("GET Error: \(error)")
                }

        }
    }

    
    
    // Setting up an API Class with a POST method that accepts a elegate of type APIProtocol
    func post(path: String, parameters: [String: AnyObject]? = nil, delegate: APIProtocol? = nil){
        let url = "\(self.hostname)\(path)"
        NSLog("Preparing for POST request to: \(url)")
        
        Alamofire.request(.POST, url, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    print("Validation Successful")
                    let json = JSON(response.result.value!)
                    NSLog("POST Result: \(json)")
                    // Call delegate if it was passed into the call
                    if(delegate != nil) {
                        delegate!.didReceiveResult(json)
                    }
                case .Failure(let error):
                    print("POST Error \(error)")
                }
                
                        }

        
        
    }
    
}

extension Alamofire.Request {
    
    public static func imageResponseSerializer() -> ResponseSerializer<UIImage, NSError> {
        return ResponseSerializer { request, response, data, error in
            
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            if let image = UIImage(data: validData) {
                return .Success(image)
            }
            else {
                return .Failure(Error.errorWithCode(.DataSerializationFailed, failureReason: "Unable to create image."))
            }
            
        }
    }
    
    func responseImage(completionHandler: Response<UIImage, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.imageResponseSerializer(), completionHandler: completionHandler)
    }
}