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

        // Attach the toolbar to the input field in the web page
        attachToolbarToInputField(toolbar)

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

    private func attachToolbarToInputField(_ toolbar: UIToolbar) {
        // Ensure webView is a WKWebView
        if let webView = self.webView as? WKWebView {
            // Use JavaScript to monitor the specific input field with id="myInput"
            webView.evaluateJavaScript("""
            var inputElement = document.getElementById('myInput');
            if (inputElement) {
                inputElement.addEventListener('focus', function() {
                    // Call native code to add the toolbar when the input gets focus
                    window.webkit.messageHandlers.cordova.postMessage('addToolbar');
                });
            } else {
                console.log('Element with id "myInput" not found');
            }
            """, completionHandler: nil)
        }
    }
}
