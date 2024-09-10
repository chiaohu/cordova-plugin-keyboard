import UIKit

@objc(KeyboardMinus) class KeyboardMinus: CDVPlugin {
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
        if let activeTextField = getActiveTextField() {
            activeTextField.inputAccessoryView = toolbar
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
        // Traverse through the view hierarchy to find the active UITextField
        let keyWindow = UIApplication.shared.connectedScenes
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }

        return keyWindow?.findFirstResponder() as? UITextField
    }
}
