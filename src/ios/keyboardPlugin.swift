import UIKit
import WebKit

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

        // Add the toolbar to the keyboard of the HTML input
        addToolbarToWebViewInput(toolbar)

        // Send a success callback to JavaScript
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc func minusButtonTapped() {
        // Inject a minus sign into the currently focused input in the WebView
        self.webView?.evaluateJavaScript("document.activeElement.value += '-';", completionHandler: nil)
    }

    private func addToolbarToWebViewInput(_ toolbar: UIToolbar) {
        // Traverse all subviews to find the WKWebView
        if let webView = self.webView as? WKWebView {
            webView.evaluateJavaScript("document.activeElement.tagName") { result, error in
                if let tagName = result as? String, tagName == "INPUT" {
                    // Detect if the focused element is an input field
                    if let inputView = self.getWebViewInputAccessoryView() {
                        inputView.inputAccessoryView = toolbar
                        inputView.reloadInputViews()
                    }
                }
            }
        }
    }

    private func getWebViewInputAccessoryView() -> UIView? {
        // Return the view responsible for the WebView's input
        for window in UIApplication.shared.windows {
            if let firstResponder = window.findFirstResponder() {
                return firstResponder as? UIView
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
