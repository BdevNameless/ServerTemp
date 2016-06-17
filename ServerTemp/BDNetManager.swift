//
//  BDNetManager.swift
//  ServerTemp
//
//  Created by BdevNameless on 09.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import NetworkExtension

extension Request {
    public static func SWJSONResponseSerializer() -> ResponseSerializer<JSON, NSError> {
        return ResponseSerializer { request, response, data, error in
            guard error == nil else {
                return .Failure(error!)
            }
            
            guard data != nil else {
                let failReason = "Data could not be serialized. Input data is nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failReason)
                return .Failure(error)
            }
            var jsonError: NSError? = nil
            let json = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: &jsonError)
            if jsonError == nil {
                return .Success(json)
            }
            return .Failure(jsonError!)
        }
    }
    
    public func responseSWJSON(completionHandler: Response<JSON, NSError> -> Void) -> Self {
        return response(responseSerializer: Request.SWJSONResponseSerializer(), completionHandler: completionHandler)
    }
    
    //MARK: -
}


class BDNetManager: Alamofire.Manager {
    
    static var sharedManager: BDNetManager = {
        var serverTrustPolicies: [String: ServerTrustPolicy] = [:]
        if let address = ZabbixConfiguration.serverAddress {
            serverTrustPolicies[address] = .DisableEvaluation
        }
//        let serverTrustPolicies: [String: ServerTrustPolicy] = [
//            "192.168.5.27": .DisableEvaluation,
//            "zabbix.viveya.local": .DisableEvaluation
//        ]
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        let manager = BDNetManager(
            configuration: config,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()
    
    //MARK: Attributes
    internal var currentRequest: Request? = nil
    
    private let vpnConfig = VPNConfiguration()
    
    //MARK: Initializers
    private override init(configuration: NSURLSessionConfiguration, delegate: Manager.SessionDelegate = Manager.SessionDelegate(), serverTrustPolicyManager: ServerTrustPolicyManager? = nil) {
        super.init(configuration: configuration, delegate: delegate, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    //MARK: public API
    internal override func request(method: Alamofire.Method, _ URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: ParameterEncoding = .URL, headers: [String : String]? = nil) -> Request {
        currentRequest = super.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
        return currentRequest!
    }
    
    //MARK: -
}
