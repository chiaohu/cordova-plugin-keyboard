import UIKit

@objc(IOSKeyboardExtension) class IOSKeyboardExtension : CDVPlugin {
    @objc(addHyphenKey:)
    func addHyphenKey(command: CDVInvokedUrlCommand) {
        DispatchQueue.main.async {
            if let keyboardVC = UIInputViewController.init() {
                let hyphenButton = UIButton(type: .system)
                hyphenButton.setTitle("-", for: .normal)
                hyphenButton.sizeToFit()
                hyphenButton.addTarget(self, action: #selector(self.insertHyphen), for: .touchUpInside)
                
                keyboardVC.inputView?.addSubview(hyphenButton)
                
                let result = CDVPluginResult(status: CDVCommandStatus_OK)
                self.commandDelegate.send(result, callbackId: command.callbackId)
            } else {
                let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "Failed to add hyphen key")
                self.commandDelegate.send(result, callbackId: command.callbackId)
            }
        }
    }
    
    @objc func insertHyphen() {
        UIPasteboard.general.string = "-"
        NotificationCenter.default.post(name: UITextView.textDidChangeNotification, object: nil)
    }
}
