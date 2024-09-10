import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    @objc(addMinusButton:)
    func addMinusButton(command: CDVInvokedUrlCommand) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        // Create a minus button
        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(self.minusButtonTapped))

        // Flexible space to push the button to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // Add the minus button to the toolbar
        toolbar.setItems([flexibleSpace, minusButton], animated: false)

        // Add the toolbar to the keyboard
        if let activeTextField = getActiveTextField(), activeTextField.isFirstResponder {
            activeTextField.inputAccessoryView = toolbar
            print("Input accessory view set for: \(activeTextField)")
        } else {
            print("Failed to set input accessory view.")
        }

        // Send a success callback to JavaScript
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc func minusButtonTapped() {
        if let activeTextField = getActiveTextField() {
            // Insert minus sign to the text field
            if let text = activeTextField.text {
                activeTextField.text = text + "-"
            }
        }
    }

    private func getActiveTextField() -> UITextField? {
        let keyWindow = UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    
        let activeTextField = keyWindow?.findFirstResponder() as? UITextField
        print("Active text field: \(String(describing: activeTextField))")  // 添加日誌輸出
        return activeTextField
    }
}

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
