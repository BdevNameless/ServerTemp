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

enum VPNError: ErrorType {
    case ErrorWhileStartingVPNTunnel(error: NEVPNError)
    case InvalidVPNConfoguration
}

class VPNConfiguration {
    
    
    //MARK: -  Initializers
    init(_ loadConfig: Bool = false) {
        if loadConfig {
            loadConfigugarion()
        }
    }
    
    //MARK: - Private instance varuables
    private let manager = NEVPNManager.sharedManager()
    private var needToSave = false
    
    //MARK: - Internal instance varuables
    internal var managerEnabled: Bool {
        get {
            return manager.enabled
        }
        set {
            manager.enabled = newValue
            needToSave = true
        }
    }
    
    internal var connectionStatus: NEVPNStatus {
        get {
            return manager.connection.status
        }
    }
    
    internal var serverAddress: String? {
        get {
            return manager.protocolConfiguration?.serverAddress
        }
        set {
            manager.protocolConfiguration?.serverAddress = newValue
            needToSave = true
        }
    }
    
    internal var groupName: String? {
        get {
            let ipsecP = manager.protocolConfiguration as? NEVPNProtocolIPSec
            return ipsecP?.localIdentifier
        }
        set {
            let ipsecP = manager.protocolConfiguration as? NEVPNProtocolIPSec
            ipsecP?.localIdentifier = newValue
            needToSave = true
        }
    }
    
    internal var username: String? {
        get {
            return manager.protocolConfiguration?.username
        }
        set {
            manager.protocolConfiguration?.username = newValue
            needToSave = true
        }
    }
    
    internal var password: String? {
        get {
            return loadKeyForAccount("VPNPassword")
        }
        set {
            updatePassword(newValue)
            needToSave = true
        }
    }
    
    internal var sharedKey: String? {
        get {
            return loadKeyForAccount("VPNSharedKey")
        }
        set {
            updateSharedKey(newValue)
            needToSave = true
        }
    }
    
    //MARK: - Public API
    
    internal func saveConfiguration(handler: ((error: NSError?) -> Void)? = nil) {
        if needToSave {
            let p = manager.protocolConfiguration as! NEVPNProtocolIPSec
            let shsRef = getPersistentRefForSharedKey()
            if shsRef.status == nil {
                p.sharedSecretReference = shsRef.0
            }
            let pwdRef = getPersistentRefForPassword()
            if pwdRef.status == nil {
                p.passwordReference = pwdRef.0
            }
            let saveQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0)
            let saveGroup = dispatch_group_create()
            dispatch_async(saveQueue, { [unowned self] in
                dispatch_group_enter(saveGroup)
                self.manager.saveToPreferencesWithCompletionHandler() { [unowned self] (saveError: NSError?) in
                    if saveError == nil {
                        print("VPN PREFERENCES SECSESSFULY SAVED")
                        self.needToSave = false
                    }
                    else {
                        print("ERROR WHILE SAVING VPN PREFERENCES : \(saveError)")
                    }
                    if handler != nil {
                        handler!(error: saveError)
                    }
                    dispatch_group_leave(saveGroup)
                }
            })
            dispatch_group_wait(saveGroup, DISPATCH_TIME_FOREVER)
            return
//            manager.saveToPreferencesWithCompletionHandler() { [unowned self] (saveError: NSError?) in
//                if saveError == nil {
//                    print("VPN PREFERENCES SECSESSFULY SAVED")
//                    self.needToSave = false
//                }
//                else {
//                    print("ERROR WHILE SAVING VPN PREFERENCES : \(saveError)")
//                }
//                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
//                dispatch_after(delayTime, dispatch_get_main_queue()) {
//                    if handler != nil {
//                        handler!(error: saveError)
//                    }
//                }
//            }
        }
        else {
            if handler != nil {
                handler!(error: nil)
            }
        }
    }
    
    internal func loadConfigugarion(handler: ((error: NSError?) -> Void)? = nil) {
        manager.loadFromPreferencesWithCompletionHandler() { [unowned self] (error: NSError?) in
            if (error == nil) {
                print("VPN PREFERENCES HAVE BEEN LOADED \(NSDate())")
                if (self.manager.protocolConfiguration == nil) {
                    print("NEW VPN PROTOCOL CONFIGURATION CREATED")
                    let p = NEVPNProtocolIPSec()
                    p.authenticationMethod = .SharedSecret
                    p.disconnectOnSleep = false
                    p.useExtendedAuthentication = true
                    self.manager.protocolConfiguration = p
                }
                if handler != nil {
                    handler!(error: nil)
                }
            }
            else {
                print("ERROR WHILE LOADING VPN PREFERENCES: \(error)")
                if handler != nil {
                    handler!(error: error)
                }
            }
        }
    }
    
    internal func removeConfiguration(handler: ((error: NSError?) -> Void)? = nil) {
        manager.removeFromPreferencesWithCompletionHandler() { (remError: NSError?) in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [unowned self] in
                if remError == nil {
                    print("VPN PREFERENCES REMOVED")
                    self.flushKeychain()
                }
                else {
                    print("ERROR WHILE REMOVING VPN PREFERENCES. ERROR : \(remError)")
                }
                if let action = handler {
                    action(error: remError)
                }
            }
        }
    }
    
    internal func testConnection() throws {
        if needToSave {
            saveConfiguration()
        }
        NSTimer.init(timeInterval: 0.8 * Double(NSEC_PER_SEC), target: self, selector: #selector(VPNConfiguration.startVPN), userInfo: nil, repeats: false).fire()
//        saveConfiguration() { [unowned self] (error: NSError?) in
//            if error == nil {
//                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.8 * Double(NSEC_PER_SEC)))
//                dispatch_after(delayTime, dispatch_get_main_queue()) {
//                    try! self.startVPN()
//                }
//            }
//        }
    }
    
    @objc internal func startVPN() throws {
        guard connectionStatus != .Invalid else {
            throw VPNError.InvalidVPNConfoguration
        }
        
        print("TRY STARTING VPN TUNNEL")
        let statuses: Set<NEVPNStatus> = [.Disconnected, .Disconnecting]
        if statuses.contains(manager.connection.status) {
            do {
                try manager.connection.startVPNTunnel()
                print("STARTING VPN TUNNEL")
            }
            catch let error as NEVPNError {
                throw VPNError.ErrorWhileStartingVPNTunnel(error: error)
            }
        }
        else {
            print("VPN tunnel is already up.")
        }
    }
    
    internal func stopVPN() {
        let statuses: Set<NEVPNStatus> = [.Connected, .Connecting, .Reasserting]
        if statuses.contains(manager.connection.status) {
            print("STOPPING VPN TUNNEL")
            manager.connection.stopVPNTunnel()
        }
        else {
            print("VPN tunnel is already down")
        }
    }
    
    
    //MARK: - Private Methods
    private func flushKeychain() {
        let sharedQuery:[NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "VPNSharedKey"]
        let pwdQuery:[NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: "VPNPassword"]
        let s_status = SecItemDelete(sharedQuery)
        if s_status == 0 {
            print("VPN SHARED KEY FLUSHED")
        }
        else {
            print("ERROR WHILE FLUSHING VPN SHARED KEY : \(s_status)")
        }
        let p_status = SecItemDelete(pwdQuery)
        if p_status == 0 {
            print("VPN PASSWORD FLUSHED")
        } else {
            print("ERROR WHILE FLISHING VPN PASSWORD : \(p_status)")
        }
    }
    
    private func getPersistentRefForSharedKey() -> (NSData?, status: OSStatus?) {
        return self.getPersistentRefForKey("VPNSharedKey")
    }
    
    private func getPersistentRefForPassword() -> (NSData?, status: OSStatus?){
        return self.getPersistentRefForKey("VPNPassword")
    }
    
    private func getPersistentRefForKey(key: String) -> (NSData?, status: OSStatus?) {
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key, kSecReturnPersistentRef: kCFBooleanTrue]
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
    
    private func loadKeyForAccount(account: String) -> String? {
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: account, kSecReturnData: kCFBooleanTrue]
        var result: AnyObject?
        let status = withUnsafeMutablePointer(&result) { cfPointer -> OSStatus in
            SecItemCopyMatching(query as CFDictionaryRef, UnsafeMutablePointer(cfPointer))
        }
        if status != errSecSuccess {
            print("ERROR WHILE LOADING \(account) KEY : \(status)")
            return nil
        }
        if let resultData = result as? NSData {
            return String(data: resultData, encoding: NSUTF8StringEncoding)
        }
        return nil
    }
    
//    private func addSharedKey(sharedKey: String?) {
//        addGenericPassword(sharedKey, forKey: "VPNSharedKey")
//    }
//    
//    private func addPassword(pwd: String?) {
//        addGenericPassword(pwd, forKey: "VPNPassword")
//    }
    
    private func addGenericPassword(value: String?, forKey key: String!) {
        let data = value?.dataUsingEncoding(NSUTF8StringEncoding)
        let query: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key, kSecValueData: data!]
        let status = SecItemAdd(query as CFDictionaryRef, nil)
        if (status != errSecSuccess) {
            switch key {
            case "VPNPassword":
                print("ERROR WHILE ADDING NEW VPN PASSWORD : \(status)")
                break
            case "VPNSharedKey":
                print("ERROR WHILE ADDING NEW SHARED KEY : \(status)")
                break
            default:
                break
            }
        }
        
    }
    
    private func updateSharedKey(value: String?) {
        if value != sharedKey {
            updateGenericPassword(value, forKey: "VPNSharedKey")
        }
    }
    
    private func updatePassword(value: String?) {
        if value != password {
            updateGenericPassword(value, forKey: "VPNPassword")
        }
    }
    
    private func updateGenericPassword(value: String?, forKey key: String!) {
        guard value != nil else {
            print("ERROR WHILE UPDATING \(key). VALUE MUST NOT BE NIL.")
            return
        }
        let data = value!.dataUsingEncoding(NSUTF8StringEncoding)
        let searchQuery: [NSObject: AnyObject] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: key]
        let updateQuery: [NSObject: AnyObject] = [kSecValueData: data!]
        let status = SecItemUpdate(searchQuery as CFDictionaryRef, updateQuery as CFDictionaryRef)
        if status == errSecItemNotFound {
            print("NO \(key) FOUND. CREATING NEW ONE.")
            addGenericPassword(value, forKey: key)
        }
        else if (status != errSecSuccess){
            print("ERROR WHILE UPDATING \(key): \(status)")
        }
    }
    
    private func savePublicData() {
        let p = manager.protocolConfiguration as! NEVPNProtocolIPSec
        let shsRef = getPersistentRefForSharedKey()
        if shsRef.status == nil {
            p.sharedSecretReference = shsRef.0
        }
        let pwdRef = getPersistentRefForPassword()
        if pwdRef.status == nil {
            p.passwordReference = pwdRef.0
        }
        manager.saveToPreferencesWithCompletionHandler() { (error: NSError?) in
            if error == nil {
                print("VPN PREFERENCES SECSESSFULY SAVED")
            }
            else {
                print("ERROR WHILE SAVING VPN PREFERENCES : \(error)")
            }
        }
    }
}