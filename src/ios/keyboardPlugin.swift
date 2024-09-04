import Foundation
import Cordova
import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    // 定義透明的 UITextField
    var transparentTextField: UITextField?

    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        // 創建透明的 UITextField
        if transparentTextField == nil {
            setupTransparentTextField()
        }
        
        // 將焦點設置到透明的 UITextField
        transparentTextField?.becomeFirstResponder()
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 初始化透明的 UITextField 並設置工具欄
    func setupTransparentTextField() {
        transparentTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.webView!.frame.width, height: 40))
        transparentTextField?.backgroundColor = UIColor.clear
        transparentTextField?.textColor = UIColor.clear
        transparentTextField?.tintColor = UIColor.clear
        transparentTextField?.keyboardType = .numberPad
        transparentTextField?.inputAccessoryView = createToolbar() // 設置自定義工具欄
        
        // 將透明的 UITextField 添加到 WebView 的上層
        self.webView?.addSubview(transparentTextField!)
    }

    // 創建工具欄
    func createToolbar() -> UIToolbar {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let minusBtn: UIBarButtonItem = UIBarButtonItem(title: "-", style: UIBarButtonItem.Style.plain, target: self, action: #selector(minusButtonAction))
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "確定", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))
        
        var items = [UIBarButtonItem]()
        items.append(minusBtn) // 添加 "-" 按鈕
        items.append(flexSpace)
        items.append(doneBtn)  // 添加 "確定" 按鈕
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        return doneToolbar
    }

    @objc func minusButtonAction() {
        // 確保當前有輸入框處於焦點狀態
        if let textField = transparentTextField {
            let currentText = textField.text ?? ""
            textField.text = currentText + "-"
        }
    }

    @objc func doneButtonAction() {
        // 收起鍵盤並隱藏透明的 UITextField
        hideTransparentTextField()
    }

    // 隱藏並移除透明的 UITextField
    func hideTransparentTextField() {
        if let textField = transparentTextField {
            textField.resignFirstResponder()
            textField.removeFromSuperview()
            transparentTextField = nil
        }
    }

    // 初始化插件時設置監聽器
    override func pluginInitialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillHide(notification: Notification) {
        // 當鍵盤隱藏時，也隱藏透明的 UITextField
        hideTransparentTextField()
    }
}
