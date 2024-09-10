import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {

    @objc(addMinusButton:)
    func addMinusButton(command: CDVInvokedUrlCommand) {
        // 創建工具列並添加減號按鈕
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(self.minusButtonTapped))

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexibleSpace, minusButton], animated: false)

        // 檢查當前是否有活動的輸入框，並添加工具列
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if let activeTextField = self.getActiveTextField(), activeTextField.isFirstResponder {
                activeTextField.inputAccessoryView = toolbar
                activeTextField.reloadInputViews()
                print("Successfully added toolbar to active text field.")
            } else {
                print("No active text field found to attach the toolbar.")
            }
        }

        // 傳送成功結果回 JS
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc func minusButtonTapped() {
        if let activeTextField = getActiveTextField() {
            activeTextField.text = (activeTextField.text ?? "") + "-"
        }
    }

    private func getActiveTextField() -> UITextField? {
        for window in UIApplication.shared.windows {
            if let activeTextField = findActiveTextField(in: window) {
                return activeTextField
            }
        }
        return nil
    }

    private func findActiveTextField(in view: UIView) -> UITextField? {
        for subview in view.subviews {
            if let textField = subview as? UITextField, textField.isFirstResponder {
                return textField
            } else if let found = findActiveTextField(in: subview) {
                return found
            }
        }
        return nil
    }
}
