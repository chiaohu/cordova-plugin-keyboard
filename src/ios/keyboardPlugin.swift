import Foundation
import Cordova

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
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
        self.minusButtonAction()
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Minus button pressed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(doneButtonAction:)
    func doneButtonAction(command: CDVInvokedUrlCommand) {
        // 處理 "確定" 按鈕點擊事件的 Swift 代碼
        self.doneButtonAction()
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Done button pressed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 你的 Swift 方法，包括 addDoneButtonOnKeyboard, minusButtonAction, doneButtonAction
    func addDoneButtonOnKeyboard() {
        // 在鍵盤上新增按鈕的代碼...
    }

    @objc func minusButtonAction() {
        if let currentText = self.numTxt.text {
            self.numTxt.text = currentText + "-"
        }
    }

    @objc func doneButtonAction() {
        self.numTxt.resignFirstResponder()
        print("done.....")
    }
}