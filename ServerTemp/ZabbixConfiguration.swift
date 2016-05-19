//
//  ZabbixConfiguration.swift
//  ServerTemp
//
//  Created by BdevNameless on 01.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import Foundation
import Security
import NetworkExtension

class ZabbixConfiguration {

    
    //MARK: - Instance varuables
    static internal var username: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("ZabbixUsername")
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(newValue, forKey: "ZabbixUsername")
            userDefaults.synchronize()
        }
    }
    static internal var password: String? {
        get {
            return ZabbixConfiguration.loadPassword()
        }
        set {
            ZabbixConfiguration.updatePassword(newValue)
        }
    }
    static internal var serverAddress: String? {
        get {
            return NSUserDefaults.standardUserDefaults().stringForKey("ZabbixServerAddress")
        }
        set {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setValue(newValue, forKey: "ZabbixServerAddress")
            userDefaults.synchronize()
        }
    }
    static internal var isValid: Bool {
        return ((ZabbixConfiguration.serverAddress != nil)&&(ZabbixConfiguration.password != nil)&&(ZabbixConfiguration.username != nil))
    }
    
    //MARK: - Private Methods
    
    static private func loadPassword() -> String? {
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "ZabbixPassword", kSecReturnData: kCFBooleanTrue]
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { cfPointer -> OSStatus in
            SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer(cfPointer))
        }
        if status != errSecSuccess {
            return nil
        }
        if let resultData = result as? NSData {
            return String(data: resultData, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
    
    static private func addPassword(value: String?) {
        let data = value!.dataUsingEncoding(NSUTF8StringEncoding)
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "ZabbixPassword", kSecValueData: data!]
        SecItemAdd(query as CFDictionaryRef, nil)
    }
    
    static private func updatePassword(value: String?) {
        if value != ZabbixConfiguration.password {
            guard value != nil else {
                return
            }
            let data = value!.dataUsingEncoding(NSUTF8StringEncoding)
            let searchQuery: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "ZabbixPassword"]
            let updateQuery: [NSObject: AnyObject] = [kSecValueData: data!]
            let status = SecItemUpdate(searchQuery as CFDictionaryRef, updateQuery as CFDictionaryRef)
            if status == errSecItemNotFound {
                ZabbixConfiguration.addPassword(value)
            }
        }
    }
}
