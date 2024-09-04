import Foundation
import Cordova
import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    // 定義 numTxt 為 UITextField 類型
    var numTxt: UITextField?

    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        // 調用你的 Swift 方法來設置鍵盤
        self.addDoneButtonOnKeyboard() // 假設這是你設置鍵盤的 Swift 方法
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(minusButtonAction:)
    func minusButtonAction(command: CDVInvokedUrlCommand) {
        // 處理 "-" 按鈕點擊事件的 Swift 代碼
        if let textField = self.numTxt {
            let currentText = textField.text ?? ""
            textField.text = currentText + "-"
        }
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Minus button pressed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(doneButtonAction:)
    func doneButtonAction(command: CDVInvokedUrlCommand) {
        // 處理 "確定" 按鈕點擊事件的 Swift 代碼
        if let textField = self.numTxt {
            textField.resignFirstResponder()
        }
        
        print("done.....")
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Done button pressed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 你的 Swift 方法，包括 addDoneButtonOnKeyboard, minusButtonAction, doneButtonAction
    func addDoneButtonOnKeyboard() {
        // 創建一個新的 UITextField 並設置為插件的屬性
        self.numTxt = UITextField(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        self.numTxt?.borderStyle = .roundedRect
        
        // 添加鍵盤上的自定義按鈕
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "確定", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneButtonAction))
        let minusBtn: UIBarButtonItem = UIBarButtonItem(title: "-", style: UIBarButtonItem.Style.plain, target: self, action: #selector(minusButtonAction))

        var items = [UIBarButtonItem]()
        items.append(minusBtn) // 添加 "-" 按鈕
        items.append(flexSpace)
        items.append(doneBtn)  // 添加 "確定" 按鈕

        doneToolbar.items = items
        doneToolbar.sizeToFit()

        // 將工具欄設置為輸入框的輔助視圖
        self.numTxt?.inputAccessoryView = doneToolbar

        // 在插件中添加 UITextField，例如在視圖的頂部視圖
        self.webView?.addSubview(self.numTxt!)
    }
}
