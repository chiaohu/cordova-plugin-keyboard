import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    @objc(addMinusButton:)
    func addMinusButton(command: CDVInvokedUrlCommand) {
        // 監聽鍵盤顯示的通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // 傳送成功回調到 JavaScript
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    // 當鍵盤將要顯示時調用此方法
    @objc func keyboardWillShow(notification: NSNotification) {
        // 創建工具列並添加減號按鈕
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(self.minusButtonTapped))

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexibleSpace, minusButton], animated: false)

        // 檢查當前的第一響應者並添加工具列
        if let activeTextField = getActiveTextField() {
            activeTextField.inputAccessoryView = toolbar
            activeTextField.reloadInputViews() // 重新載入以顯示工具列
            print("Successfully added toolbar to active text field.")
        } else {
            print("No active text field found.")
        }
    }

    // 當按下減號按鈕時，將減號符號插入當前輸入框
    @objc func minusButtonTapped() {
        if let activeTextField = getActiveTextField() {
            activeTextField.text = (activeTextField.text ?? "") + "-"
        }
    }

    // 獲取當前的第一響應者（UITextField 或 UITextView）
    private func getActiveTextField() -> UIView? {
        // 遍歷視圖層級以查找第一響應者
        for window in UIApplication.shared.windows {
            if let responder = window.findFirstResponder() {
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
