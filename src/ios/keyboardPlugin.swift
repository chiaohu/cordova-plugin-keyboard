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

        // Inject JavaScript to monitor the input element with id="myInput" and attach toolbar to it
        injectJavaScriptToAttachToolbar(toolbar)

        // Send a success callback to JavaScript
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK)
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc func minusButtonTapped() {
        // Inject a minus sign into the currently focused input in the WebView
        if let webView = self.webView as? WKWebView {
            webView.evaluateJavaScript("document.activeElement.value += '-';", completionHandler: nil)
        }
    }

    private func injectJavaScriptToAttachToolbar(_ toolbar: UIToolbar) {
        // Ensure webView is a WKWebView
        if let webView = self.webView as? WKWebView {
            webView.evaluateJavaScript("""
            var inputElement = document.getElementById('myInput');
            if (inputElement) {
                inputElement.addEventListener('focus', function() {
                    // Handle focus event, such as notifying native code
                    // You can add additional native calls here if needed
                });
            } else {
                console.log('Element with id "myInput" not found');
            }
            """, completionHandler: nil)
        } else {
            print("Failed to cast webView as WKWebView")
        }
    }
}
