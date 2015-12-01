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
    
    
    //MARK: -  Initializers
    init() {
        loadConfigugarion()
    }
    
    //MARK: - Instance varuables
    internal var username: String? = nil
    internal var password: String? = nil
    
    //MARK: - Public API
    
    internal func isEqual(conf: ZabbixConfiguration) -> Bool {
        if (conf.password != password) {
            return false
        }
        if (conf.username != username) {
            return false
        }
        return true
    }
    
    internal func saveConfiguration() {
        savePublicData()
        updatePassword()
    }
    
    internal func loadConfigugarion() {
        loadPublicData()
        loadPassword()
    }
    
    //MARK: - Private Methods
    private func getPersistentRefForPassword() -> (NSData?, status: OSStatus?){
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "ZabbixPassword", kSecReturnPersistentRef: kCFBooleanTrue]
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { cfPointer -> OSStatus in
            SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer(cfPointer))
        }
        if status != errSecSuccess {
            return (nil, status)
        }
        if let resultData = result as? NSData {
            return (resultData, nil)
        }
        return (nil, nil)
    }
    
    private func loadPassword() -> OSStatus? {
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "ZabbixPassword", kSecReturnData: kCFBooleanTrue]
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { cfPointer -> OSStatus in
            SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer(cfPointer))
        }
        if status != errSecSuccess {
            return (status)
        }
        if let resultData = result as? NSData {
            password = String(data: resultData, encoding: NSUTF8StringEncoding)
            return (nil)
        }
        return (nil)
    }
    
    private func addPassword() -> OSStatus {
        guard password != nil else {
            return errSecParam
        }
        let data = password!.dataUsingEncoding(NSUTF8StringEncoding)
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "ZabbixPassword", kSecValueData: data!]
        let status = SecItemAdd(query as CFDictionaryRef, nil)
        return status
    }
    
    private func updatePassword() -> OSStatus {
        guard password != nil else {
            return errSecParam
        }
        let data = password!.dataUsingEncoding(NSUTF8StringEncoding)
        let searchQuery: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "ZabbixPassword"]
        let updateQuery: [NSObject: AnyObject] = [kSecValueData: data!]
        let status = SecItemUpdate(searchQuery as CFDictionaryRef, updateQuery as CFDictionaryRef)
        if status == errSecItemNotFound {
            return addPassword()
        }
        return status
    }
    
    private func savePublicData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if username != nil {
            userDefaults.setValue(username!, forKey: "ZabbixUsername")
        }
        userDefaults.synchronize()
    }
    
    private func loadPublicData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        username = defaults.valueForKey("ZabbixUsername") as? String
    }

    
}
