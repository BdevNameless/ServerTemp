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
    internal func cancelCurrentRequest() {
        if let cur_req = netManager.currentRequest {
            cur_req.cancel()
            netManager.currentRequest = nil
        }
    }
    
    internal func login(handler: ((error: NSError?, result: JSON?) -> Void)?) {
        if zbxConfig.isValid {
            let params = [
                    "user": zbxConfig.username!,
                    "password": zbxConfig.password!
            ]
            performRequestForMethod(.Login, withParams: params, handler: handler)
        }
        else{
            if handler != nil {
                handler!(error: NSError(domain: zbxErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Zabbix configuration. Check preferences."]), result: nil)
            }
        }
    }
    
    internal func freshTempFor300Serv(handler: ((error: NSError?, result: JSON?) -> Void)?) {
        guard token != nil else {
            login() { [unowned self] (loginError: NSError?, result: JSON?) in
                guard loginError == nil else {
                    if handler != nil {
                        handler!(error: loginError!, result: nil)
                    }
                    return
                }
                self.freshTempFor300Serv(handler)
            }
            return
        }
        let params = [
                "output": "extend",
                "history": 0,
                "itemids": ["23663", "23664"],
                "sortfield": "clock",
                "sortorder": "DESC",
                "limit": 2
        ]
        performRequestForMethod(.GetHistory, withParams: params, handler: handler)
    }
    
    internal func getItemsByID(id: [String], handler: ((error: NSError?, result: JSON?) -> Void)?) {
        guard token != nil else {
            login() { [unowned self] (loginError: NSError?, result: JSON?) in
                guard loginError == nil else {
                    if handler != nil {
                        handler!(error: loginError!, result: nil)
                    }
                    return
                }
                self.getItemsByID(id, handler: handler)
            }
            return
        }
        let params: [String: AnyObject] = [
            "output": "extend",
            "itemids": id
        ]
        performRequestForMethod(.GetItem, withParams: params, handler: handler)
    }
    
    //MARK: - Private Methods
    
    private enum APIMethod : String {
        case Login = "user.login"
        case GetHistory = "history.get"
        case GetHost = "host.get"
        case GetItem = "item.get"
    }
    
    private func performRequestForMethod(method: APIMethod, withParams params: [String: AnyObject], handler: ((error: NSError?, result: JSON?) -> Void)?) {
        var parameters: [String: AnyObject] = [
            "jsonrpc": "2.0",
            "method": method.rawValue,
            "params": params,
            "id": 1
        ]
        if ((token != nil)&&(method != .Login)) {
            parameters["auth"] = token!
        }
        netManager.request(.POST, restURL!, parameters: parameters, encoding: .JSON).responseSWJSON() { [unowned self] (res: Response<JSON, NSError>) in
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
            let jsonResult = json["result"]
            if handler != nil {
                if method == .Login {
                    self.token = jsonResult.stringValue
                    handler!(error: nil, result: nil)
                }
                else {
                    handler!(error: nil, result: jsonResult)
                }
            }
        }
    }
    
}

