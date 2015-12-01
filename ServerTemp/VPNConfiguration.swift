//
//  VPNConfiguration.swift
//  ServerTemp
//
//  Created by BdevNameless on 01.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import Foundation
import Security
import NetworkExtension

class VPNConfiguration {
    
    
    //MARK: -  Initializers
    init() {
        loadConfigugarion()
    }
    
    //MARK: - Instance varuables
    internal var serverAddress: String? = nil
    internal var username: String? = nil
    internal var password: String? = nil
    internal var sharedKey: String? = nil
    internal var groupName: String? = nil
    
    //MARK: - Public API
    
    internal func isEqual(conf: VPNConfiguration) -> Bool {
        if (conf.serverAddress != serverAddress) {
            return false
        }
        if (conf.password != password) {
            return false
        }
        if (conf.username != username) {
            return false
        }
        if (conf.sharedKey != sharedKey) {
            return false
        }
        if (conf.groupName != groupName) {
            return false
        }
        return true
    }
    
    internal func saveConfiguration() {
        savePublicData()
        updateSharedKey()
    }
    
    internal func loadConfigugarion() {
        loadPublicData()
        loadSharedKey()
    }
    
    //MARK: - Private Methods
    private func getPersistentRefForSharedKey() -> (NSData?, status: OSStatus?) {
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrLabel: "VPNSharedKey", kSecReturnPersistentRef: kCFBooleanTrue]
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
    
    private func loadSharedKey() -> OSStatus? {
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrLabel: "VPNSharedKey", kSecReturnData: kCFBooleanTrue]
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { cfPointer -> OSStatus in
            SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer(cfPointer))
        }
        if status != errSecSuccess {
            return (status)
        }
        if let resultData = result as? NSData {
            sharedKey = String(data: resultData, encoding: NSUTF8StringEncoding)
            return (nil)
        }
        return (nil)
    }
    
    private func addSharedKey() -> OSStatus {
        guard sharedKey != nil else {
            return errSecParam
        }
        let data = sharedKey!.dataUsingEncoding(NSUTF8StringEncoding)
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrLabel: "VPNSharedKey", kSecValueData: data!]
        let status = SecItemAdd(query as CFDictionaryRef, nil)
        return status
    }
    
    private func updateSharedKey() -> OSStatus {
        guard sharedKey != nil else {
            return errSecParam
        }
        let data = sharedKey!.dataUsingEncoding(NSUTF8StringEncoding)
        let searchQuery: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrLabel: "VPNSharedKey"]
        let updateQuery: [NSObject: AnyObject] = [kSecValueData: data!]
        let status = SecItemUpdate(searchQuery as CFDictionaryRef, updateQuery as CFDictionaryRef)
        if status == errSecItemNotFound {
            return addSharedKey()
        }
        return status
    }
    
    private func savePublicData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if serverAddress != nil {
            userDefaults.setValue(serverAddress!, forKey: "VPNServerAddress")
        }
        if username != nil {
            userDefaults.setValue(username!, forKey: "VPNUsername")
        }
        if groupName != nil {
            userDefaults.setValue(groupName!, forKey: "VPNGroupName")
        }
        userDefaults.synchronize()
    }
    
    private func loadPublicData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        serverAddress = defaults.valueForKey("VPNServerAddress") as? String
        username = defaults.valueForKey("VPNUsername") as? String
        groupName = defaults.valueForKey("VPNGroupName") as? String
    }
    
}