import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {

    @objc(addMinusButton:)
    func addMinusButton(command: CDVInvokedUrlCommand) {
        // Create a toolbar with a minus button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(self.minusButtonTapped))

        // Flexible space to push the button to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexibleSpace, minusButton], animated: false)

        // Attach the toolbar to the currently active input field
        attachToolbarToActiveInput(toolbar)

        // Send a success callback to JavaScript
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc func minusButtonTapped() {
        // Inject a minus sign into the currently focused input field
        if let activeTextField = getActiveTextField() {
            activeTextField.text = (activeTextField.text ?? "") + "-"
        }
    }

    private func attachToolbarToActiveInput(_ toolbar: UIToolbar) {
        // Get the currently active UITextField or UITextView
        if let activeTextField = getActiveTextField(), activeTextField.isFirstResponder {
            activeTextField.inputAccessoryView = toolbar
            activeTextField.reloadInputViews()
        } else {
            print("No active text field found to attach the toolbar.")
        }
    }

    private func getActiveTextField() -> UITextField? {
        // Traverse view hierarchy to find the active UITextField
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
