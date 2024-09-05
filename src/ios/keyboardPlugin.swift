import Foundation
import WebKit

@objc(KeyboardPlugin) class KeyboardPlugin: CDVPlugin {
    
    var doneToolbar: String!

    override func pluginInitialize() {
        super.pluginInitialize()
        setupToolbar()
    }

    // Define the toolbar as HTML string
    func setupToolbar() {
        doneToolbar = """
        <div id="custom-toolbar" style="position: fixed; bottom: 0; width: 100%; background-color: #fff; border-top: 1px solid #ddd; text-align: center;">
            <button id="minusBtn">-</button>
            <button id="doneBtn">Done</button>
        </div>
        """
    }

    @objc(addCustomToolbar:)
    func addCustomToolbar(command: CDVInvokedUrlCommand) {
        if let webView = self.webView as? WKWebView {
            let js = """
            (function() {
                var toolbarHTML = \(self.doneToolbar);
                var existingToolbar = document.getElementById('custom-toolbar');
                if (!existingToolbar) {
                    document.body.insertAdjacentHTML('beforeend', toolbarHTML);
                    document.getElementById('minusBtn').addEventListener('click', function() {
                        cordova.exec(null, null, 'KeyboardPlugin', 'minusButtonAction', []);
                    });
                    document.getElementById('doneBtn').addEventListener('click', function() {
                        cordova.exec(null, null, 'KeyboardPlugin', 'doneButtonAction', []);
                    });
                }
            })();
            """
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Toolbar added")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(minusButtonAction:)
    func minusButtonAction(command: CDVInvokedUrlCommand) {
        if let webView = self.webView as? WKWebView {
            let js = """
            (function() {
                var inputs = document.querySelectorAll('input[type="text"], input[type="number"]');
                for (var i = 0; i < inputs.length; i++) {
                    var input = inputs[i];
                    if (document.activeElement === input) {
                        input.value += '-';
                        input.focus();
                    }
                }
            })();
            """
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Minus button pressed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(doneButtonAction:)
    func doneButtonAction(command: CDVInvokedUrlCommand) {
        if let webView = self.webView as? WKWebView {
            let js = """
            document.activeElement.blur();
            var toolbar = document.getElementById('custom-toolbar');
            if (toolbar) {
                toolbar.remove();
            }
            """
            webView.evaluateJavaScript(js) { _, error in
                if let error = error {
                    print("Error evaluating JavaScript: \(error.localizedDescription)")
                }
            }
        }
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Done button pressed")
        self.commandDelegate.send(pluginResult, callbackId: command.callbackId)
    }
}
