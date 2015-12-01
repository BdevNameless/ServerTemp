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

protocol VPNConfigurationDelegate {
    func VPNConfigurationChanged()
}

class VPNConfiguration {
    
    static let sharedInstance = VPNConfiguration()
    
    init() {
        loadPublicData()
    }
    
    internal var serverAddress: String? = nil {
        didSet {
            if (oldValue != serverAddress) {
                needsUpdate = true
            }
        }
    }
    internal var username: String? = nil {
        didSet {
            if (oldValue != username) {
                needsUpdate = true
            }
        }
    }
    internal var password: String? = nil {
        didSet {
            if (oldValue != password) {
                needsUpdate = true
            }
        }
    }
    internal var sharedKey: String? = nil {
        didSet {
            if (oldValue != sharedKey) {
                needsUpdate = true
            }
        }
    }
    internal var needsUpdate: Bool = false
    
    
    internal func saveConfiguration() {
        savePublicData()
    }
    
    private func savePublicData() {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if serverAddress != nil {
            userDefaults.setValue(serverAddress!, forKey: "VPNServerAddress")
        }
        if username != nil {
            userDefaults.setValue(username!, forKey: "VPNUsername")
        }
        userDefaults.synchronize()
    }
    
    private func loadPublicData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        serverAddress = defaults.valueForKey("VPNServerAddress") as? String
        username = defaults.valueForKey("VPNUsername") as? String
    }
    
    private func initkeychainFields() {
        
    }

}