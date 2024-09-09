import UIKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    @objc(addMinusButton:)
    func addMinusButton(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            if let viewController = self.viewController {
                print("viewController is not nil") // 確認 viewController 存在
                if let textField = self.findTextFieldIn(viewController.view) {
                    self.addMinusButtonToTextField(textField: textField)
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Minus button added")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                } else {
                    let pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "TextField not found")
                    self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
    }
    
    func findTextFieldIn(_ view: UIView) -> UITextField? {
        for subview in view.subviews {
            if let textField = subview as? UITextField {
                print("Found UITextField: \(textField)")
                return textField
            } else if let foundTextField = findTextFieldIn(subview) {
                return foundTextField
            }
        }
        print("No UITextField found in view: \(view)")
        return nil
    }
    
    func addMinusButtonToTextField(textField: UITextField) {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let minusButton = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(insertMinus))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePressed))
        
        toolbar.setItems([minusButton, flexibleSpace, doneButton], animated: false)
        textField.inputAccessoryView = toolbar
        textField.keyboardType = .numberPad

        print("UIToolbar added to UITextField: \(textField)")
    }
    
    @objc func insertMinus() {
        if let textField = findTextFieldIn(self.viewController.view), let currentText = textField.text {
            textField.text = currentText + "-"
        }
    }
    
    @objc func donePressed() {
        self.viewController.view.endEditing(true)
    }
}
