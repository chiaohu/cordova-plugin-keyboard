import Foundation
import UIKit
import WebKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin, WKScriptMessageHandler {
    
    // 監聽 WKWebView 中的 JavaScript 消息
    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        // 註冊與 JavaScript 交互的處理
        if let webView = self.webView as? WKWebView {
            let contentController = webView.configuration.userContentController
            contentController.add(self, name: "minusButtonHandler")
        }

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 設置工具欄
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(minusButtonTapped))
        let doneButton = UIBarButtonItem(title: "確定", style: .done, target: self, action: #selector(doneButtonTapped))

        toolbar.items = [minusButton, flexSpace, doneButton]
        return toolbar
    }

    // 當「-」按鈕被按下時
    @objc func minusButtonTapped() {
        if let webView = self.webView as? WKWebView {
            let js = """
            var activeElement = document.activeElement;
            if (activeElement && activeElement.tagName === 'INPUT') {
                activeElement.value += '-';
                activeElement.focus();
            }
            """
            webView.evaluateJavaScript(js) { result, error in
                if let error = error {
                    print("Error adding minus: \(error.localizedDescription)")
                }
            }
        }
    }

    // 當「確定」按鈕被按下時
    @objc func doneButtonTapped() {
        if let webView = self.webView as? WKWebView {
            webView.endEditing(true) // 收起鍵盤
        }
    }

    // WKScriptMessageHandler: 處理 JavaScript 消息
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "minusButtonHandler" {
            // 在這裡你可以處理來自 JavaScript 的消息
        }
    }

    // 插件初始化時
    override func pluginInitialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        if let webView = self.webView as? WKWebView {
            // 查找當前的第一響應者 (輸入框)
            let js = """
            var activeElement = document.activeElement;
            if (activeElement && activeElement.tagName === 'INPUT') {
                window.webkit.messageHandlers.minusButtonHandler.postMessage(null);
            }
            """
            webView.evaluateJavaScript(js)
            
            // 查找目前的輸入框並設置工具欄
            for window in UIApplication.shared.windows {
                if let view = window.findFirstResponder() as? UITextField {
                    view.inputAccessoryView = createToolbar() // 添加工具欄
                    view.reloadInputViews() // 刷新輸入視圖以顯示工具欄
                }
            }
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        // 可以在此處處理鍵盤隱藏時的事件
    }
}

// UIView 擴展來查找第一響應者
extension UIView {
    func findFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
}
