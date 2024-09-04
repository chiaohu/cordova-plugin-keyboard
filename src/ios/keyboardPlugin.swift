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

        // 通過 JavaScript 來設置輸入框為只讀，然後調用 JavaScript 來處理 "-" 按鈕的輸入
        let jsCode = """
        document.querySelectorAll('input[type=number]').forEach(input => {
            input.readOnly = true;
            input.addEventListener('focus', function() {
                window.webkit.messageHandlers.keyboardHandler.postMessage('showMinusButton');
            });
        });
        """

        webView.evaluateJavaScript(jsCode) { _, error in
            if let error = error {
                print("Error setting up JavaScript handlers: \(error.localizedDescription)")
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "JavaScript setup failed")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            } else {
                let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
                self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }

    @objc func showMinusButton() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let minusAction = UIAlertAction(title: "-", style: .default) { _ in
            self.notifyJSAboutMinusButton()
        }
        let doneAction = UIAlertAction(title: "完成", style: .cancel) { _ in
            self.webView?.endEditing(true)
        }
        
        alertController.addAction(minusAction)
        alertController.addAction(doneAction)

        // 顯示操作表
        self.viewController?.present(alertController, animated: true, completion: nil)
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
        // 設置 JavaScript 的回調處理
        if let webView = self.webView as? WKWebView {
            let contentController = webView.configuration.userContentController
            contentController.add(self, name: "keyboardHandler")
        }
    }

    @objc func keyboardWillHide(notification: Notification) {
        // 鍵盤隱藏時的操作（如果需要）
    }
}

extension KeyboardPlugin: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "keyboardHandler", message.body as? String == "showMinusButton" {
            self.showMinusButton()
        }
    }
}
