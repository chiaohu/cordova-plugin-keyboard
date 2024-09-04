import Foundation
import Cordova
import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    // 定義變量來存儲輸入框的引用
    var currentInputField: UITextField?

    @objc(addMinusButtonToKeyboard:)
    print("addMinusButtonToKeyboard called") // 添加日誌
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        // 為當前焦點輸入框設置自定義鍵盤
        addDoneButtonOnKeyboard()
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 設置鍵盤上的自定義按鈕
    func addDoneButtonOnKeyboard() {
        print("Setting up custom toolbar for keyboard") // 添加日誌
        // 創建自定義工具欄
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

        // 將工具欄設置為當前輸入框的輔助視圖
        if let textField = currentInputField {
            textField.inputAccessoryView = doneToolbar
        }
    }

    @objc func minusButtonAction() {
        // 確保當前有輸入框處於焦點狀態
        if let textField = currentInputField {
            let currentText = textField.text ?? ""
            textField.text = currentText + "-"
        }
    }

    @objc func doneButtonAction() {
        // 收起鍵盤
        if let textField = currentInputField {
            textField.resignFirstResponder()
        }
    }

    // 監聽輸入框聚焦事件並設置鍵盤
    override func pluginInitialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        // 檢查當前焦點的元素是否為輸入框
        if let activeField = self.webView?.findFirstResponder() as? UITextField {
            self.currentInputField = activeField
            self.addDoneButtonOnKeyboard() // 為當前輸入框添加自定義工具欄
        }
    }
}

// 擴展 WKWebView 來查找當前的第一響應者
extension UIView {
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subView in self.subviews {
            if let firstResponder = subView.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
}
