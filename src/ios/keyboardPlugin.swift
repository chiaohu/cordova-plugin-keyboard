import Foundation
import UIKit
import WebKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    // 定義工具欄
    var doneToolbar: UIToolbar!

    override func pluginInitialize() {
        super.pluginInitialize()
        setupToolbar()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // 設置工具欄
    func setupToolbar() {
        doneToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.webView!.frame.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let minusBtn = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(minusButtonAction))
        let doneBtn = UIBarButtonItem(title: "確定", style: .done, target: self, action: #selector(doneButtonAction))

        doneToolbar.items = [minusBtn, flexSpace, doneBtn]
        doneToolbar.sizeToFit()

        // 將工具欄添加到 WebView 的父視圖中
        if let webView = self.webView as? WKWebView {
            webView.superview?.addSubview(doneToolbar)
            adjustToolbarPosition()
        }
    }

    @objc func minusButtonAction() {
        // 處理 "-" 按鈕點擊事件
        print("Minus button pressed")
        if let webView = self.webView as? WKWebView {
            let js = """
            (function() {
                var inputs = document.querySelectorAll('input[type="text"], input[type="number"]');
                for (var i = 0; i < inputs.length; i++) {
                    var input = inputs[i];
                    if (document.activeElement === input) {
                        input.value += '-';
                        input.focus();
                    }
                }
            })();
            """
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
    }

    @objc func doneButtonAction() {
        // 隱藏工具欄
        hideToolbar()
        if let webView = self.webView as? WKWebView {
            let js = "document.activeElement.blur();"
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
    }

    // 隱藏工具欄
    func hideToolbar() {
        doneToolbar.removeFromSuperview()
    }

    // 當鍵盤顯示時調整工具欄位置
    @objc func keyboardWillShow(notification: Notification) {
        adjustToolbarPosition()
    }

    // 當鍵盤隱藏時隱藏工具欄
    @objc func keyboardWillHide(notification: Notification) {
        hideToolbar()
    }

    // 調整工具欄的位置
    func adjustToolbarPosition() {
        if let webView = self.webView as? WKWebView {
            let keyboardHeight = getKeyboardHeight()
            let toolbarHeight = doneToolbar.frame.height
            let webViewBottom = webView.frame.height
            let toolbarY = webViewBottom - keyboardHeight - toolbarHeight
            
            doneToolbar.frame = CGRect(x: 0, y: toolbarY, width: webView.frame.width, height: toolbarHeight)
        }
    }

    // 獲取鍵盤的高度（此處應根據需要實現）
    func getKeyboardHeight() -> CGFloat {
        // 這裡返回一個固定值，根據實際情況修改
        return 250
    }
}
