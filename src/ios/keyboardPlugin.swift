import Foundation
import UIKit
import WebKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {

    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        // 設置 WebView 中當前聚焦的輸入框的自定義鍵盤
        if let webView = self.webView as? WKWebView {
            addCustomKeyboardAccessory(to: webView)
        }

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 為 WebView 中的輸入框設置自定義工具欄
    func addCustomKeyboardAccessory(to webView: WKWebView) {
        // 構建自定義工具欄
        let doneToolbar: UIToolbar = UIToolbar()
        doneToolbar.sizeToFit()
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let minusButton = UIBarButtonItem(title: "－", style: .plain, target: self, action: #selector(minusButtonTapped))
        let doneButton = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneButtonTapped))
        
        doneToolbar.items = [minusButton, flexSpace, doneButton]
        
        // 設置所有 HTML 輸入框的輔助視圖
        let js = """
        (function() {
            var inputs = document.querySelectorAll('input[type="text"], input[type="number"]');
            for (var i = 0; i < inputs.length; i++) {
                inputs[i].blur(); // 暫時移除焦點以設置自定義輔助視圖
                inputs[i].focus(); // 恢復焦點以顯示鍵盤
            }
        })();
        """
        webView.evaluateJavaScript(js) { [weak self] _, error in
            if let error = error {
                print("Error evaluating JavaScript: \(error.localizedDescription)")
            } else {
                // 設置工具欄為輸入框的 inputAccessoryView
                webView.inputAccessoryView = doneToolbar
            }
        }
    }

    @objc func minusButtonTapped() {
        // 使用 JavaScript 在當前聚焦的 HTML 輸入框中插入 "-"
        let js = "document.activeElement.value += '-';"
        if let webView = self.webView as? WKWebView {
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }

    @objc func doneButtonTapped() {
        // 收起鍵盤
        let js = "document.activeElement.blur();"
        if let webView = self.webView as? WKWebView {
            webView.evaluateJavaScript(js, completionHandler: nil)
        }
    }
}
