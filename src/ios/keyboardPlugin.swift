import Foundation
import UIKit
import WebKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin, UITextFieldDelegate {
    
    // UITextField 用於顯示鍵盤
    var activeTextField: UITextField?
    
    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        // 創建一個新的 UITextField 並設置工具欄
        if activeTextField == nil {
            setupActiveTextField()
        }

        // 將焦點設置到 UITextField
        activeTextField?.becomeFirstResponder()

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 初始化 UITextField 並設置工具欄
    func setupActiveTextField() {
        activeTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.webView!.frame.width, height: 40))
        activeTextField?.backgroundColor = UIColor.clear
        activeTextField?.textColor = UIColor.clear
        activeTextField?.tintColor = UIColor.clear
        activeTextField?.keyboardType = .numberPad
        activeTextField?.delegate = self // 設置代理
        activeTextField?.inputAccessoryView = createToolbar() // 設置自定義工具欄
        self.webView?.addSubview(activeTextField!)
    }

    // 創建工具欄，新增 "-" 按鈕
    func createToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        toolbar.barStyle = UIBarStyle.default

        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(minusButtonAction))
        let doneButton = UIBarButtonItem(title: "確定", style: .done, target: self, action: #selector(doneButtonAction))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.items = [minusButton, flexSpace, doneButton]
        toolbar.sizeToFit()

        return toolbar
    }

    @objc func minusButtonAction() {
        // 在 TextField 中插入 "-"
        if let textField = activeTextField {
            let currentText = textField.text ?? ""
            textField.text = currentText + "-"
            updateWebViewInputField(text: textField.text!)
        }
    }

    @objc func doneButtonAction() {
        // 收起鍵盤
        if let textField = activeTextField {
            textField.resignFirstResponder()
        }
    }

    // 當 UITextField 輸入變化時調用此方法
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        updateWebViewInputField(text: updatedText)
        return true
    }

    // 更新 WebView 中的 HTML 輸入框
    func updateWebViewInputField(text: String) {
        if let webView = self.webView as? WKWebView {
            let js = """
            var activeElement = document.activeElement;
            if (activeElement && activeElement.tagName === 'INPUT') {
                activeElement.value = '\(text)';
                activeElement.focus();
            }
            """
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
        // 當鍵盤隱藏時，清空 activeTextField
        if let textField = activeTextField {
            textField.resignFirstResponder()
            textField.removeFromSuperview()
            activeTextField = nil
        }
    }
}
