import Foundation
import UIKit
import WebKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        guard let webView = self.webView as? WKWebView else {
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "WebView not found")
            self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        // 創建自定義工具欄
        let toolbar = createToolbar()
        
        // 找到 WebView 中的所有輸入框
        webView.evaluateJavaScript("document.querySelectorAll('input[type=number]').forEach(input => input.readOnly = true);", completionHandler: nil)
        
        // 遍歷 WebView 中的所有子視圖，查找 `UITextField` 或 `UITextView`
        for subview in webView.subviews {
            if let scrollView = subview as? UIScrollView {
                for textField in scrollView.subviews where textField is UITextField {
                    (textField as! UITextField).inputAccessoryView = toolbar
                }
            }
        }
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
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
        // 當 "-" 按鈕被按下時，通知 WebView 層
        notifyJSAboutMinusButton()
    }

    @objc func doneButtonAction() {
        // 收起鍵盤
        self.webView?.endEditing(true)
    }

    // 通知 JavaScript 關於 "-" 按鈕的點擊
    func notifyJSAboutMinusButton() {
        if let webView = self.webView as? WKWebView {
            let js = "window.dispatchEvent(new CustomEvent('minusButtonClicked'));"
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
    }

    // 初始化插件時設置監聽器
    override func pluginInitialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillHide(notification: Notification) {
        // 這裡可以添加額外的邏輯來處理鍵盤隱藏時的狀態
    }
}
