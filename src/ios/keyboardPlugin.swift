import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {

    @objc(addMinusButton:)
    func addMinusButton(command: CDVInvokedUrlCommand) {
        // 監聽鍵盤顯示通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        // 傳送成功回調到 JavaScript
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        // 創建工具列並添加減號按鈕
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(self.minusButtonTapped))

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexibleSpace, minusButton], animated: false)

        // 獲取第一響應者，並確保它是 UITextField 或 UITextView
        if let activeInput = getActiveInputField() {
            activeInput.inputAccessoryView = toolbar
            activeInput.reloadInputViews() // 重新加載輸入視圖以顯示工具列
            print("Successfully added toolbar to active input field.")
        } else {
            print("No active text field found.")
        }
    }

    @objc func minusButtonTapped() {
        // 獲取當前第一響應者，並確保它是 UITextField 或 UITextView
        if let activeInput = getActiveInputField() {
            // 插入減號符號
            if var text = activeInput.text {
                text += "-"
                activeInput.text = text
            }
        }
    }

    // 查找當前活動的 UITextField 或 UITextView
    private func getActiveInputField() -> (UIView & UITextInput)? {
        for window in UIApplication.shared.windows {
            if let responder = window.findFirstResponder() as? (UIView & UITextInput) {
                return responder
            }
        }
        return nil
    }
}

// 擴展 UIView 來查找當前的第一響應者
extension UIView {
    func findFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        for subview in self.subviews {
            if let responder = subview.findFirstResponder() {
                return responder
            }
        }
        return nil
    }
}
