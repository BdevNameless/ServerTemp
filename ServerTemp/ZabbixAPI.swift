//
//  ZabbixAPI.swift
//  ServerTemp
//
//  Created by BdevNameless on 07.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

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
}

class BDNetManager: Alamofire.Manager {
    
    static var sharedManager: BDNetManager = {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "192.168.5.27": .DisableEvaluation
        ]
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        let manager = BDNetManager(
            configuration: config,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
        )
        return manager
    }()
    
    private override init(configuration: NSURLSessionConfiguration, delegate: Manager.SessionDelegate = Manager.SessionDelegate(), serverTrustPolicyManager: ServerTrustPolicyManager? = nil) {
        super.init(configuration: configuration, delegate: delegate, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    internal var currentRequest: Request? = nil
}


class ZabbixManager {
    //MARK: - Initialization
    static var sharedInstance = ZabbixManager()
    
    private init() {
        
    }
    
    //MARK: - Private Attributes
    private let netManager = BDNetManager.sharedManager
    private let zbxConfig = ZabbixConfiguration()
    private var token: String? = nil
    private let zbxErrorDomain = "ZabbixErrorDomain"
    
    
    //MARK: - Internal Methods
    internal func login(handler: ((error: NSError?) -> Void)?) {
        let params = [
            "jsonrpc": "2.0",
            "method": "user.login",
            "params": [
                "user": zbxConfig.username!,
                "password": zbxConfig.password!,
            ],
            "id": 1
        ]
        netManager.request(.POST, "https://\(zbxConfig.serverAddress!)/zabbix/api_jsonrpc.php", parameters: params, encoding: .JSON).responseSWJSON() { [unowned self] (res: Response<JSON, NSError>) in
            let reqError = res.result.error
            guard reqError == nil else {
                if handler != nil {
                    handler!(error: reqError!)
                }
                return
            }
            let json = res.result.value!
            let jsonError = json["error"]
            guard jsonError == nil else {
                if handler != nil {
                    handler!(error: NSError(domain: self.zbxErrorDomain, code: jsonError["code"].int!, userInfo: [NSLocalizedDescriptionKey: jsonError["data"].string!]))
                }
                return
            }
            if handler != nil {
                self.token = json["result"].string!
                print(self.token)
                handler!(error: nil)
            }
        }
    }
    
}

