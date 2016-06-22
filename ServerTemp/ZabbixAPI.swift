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


struct ReportValue: CustomStringConvertible {
    
    let value: Double
    let date: NSDate
    let itemid: String

    var description: String {
        return "Record(value: \(value), date: \(date))"
    }
    
//    init(val: Double?, clock: NSDate?) {
//        value = val
//        date = clock
//    }
}

struct ZabbixItem: CustomStringConvertible {
    let itemid: String
    let name: String
    let units: String
    let lastClock: NSDate
    let lastValue: Double
    
    var description: String {
        return "Zabbix Item (itemid: \(itemid), name: \(name), units: \(units), lastclock: \(lastClock), lastValue: \(lastValue))"
    }
    
}

struct ZabbixHost: CustomStringConvertible {
    
    let hostid: String
    let hostname: String
    let snmp_available: Bool
    let available: Int
    let status: Int
    
    var description: String {
        return "Zabbix Host(hostid: \(hostid), hostname: \(hostname), snmp_available: \(snmp_available), available: \(available), status: \(status))"
    }
    
//    init(hostid: String, hostname: String, snmp: Bool, available: Int, status: Int) {
//        self.hostid = hostid
//        self.hostname = hostname
//        snmp_available = snmp
//        self.available = available
//        self.status = status
//    }
}

class ZabbixManager {
    
    //MARK: - Initialization
    static var sharedInstance = ZabbixManager()
    
    private init() {
        
    }
    
    //MARK: - Private Attributes
    private let netManager = BDNetManager.sharedManager
    private var token: String? = nil
    private let zbxErrorDomain = "ZabbixErrorDomain"
    lazy private var restURL: String? = {
        if let address = ZabbixConfiguration.serverAddress {
            return "https://\(address)/zabbix/api_jsonrpc.php"
        }
        return nil
    }()
    
    //MARK: - Internal Methods
    
    func cancelCurrentRequest() {
        if let cur_req = netManager.currentRequest {
            cur_req.cancel()
            netManager.currentRequest = nil
        }
    }
    
    func getItemReportsByIDs(itemids: [String]?, withFilter filter: [String: AnyObject]?, handler: ((error: NSError?, result: [String: ReportValue]?) -> Void)?) {
        var params: [String: AnyObject] = ["output": "extend"]
        if itemids != nil {
            params["itemids"] = itemids!
        }
        if filter != nil {
            params["filter"] = filter!
        }
        performRequestForAuthentificatedMethod(.GetItem, withParams: params) { (error, result) in
            guard error == nil else {
                if handler != nil {
                    handler!(error: error, result: nil)
                }
                return
            }
            var response: [String: ReportValue] = [:]
            let asArray = result!.arrayValue
            for item in asArray {
                let key = item["itemid"].stringValue
                let report = ReportValue(value: item["lastvalue"].doubleValue, date: NSDate(timeIntervalSince1970: item["lastclock"].doubleValue).dateByAddingTimeInterval(Double(NSTimeZone.systemTimeZone().secondsFromGMTForDate(NSDate()))), itemid: item["itemid"].stringValue)
                response[key] = report
            }
            if handler != nil {
                handler!(error: nil, result: response)
            }
        }
    }
    
    func getHistoryByIDs(itemids: [String]?, withFilter filter: [String: AnyObject]?, handler: ((error: NSError?, result: [ReportValue]?) -> Void)?) {
        var params: [String: AnyObject] = ["output": "extend", "sortfield": ["itemid", "clock"], "sortorder": "DESC"]
        if itemids != nil {
            params["itemids"] = itemids!
        }
        if filter != nil {
            params["filter"] = filter!
        }
        performRequestForAuthentificatedMethod(.GetHistory, withParams: params) { (error, result) in
            guard error != nil else {
                if handler != nil {
                    handler!(error: error, result: nil)
                }
                return
            }
            
            if handler != nil {
                var response: [ReportValue] = []
                for report in result!.arrayValue {
                    response.append(ReportValue(value: report["value"].doubleValue, date: NSDate(timeIntervalSince1970: report["clock"].doubleValue).dateByAddingTimeInterval(Double(NSTimeZone.systemTimeZone().secondsFromGMTForDate(NSDate()))), itemid: report["itemid"].stringValue))
                }
                handler!(error: nil, result: response)
            }
        }
    }
    
    func getItemsByIDs(itemids: [String]?, withFilter filter: [String: AnyObject]?, handler: ((error: NSError?, result: [ZabbixItem]?) -> Void)?) {
        var params: [String: AnyObject] = ["output": "extend", "sortfield": "name", "sortorder": "ASC"]
        if itemids != nil {
            params["itemids"] = itemids!
        }
        if filter != nil {
            params["filter"] = filter!
        }
        performRequestForAuthentificatedMethod(.GetItem, withParams: params) { (error, result) in
            guard error == nil else {
                if handler != nil {
                    handler!(error: error, result: nil)
                }
                return
            }
            if handler != nil {
                var response: [ZabbixItem] = []
                for item in result!.arrayValue {
                    response.append(ZabbixItem(itemid: item["itemid"].stringValue, name: item["name"].stringValue, units: item["units"].stringValue, lastClock: NSDate(timeIntervalSince1970: item["lastclock"].doubleValue).dateByAddingTimeInterval(Double(NSTimeZone.systemTimeZone().secondsFromGMTForDate(NSDate()))), lastValue: item["lastvalue"].doubleValue))
                }
                handler!(error: nil, result: response)
            }
        }
    }
    
    func getHostsByIDs(hostids: [String]?, withFilter filter: [String: AnyObject]?, handler: ((error: NSError?, result: [ZabbixHost]?) -> Void)?) {
        var params: [String: AnyObject] = ["output": "extend", "sortfield": "name", "sortorder": "ASC", "with_monitored_items": true]
        if hostids != nil {
            params["hostids"] = hostids!
        }
        if filter != nil {
            params["filter"] = filter!
        }
        performRequestForAuthentificatedMethod(.GetHost, withParams: params) { (error, result) in
            guard error == nil else {
                if handler != nil {
                    handler!(error: error, result: nil)
                }
                return
            }
            if handler != nil {
                var response: [ZabbixHost] = []
                print(result!.arrayValue)
                for host in result!.arrayValue {
                    response.append(ZabbixHost(hostid: host["hostid"].stringValue, hostname: host["name"].stringValue, snmp_available: host["snmp_available"].boolValue, available: host["available"].intValue, status: host["status"].intValue))
                }
                handler!(error: nil, result: response)
            }
        }
        
    }
    
    //MARK: - Private Methods
    
    private enum APIMethod : String {
        case Login = "user.login"
        case GetHistory = "history.get"
        case GetHost = "host.get"
        case GetItem = "item.get"
    }
    
    private func performRequestForAuthentificatedMethod(method: APIMethod, withParams params: [String: AnyObject], handler: ((error: NSError?, result: JSON?) -> Void)?) {
        
        guard ZabbixConfiguration.isValid else {
            if handler != nil {
                handler!(error: NSError(domain: zbxErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Zabbix configuration. Check preferences."]), result: nil)
            }
            return
        }
        
        guard token != nil else {
            let _params = [
                "user": ZabbixConfiguration.username!,
                "password": ZabbixConfiguration.password!
            ]
            
            performRequestForMethod(.Login,
                                    withParams: _params,
                                    handler:
                { [unowned self] (loginError: NSError?, loginResult: JSON?) in
                    if loginError != nil {
                        if handler != nil {
                            handler!(error: loginError!, result: nil)
                        }
                    }
                    else {
                        self.token = loginResult!.stringValue
                        self.performRequestForAuthentificatedMethod(method, withParams: params, handler: handler)
                    }
                }
            )
            return
        }
        
        let parameters: Dictionary<String, AnyObject> = [
            "jsonrpc": "2.0",
            "method": method.rawValue,
            "params": params,
            "id": 1,
            "auth": token!
        ]
        
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
    
    private func performRequestForMethod(method: APIMethod, withParams params: [String: AnyObject], handler: ((error: NSError?, result: JSON?) -> Void)?) {
        
        guard ZabbixConfiguration.isValid else {
            if handler != nil {
                handler!(error: NSError(domain: zbxErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Zabbix configuration. Check preferences."]), result: nil)
            }
            return
        }
        
        let parameters: [String: AnyObject] = [
            "jsonrpc": "2.0",
            "method": method.rawValue,
            "params": params,
            "id": 1
        ]
        
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
                handler!(error: nil,  result:jsonResult)
            }
        }
        
    }

}

