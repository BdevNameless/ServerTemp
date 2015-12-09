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


class ZabbixManager {
    //MARK: - Initialization
    static var sharedInstance = ZabbixManager()
    
    private init() {
        
    }
    
    //MARK: - Private Attribute
    private let netManager = BDNetManager.sharedManager
    private let zbxConfig = ZabbixConfiguration()
    private var token: String? = nil
    private let zbxErrorDomain = "ZabbixErrorDomain"
    lazy private var restURL: String? = {
        if let address = ZabbixConfiguration().serverAddress {
            return "https://\(address)/zabbix/api_jsonrpc.php"
        }
        return nil
    }()
    
    
    //MARK: - Internal Methods
    internal func login(handler: ((error: NSError?) -> Void)?) {
        if zbxConfig.isValid {
            let params = [
                "jsonrpc": "2.0",
                "method": "user.login",
                "params": [
                    "user": zbxConfig.username!,
                    "password": zbxConfig.password!,
                ],
                "id": 1
            ]
            netManager.request(.POST, restURL!, parameters: params, encoding: .JSON).responseSWJSON() { [unowned self] (res: Response<JSON, NSError>) in
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
        else{
            if handler != nil {
                handler!(error: NSError(domain: zbxErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Zabbix configuration. Check preferences."]))
            }
        }
    }
    
    internal func freshTempFor300Serv(handler: ((error: NSError?, result: [JSON]?) -> Void)?) {
        guard token != nil else {
            if handler != nil {
                handler!(error: NSError(domain: zbxErrorDomain, code: -2, userInfo: [NSLocalizedDescriptionKey: "Zabbix authorization is needed."]), result: nil)
            }
            return
        }
        let params = [
            "jsonrpc": "2.0",
            "method": "history.get",
            "params": [
                "output": "extend",
                "history": 0,
                "itemids": ["23663", "23664"],
                "sortfield": "clock",
                "sortorder": "DESC",
                "limit": 2
            ],
            "auth": token!,
            "id": 1
        ]
        netManager.request(.POST, restURL!, parameters: (params as! [String : AnyObject]), encoding: .JSON).responseSWJSON() { [unowned self] (res: Response<JSON, NSError>) in
            let reqError = res.result.error
            guard reqError == nil else {
                if handler != nil {
                    handler!(error: reqError!, result: nil)
                }
                return
            }
            let json = res.result.value!
            let jsonError = json["error"]
            guard jsonError == nil else {
                if handler != nil {
                    handler!(error: NSError(domain: self.zbxErrorDomain, code: jsonError["code"].int!, userInfo: [NSLocalizedDescriptionKey: jsonError["data"].string!]), result: nil)
                }
                return
            }
            let jsonResult = json["result"].arrayValue
            if handler != nil {
                handler!(error: nil, result: jsonResult)
            }
        }
    }
    
}

