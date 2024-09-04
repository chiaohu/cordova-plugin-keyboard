import Foundation
import UIKit
import WebKit // 確保導入 WebKit 以使用 WKWebView

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin, UITextFieldDelegate {
    
    // 定義容器視圖和透明的 UITextField
    var keyboardContainerView: UIView?
    var transparentTextField: UITextField?

    @objc(addMinusButtonToKeyboard:)
    func addMinusButtonToKeyboard(command: CDVInvokedUrlCommand) {
        // 創建透明的 UITextField 和容器視圖
        if keyboardContainerView == nil {
            setupKeyboardContainerView()
        }
        
        // 將焦點設置到透明的 UITextField
        transparentTextField?.becomeFirstResponder()
        
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Keyboard setup completed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 初始化容器視圖和透明的 UITextField
    func setupKeyboardContainerView() {
        // 創建容器視圖
        keyboardContainerView = UIView(frame: CGRect(x: 0, y: self.webView!.frame.height - 40, width: self.webView!.frame.width, height: 40))
        keyboardContainerView?.backgroundColor = UIColor.clear
        
        // 創建透明的 UITextField
        transparentTextField = UITextField(frame: CGRect(x: 0, y: 0, width: keyboardContainerView!.frame.width, height: 40))
        transparentTextField?.backgroundColor = UIColor.clear
        transparentTextField?.textColor = UIColor.clear
        transparentTextField?.tintColor = UIColor.clear
        transparentTextField?.keyboardType = .numberPad
        transparentTextField?.delegate = self // 設置代理
        transparentTextField?.inputAccessoryView = createToolbar() // 設置自定義工具欄
        
        // 將透明的 UITextField 添加到容器視圖
        keyboardContainerView?.addSubview(transparentTextField!)
        
        // 將容器視圖添加到 WebView 的上層
        self.webView?.addSubview(keyboardContainerView!)
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
        // 在透明的 UITextField 中插入 "-"
        if let textField = transparentTextField {
            let currentText = textField.text ?? ""
            textField.text = currentText + "-"
            updateWebViewInputField(text: textField.text!)
        }
    }

    @objc func doneButtonAction() {
        // 收起鍵盤並隱藏透明的 UITextField 和容器視圖
        hideKeyboardContainerView()
    }

    // 隱藏並移除透明的 UITextField 和容器視圖
    func hideKeyboardContainerView() {
        if let containerView = keyboardContainerView {
            transparentTextField?.resignFirstResponder()
            containerView.removeFromSuperview()
            keyboardContainerView = nil
            transparentTextField = nil
        }
    }

    // 當透明的 UITextField 輸入變化時調用此方法
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        updateWebViewInputField(text: updatedText)
        return true
    }

    // 更新 WebView 中的 HTML 輸入框
    func updateWebViewInputField(text: String) {
        if let webView = self.webView as? WKWebView {
            // 使用 JavaScript 設置 HTML 輸入框的值並保持焦點
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: Notification) {
        // 調整容器視圖的位置，以避免被鍵盤遮擋
        adjustKeyboardContainerPosition()
    }

    @objc func keyboardWillHide(notification: Notification) {
        // 當鍵盤隱藏時，也隱藏透明的 UITextField 和容器視圖
        hideKeyboardContainerView()
    }

    // 調整容器視圖的位置
    func adjustKeyboardContainerPosition() {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            // 將容器視圖放置在鍵盤上方
            let newY = self.webView!.frame.height - keyboardFrame.height - 40
            keyboardContainerView?.frame.origin.y = newY
        }
    }
}
