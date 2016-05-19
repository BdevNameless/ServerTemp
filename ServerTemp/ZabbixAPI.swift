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


class ReportValue {
    
    var value: Double? = nil
    var date: NSDate? = nil

    func description() -> String {
        return "Record(value: \(value), date: \(date))"
    }
    
    init(val: Double?, clock: NSDate?) {
        value = val
        date = clock
    }
}

class ZabbixManager {
    //MARK: - Initialization
    static var sharedInstance = ZabbixManager()
    
    private init() {
        
    }
    
    //MARK: - Private Attributes
    private let netManager = BDNetManager.sharedManager
//    private let zbxConfig = ZabbixConfiguration()
    private var token: String? = nil
    private let zbxErrorDomain = "ZabbixErrorDomain"
    lazy private var restURL: String? = {
        if let address = ZabbixConfiguration.serverAddress {
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
        if ZabbixConfiguration.isValid {
            let params = [
                    "user": ZabbixConfiguration.username!,
                    "password": ZabbixConfiguration.password!
            ]
            performRequestForMethod(.Login, withParams: params, handler: handler)
        }
        else{
            if handler != nil {
                handler!(error: NSError(domain: zbxErrorDomain, code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Zabbix configuration. Check preferences."]), result: nil)
            }
        }
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
    
    internal func getFresh300Report(handler: ((error: NSError?, result: [String: ReportValue]?) -> Void)?) {
        guard token != nil else {
            login() { [unowned self] (loginError: NSError?, result: JSON?) in
                guard loginError == nil else {
                    if handler != nil {
                        handler!(error: loginError!, result: nil)
                    }
                    return
                }
                self.getFresh300Report(handler)
            }
            return
        }
        _freshTempFor300Serv() { (fetchError: NSError?, res: JSON?) in
            guard fetchError == nil else {
                if handler != nil {
                    handler!(error: fetchError!, result: nil)
                }
                return
            }
            var response: [String: ReportValue] = [:]
            let asArray = res!.arrayValue
            for item in asArray {
                let key = item["itemid"].stringValue
                let report = ReportValue(val: item["value"].doubleValue, clock: NSDate(timeIntervalSince1970: item["clock"].doubleValue).dateByAddingTimeInterval(Double(NSTimeZone.systemTimeZone().secondsFromGMTForDate(NSDate()))))
                response[key] = report
            }
            if handler != nil {
                handler!(error: nil, result: response)
            }
        }
        
    }
    
    internal func get300History(hours: Int, handler: ((error: NSError?, result: [ReportValue]?) -> Void)?) {
        guard token != nil else {
            login() { [unowned self] (loginError: NSError?, result: JSON?) in
                guard loginError == nil else {
                    if handler != nil {
                        handler!(error: loginError!, result: nil)
                    }
                    return
                }
                self.get300History(hours, handler: handler)
            }
            return
        }
        let now = NSDate()
        let fromDate = String(Int(now.dateByAddingTimeInterval(Double(-(hours*3600))).timeIntervalSince1970))
        print(now, now.dateByAddingTimeInterval(Double(-(hours*3600))))
        var res1: [JSON] = []
        var res2: [JSON] = []
        _getItemHistory("23663", fromTimestamp: fromDate) { [unowned self] (error1: NSError?, result1: JSON?) in
            guard error1 == nil else {
                if handler != nil {
                    handler!(error: error1, result: nil)
                }
                return
            }
            res1 = result1!.arrayValue
            self._getItemHistory("23664", fromTimestamp: fromDate) { (error2: NSError?, result2: JSON?) in
                guard error2 == nil else {
                    if handler != nil {
                        handler!(error: error2, result: nil)
                    }
                    return
                }
                res2 = result2!.arrayValue
                var delta = res2.count - res1.count
                print(delta)
                if delta != 0 {
                    while delta > 0 {
                        res2.removeFirst()
                        delta -= 1
                    }
                }
                let step = res2.count/hours
                var i = 0
                var response: [ReportValue] = []
                while i < res2.count {
                    let aver = (res1[i]["value"].doubleValue + res2[i]["value"].doubleValue)/2
                    let date = NSDate(timeIntervalSince1970: res2[i]["clock"].doubleValue).dateByAddingTimeInterval(Double(NSTimeZone.systemTimeZone().secondsFromGMTForDate(NSDate())))
                    response.append(ReportValue(val: aver, clock: date))
                    i += step
                }
                if handler != nil {
                    handler!(error: nil, result: response)
                }
            }
        }
    }
    
    //MARK: - Private Methods
    
    private func _freshTempFor300Serv(handler: ((error: NSError?, result: JSON?) -> Void)?) {
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
    
    private func _getItemHistory(itemid: String, fromTimestamp from_time: String, handler: ((error: NSError?, result: JSON?) -> Void)?) {
        let params : [String: AnyObject] = [
            "output": "extend",
            "history": 0,
            "itemids": itemid,
            "sortfield": "clock",
            "sortorder": "DESC",
            "time_from": from_time
        ]
        performRequestForMethod(.GetHistory, withParams: params, handler: handler)
    }
    
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

