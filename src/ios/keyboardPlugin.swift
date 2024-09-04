import Foundation
import UIKit
import WebKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin, UITextFieldDelegate {

    var transparentTextField: UITextField?

    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        if transparentTextField == nil {
            setupTransparentTextField()
        }

        // 使用 DispatchQueue 確保鍵盤和工具欄正確顯示
        DispatchQueue.main.async {
            self.transparentTextField?.becomeFirstResponder()
        }

        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    func setupTransparentTextField() {
        transparentTextField = UITextField(frame: CGRect(x: 0, y: 0, width: self.webView!.frame.width, height: 40))
        transparentTextField?.backgroundColor = UIColor.clear
        transparentTextField?.textColor = UIColor.clear
        transparentTextField?.tintColor = UIColor.clear
        transparentTextField?.keyboardType = .numberPad
        transparentTextField?.delegate = self
        transparentTextField?.inputAccessoryView = createToolbar()
    }

    func createToolbar() -> UIToolbar {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle = UIBarStyle.default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let minusBtn = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(minusButtonAction))
        let doneBtn = UIBarButtonItem(title: "確定", style: .done, target: self, action: #selector(doneButtonAction))

        doneToolbar.items = [minusBtn, flexSpace, doneBtn]
        doneToolbar.sizeToFit()

        return doneToolbar
    }

    @objc func minusButtonAction() {
        if let textField = transparentTextField {
            let currentText = textField.text ?? ""
            textField.text = currentText + "-"
            updateWebViewInputField(text: textField.text!)
        }
    }

    @objc func doneButtonAction() {
        hideTransparentTextField()

        // 設置 WebView 焦點
        if let webView = self.webView as? WKWebView {
            let js = "document.activeElement.blur(); setTimeout(function() { document.activeElement.focus(); }, 100);"
            webView.evaluateJavaScript(js)
        }
    }

    func hideTransparentTextField() {
        if let textField = transparentTextField {
            textField.resignFirstResponder()
            textField.removeFromSuperview()
            transparentTextField = nil
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)

        updateWebViewInputField(text: updatedText)
        return true
    }

    func updateWebViewInputField(text: String) {
        if let webView = self.webView as? WKWebView {
            let escapedText = text.replacingOccurrences(of: "'", with: "\\'")
            let js = """
            var activeElement = document.activeElement;
            if (activeElement && activeElement.tagName === 'INPUT') {
                activeElement.value = '\(escapedText)';
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

    override func pluginInitialize() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillHide(notification: Notification) {
        hideTransparentTextField()
    }
}
