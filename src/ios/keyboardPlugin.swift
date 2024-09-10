import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    var textField: UITextField?

    @objc(addMinusButton:)
    func addMinusButton(command: CDVInvokedUrlCommand) {
        // Create a text field and add it to the view if it doesn't exist
        if textField == nil {
            createTextField()
        }
        
        // Ensure the text field becomes the first responder
        textField?.becomeFirstResponder()

        // Create a toolbar with a minus button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(self.minusButtonTapped))

        // Flexible space to push the button to the right
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolbar.setItems([flexibleSpace, minusButton], animated: false)

        // Add toolbar as inputAccessoryView for the active text field
        if let activeTextField = getActiveTextField(), activeTextField.isFirstResponder {
            activeTextField.inputAccessoryView = toolbar
            print("Successfully added toolbar to active text field.")
        } else {
            print("No active text field found.")
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

    private func createTextField() {
        // Create a new UITextField
        textField = UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        textField?.borderStyle = .roundedRect

        // Add the text field to the main view
        if let textField = textField {
            self.viewController.view.addSubview(textField)
            print("Text field added to the view.")
        }

        // Add target to detect when editing begins
        textField?.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
    }

    @objc func textFieldDidBeginEditing(_ textField: UITextField) {
        print("Text field began editing.")
        // This is where the minus button toolbar could be added if not already set
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
