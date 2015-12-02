//
//  TestConnectionViewController.swift
//  ServerTemp
//
//  Created by BdevNameless on 02.12.15.
//  Copyright © 2015 Nikita Karaulov. All rights reserved.
//

import UIKit
import NetworkExtension

class TestConnectionViewController: UIViewController {
    
    //MARK: - Outlents
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var connButton: UIButton!
    @IBAction func connButtonTapped(sender: UIButton) {
        
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        confugureVPN()
    }
    
    private func configureView() {
        view.backgroundColor = UIColor.blackColor()
        connButton.layer.borderWidth = 2.0
        connButton.layer.cornerRadius = 15.0
        connButton.layer.borderColor = UIColor.greenColor().CGColor
        textView.userInteractionEnabled = false
        textView.backgroundColor = UIColor.blackColor()
        textView.layer.borderWidth = 3.0
        textView.layer.borderColor = UIColor.greenColor().CGColor
        textView.text = ""
    }
    
    private func confugureVPN() {
        let manager = NEVPNManager.sharedManager()
        manager.loadFromPreferencesWithCompletionHandler() { [unowned self] (error: NSError?) in
            if error != nil {
                self.textView.text = self.textView.text + "\n>\(error)"
            }
            else{
                self.textView.text = self.textView.text + "\n>VPN MANAGER УСПЕШНО ЗАГРУЖЕН.\n>НАСТРАИВАЮ ПОДКЛЮЧЕНИЕ..."
                let configs = VPNConfiguration()
                let p = NEVPNProtocolIPSec()
                p.username = configs.username
                self.textView.text = self.textView.text + "\n>ИСПОЛЬЗУЮ ИМЯ ПОЛЬЗОВАТЕЛЯ: \(p.username)."
                let pwdRef = configs.getPersistentRefForPassword()
                if pwdRef.status == nil {
                    p.passwordReference = pwdRef.0
                    self.textView.text = self.textView.text + "\n>ПОЛУЧЕН УКАЗАТЕЛЬ НА ПАРОЛЬ ИЗ СВЯЗКИ"
                }
                else{
                    self.textView.text = self.textView.text + "\n>НЕ УДАЛОСЬ ПОЛУЧИТЬ УКАЗАТЕЛЬ НА ПАРОЛЬ ИЗ СВЯЗКИ. ERROR CODE: \(pwdRef.status)."
                }
                p.serverAddress = configs.serverAddress
                self.textView.text = self.textView.text + "\n>ИСПОЛЬЗУЮ АДРЕС СЕРВЕРА: \(p.serverAddress)."
                p.authenticationMethod = .SharedSecret
                let shsRef = configs.getPersistentRefForSharedKey()
                if shsRef.status == nil {
                    p.sharedSecretReference = shsRef.0
                    self.textView.text = self.textView.text + "\n>ПОЛУЧЕН УКАЗАТЕЛЬ НА ОБЩИЙ СЕКРЕТ ИЗ СВЯЗКИ"
                }
                else{
                    self.textView.text = self.textView.text + "\n>НЕ УДАЛОСЬ ПОЛУЧИТЬ УКАЗАТЕЛЬ НА ОБЩИЙ СЕКРЕТ ИЗ СВЯЗКИ. ERROR CODE: \(shsRef.status)."
                }
                p.disconnectOnSleep = false
                p.useExtendedAuthentication = true
                manager.protocolConfiguration = p
                manager.localizedDescription = "МОЙ УЮТНЫЙ VPN"
                self.textView.text = self.textView.text + "\n>ПРОТОКОЛ СКОНФИГУРИРОВАН. СОХРАНЯЮ НАСТРОЙКИ..."
                manager.saveToPreferencesWithCompletionHandler() { [unowned self] (error: NSError?) in
                    if error != nil {
                        self.textView.text = self.textView.text + "\n>\(error)"
                    }
                    else{
                        self.textView.text = self.textView.text + "\nНАСТРОЙКИ УСПЕШНО СОХРАНЕНЫ.\n>⬆︎JUST TAP THIS FCKING BUTTON⬆︎"
                    }
                }
                
            }
        }
    }
    
}
